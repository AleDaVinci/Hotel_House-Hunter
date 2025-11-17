# -----------------------------------------------------------------------------
# Archivo: app/routes/modificar_reserva_routes.py
# Responsabilidad:
#   - Manejar la lógica de modificación de reservas del cliente:
#       * Simular cambio de fechas (agregar / quitar días).
#       * Aplicar el cambio de fechas si hay disponibilidad.
#       * Cancelar la reserva actual para "cambiarla totalmente"
#         y redirigir al usuario al dashboard para crear una nueva.
#
# Alcance:
#   - Trabaja SÓLO sobre reservas del usuario logueado.
#   - Valida disponibilidad usando la misma lógica de solapamiento
#     que en la búsqueda de habitaciones.
#   - Recalcula precios y promociones usando precios_service.
# -----------------------------------------------------------------------------

from flask import Blueprint, request, jsonify, session, url_for
from datetime import datetime, date
from database.connection import get_connection
from app.services.precios_service import calcular_opciones_tarifa

modificar_reserva_bp = Blueprint("modificar_reserva", __name__)


# Utilidad interna: cargar la reserva y validar que pertenece al usuario
def _obtener_reserva_usuario(id_reserva, id_usuario):
  conn = get_connection()
  cursor = conn.cursor(dictionary=True)

  sql = """
      SELECT
          r.id_reserva,
          r.codigo_reserva,
          r.id_usuario,
          r.id_habitacion,
          r.id_tarifa,
          r.id_promocion,
          r.fecha_check_in,
          r.fecha_check_out,
          r.cantidad_huespedes,
          r.estado,
          r.monto_total
      FROM reserva AS r
      WHERE r.id_reserva = %s
        AND r.id_usuario = %s
  """
  cursor.execute(sql, (id_reserva, id_usuario))
  reserva = cursor.fetchone()

  cursor.close()
  conn.close()
  return reserva


# Utilidad interna: verificar disponibilidad para una habitación y rango de fechas
def _habitacion_disponible(id_habitacion, id_reserva_actual, fecha_ini, fecha_fin):
  """
  Devuelve True si la habitación está disponible en el rango dado,
  ignorando la propia reserva actual (id_reserva_actual).
  """
  conn = get_connection()
  cursor = conn.cursor()

  sql = """
      SELECT 1
      FROM reserva AS r
      WHERE r.id_habitacion = %s
        AND r.id_reserva <> %s
        AND r.estado IN ('pendiente', 'confirmada')
        AND r.fecha_check_in  < %s
        AND r.fecha_check_out > %s
      LIMIT 1
  """

  cursor.execute(sql, (id_habitacion, id_reserva_actual, fecha_fin, fecha_ini))
  fila = cursor.fetchone()

  cursor.close()
  conn.close()

  # Si NO hay filas, está disponible
  return fila is None


# Utilidad interna: recalcular precio con la misma tarifa para nuevas fechas
def _recalcular_precio_con_misma_tarifa(id_tarifa, fecha_ini, fecha_fin):
  """
  Usa calcular_opciones_tarifa para el nuevo rango de fechas
  y busca la opción que coincida con id_tarifa.
  Devuelve (noches, total_nuevo, id_promocion_nueva, detalle_opcion)
  o (None, None, None, None) si no se pudo calcular.
  """
  opciones_tarifa, noches = calcular_opciones_tarifa(fecha_ini, fecha_fin)

  opcion_encontrada = None
  for opt in opciones_tarifa:
      if opt.get("id_tarifa") == id_tarifa:
          opcion_encontrada = opt
          break

  if not opcion_encontrada and opciones_tarifa:
      # Si no se encontró exactamente la misma tarifa,
      # tomamos la primera como fallback.
      opcion_encontrada = opciones_tarifa[0]

  if not opcion_encontrada:
      return None, None, None, None

  # total_final pre-calculado o calculamos en base a precio_noche_final
  total_nuevo = opcion_encontrada.get("total_final")
  if total_nuevo is None:
      precio_noche = opcion_encontrada.get("precio_noche_final") or 0
      total_nuevo = precio_noche * noches

  promo = opcion_encontrada.get("promo_aplicada")
  id_promocion_nueva = None
  if promo and isinstance(promo, dict):
      id_promocion_nueva = promo.get("id_promocion")

  return noches, float(total_nuevo), id_promocion_nueva, opcion_encontrada


# -----------------------------------------------------------------------------
# POST /reservas/<id_reserva>/simular_cambio_fechas
# Responsabilidad:
#   - Recibir nuevas fechas de check-in / check-out.
#   - Verificar disponibilidad de la habitación.
#   - Recalcular el precio usando la misma tarifa.
#   - Devolver diferencia de importe vs. la reserva original.
# -----------------------------------------------------------------------------
@modificar_reserva_bp.route(
  "/reservas/<int:id_reserva>/simular_cambio_fechas",
  methods=["POST"],
)
def simular_cambio_fechas(id_reserva):
  usuario = session.get("usuario")
  if not usuario:
      return jsonify(
          ok=False,
          message="Debes iniciar sesión para modificar una reserva.",
          redirect=url_for("auth.login"),
      ), 401

  id_usuario = usuario["id"]
  data = request.get_json() or {}

  nueva_ini_str = data.get("fecha_check_in")
  nueva_fin_str = data.get("fecha_check_out")

  if not nueva_ini_str or not nueva_fin_str:
      return jsonify(
          ok=False,
          message="Debes indicar las nuevas fechas de check-in y check-out.",
      ), 400

  try:
      nueva_ini = datetime.strptime(nueva_ini_str, "%Y-%m-%d").date()
      nueva_fin = datetime.strptime(nueva_fin_str, "%Y-%m-%d").date()
  except ValueError:
      return jsonify(
          ok=False,
          message="Formato de fecha inválido. Usá YYYY-MM-DD.",
      ), 400

  hoy = date.today()
  limite_max = date(2026, 12, 31)

  # Validaciones simples
  if nueva_ini < hoy:
      return jsonify(
          ok=False,
          message="La fecha de entrada no puede ser anterior a hoy.",
      ), 400

  if nueva_fin <= nueva_ini:
      return jsonify(
          ok=False,
          message="La fecha de salida debe ser posterior a la de entrada.",
      ), 400

  if nueva_ini > limite_max or nueva_fin > limite_max:
      return jsonify(
          ok=False,
          message="Las disponibilidades solo están cargadas hasta el 31/12/2026.",
      ), 400

  # Traer reserva original y validar que sea del usuario
  reserva = _obtener_reserva_usuario(id_reserva, id_usuario)
  if not reserva:
      return jsonify(
          ok=False,
          message="La reserva no existe o no te pertenece.",
      ), 404

  if reserva["estado"] in ("cancelada", "finalizada"):
      return jsonify(
          ok=False,
          message="No se puede modificar una reserva cancelada o finalizada.",
      ), 400

  # Verificar disponibilidad de la misma habitación, excluyendo la reserva actual
  disponible = _habitacion_disponible(
      reserva["id_habitacion"],
      reserva["id_reserva"],
      nueva_ini,
      nueva_fin,
  )
  if not disponible:
      return jsonify(
          ok=True,
          disponible=False,
          message=(
              "No hay disponibilidad para extender o cambiar a esas fechas. "
              "Podés cancelar la reserva y generar una nueva."
          ),
      ), 200

  # Recalcular precio con la misma tarifa
  noches_nuevas, nuevo_total, id_promocion_nueva, opcion = _recalcular_precio_con_misma_tarifa(
      reserva["id_tarifa"],
      nueva_ini,
      nueva_fin,
  )

  if noches_nuevas is None:
      return jsonify(
          ok=False,
          message="No se pudo recalcular el precio para las nuevas fechas.",
      ), 500

  total_anterior = float(reserva["monto_total"])
  diferencia = nuevo_total - total_anterior

  return jsonify(
      ok=True,
      disponible=True,
      fecha_check_in_original=reserva["fecha_check_in"].strftime("%Y-%m-%d"),
      fecha_check_out_original=reserva["fecha_check_out"].strftime("%Y-%m-%d"),
      fecha_check_in_nueva=nueva_ini.strftime("%Y-%m-%d"),
      fecha_check_out_nueva=nueva_fin.strftime("%Y-%m-%d"),
      noches_nuevas=noches_nuevas,
      total_anterior=total_anterior,
      nuevo_total=nuevo_total,
      diferencia=diferencia,
      id_promocion_nueva=id_promocion_nueva,
  ), 200


# -----------------------------------------------------------------------------
# POST /reservas/<id_reserva>/aplicar_cambio_fechas
# Responsabilidad:
#   - Aplicar el cambio de fechas (siempre validando de nuevo).
#   - Actualizar fechas, monto_total e id_promocion de la reserva.
# -----------------------------------------------------------------------------
@modificar_reserva_bp.route(
  "/reservas/<int:id_reserva>/aplicar_cambio_fechas",
  methods=["POST"],
)
def aplicar_cambio_fechas(id_reserva):
  usuario = session.get("usuario")
  if not usuario:
      return jsonify(
          ok=False,
          message="Debes iniciar sesión para modificar una reserva.",
          redirect=url_for("auth.login"),
      ), 401

  id_usuario = usuario["id"]
  data = request.get_json() or {}

  nueva_ini_str = data.get("fecha_check_in")
  nueva_fin_str = data.get("fecha_check_out")

  if not nueva_ini_str or not nueva_fin_str:
      return jsonify(
          ok=False,
          message="Debes indicar las nuevas fechas de check-in y check-out.",
      ), 400

  try:
      nueva_ini = datetime.strptime(nueva_ini_str, "%Y-%m-%d").date()
      nueva_fin = datetime.strptime(nueva_fin_str, "%Y-%m-%d").date()
  except ValueError:
      return jsonify(
          ok=False,
          message="Formato de fecha inválido. Usá YYYY-MM-DD.",
      ), 400

  hoy = date.today()
  limite_max = date(2026, 12, 31)

  if nueva_ini < hoy or nueva_fin <= nueva_ini or nueva_ini > limite_max or nueva_fin > limite_max:
      return jsonify(
          ok=False,
          message="Las nuevas fechas no son válidas.",
      ), 400

  reserva = _obtener_reserva_usuario(id_reserva, id_usuario)
  if not reserva:
      return jsonify(
          ok=False,
          message="La reserva no existe o no te pertenece.",
      ), 404

  if reserva["estado"] in ("cancelada", "finalizada"):
      return jsonify(
          ok=False,
          message="No se puede modificar una reserva cancelada o finalizada.",
      ), 400

  disponible = _habitacion_disponible(
      reserva["id_habitacion"],
      reserva["id_reserva"],
      nueva_ini,
      nueva_fin,
  )
  if not disponible:
      return jsonify(
          ok=False,
          message="No hay disponibilidad para cambiar la reserva a esas fechas.",
      ), 400

  noches_nuevas, nuevo_total, id_promocion_nueva, opcion = _recalcular_precio_con_misma_tarifa(
      reserva["id_tarifa"],
      nueva_ini,
      nueva_fin,
  )

  if noches_nuevas is None:
      return jsonify(
          ok=False,
          message="No se pudo recalcular el precio para las nuevas fechas.",
      ), 500

  # Actualizar la reserva
  conn = get_connection()
  cursor = conn.cursor()

  update_sql = """
      UPDATE reserva
      SET fecha_check_in   = %s,
          fecha_check_out  = %s,
          id_promocion     = %s,
          monto_total      = %s
      WHERE id_reserva = %s
        AND id_usuario = %s
  """

  try:
      cursor.execute(
          update_sql,
          (
              nueva_ini,
              nueva_fin,
              id_promocion_nueva,
              nuevo_total,
              reserva["id_reserva"],
              reserva["id_usuario"],
          ),
      )
      conn.commit()
  except Exception as e:
      print("[ERROR] Al aplicar cambio de fechas:", e)
      conn.rollback()
      cursor.close()
      conn.close()
      return jsonify(
          ok=False,
          message="Ocurrió un error al guardar los cambios de la reserva.",
      ), 500

  cursor.close()
  conn.close()

  return jsonify(
      ok=True,
      message="La reserva fue modificada correctamente.",
      nuevo_total=nuevo_total,
      noches_nuevas=noches_nuevas,
      redirect_url=url_for("mis_reservas.mis_reservas"),
  ), 200


# -----------------------------------------------------------------------------
# POST /reservas/<id_reserva>/cambiar_totalmente
# Responsabilidad:
#   - Cancelar la reserva actual para que el usuario pueda
#     generar una nueva desde el dashboard.
# -----------------------------------------------------------------------------
@modificar_reserva_bp.route(
  "/reservas/<int:id_reserva>/cambiar_totalmente",
  methods=["POST"],
)
def cambiar_totalmente(id_reserva):
  usuario = session.get("usuario")
  if not usuario:
      return jsonify(
          ok=False,
          message="Debes iniciar sesión para modificar una reserva.",
          redirect=url_for("auth.login"),
      ), 401

  id_usuario = usuario["id"]

  conn = get_connection()
  cursor = conn.cursor()

  update_sql = """
      UPDATE reserva
      SET estado = 'cancelada'
      WHERE id_reserva = %s
        AND id_usuario = %s
  """

  try:
      cursor.execute(update_sql, (id_reserva, id_usuario))
      conn.commit()
  except Exception as e:
      print("[ERROR] Al cancelar para cambiar totalmente:", e)
      conn.rollback()
      cursor.close()
      conn.close()
      return jsonify(
          ok=False,
          message="Ocurrió un error al cancelar la reserva.",
      ), 500

  cursor.close()
  conn.close()

  # Redirigimos al dashboard para que genere una nueva reserva
  return jsonify(
      ok=True,
      message="La reserva fue cancelada. Podés generar una nueva.",
      redirect_url=url_for("main.dashboard"),
  ), 200
