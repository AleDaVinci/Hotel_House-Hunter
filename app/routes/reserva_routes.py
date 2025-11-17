# ---------------------------------------------------------------------
# Archivo: app/routes/reserva_routes.py
# Responsabilidad:
#   - Manejar búsquedas de habitaciones disponibles
#   - Aplicar reglas de negocio de disponibilidad:
#       * Solo se considera disponibilidad desde hoy hasta 31/12/2026
#       * Una habitación está disponible si NO tiene reservas solapadas
#   - Delegar el cálculo de precios / tarifas / promociones al servicio
#     app/services/precios_service.py
#   - Crear reservas reales en la tabla `reserva`.
# ---------------------------------------------------------------------

from flask import Blueprint, request, jsonify, session, url_for
from datetime import datetime, date
from database.connection import get_connection
from app.services.precios_service import (
    calcular_opciones_tarifa,
    adjuntar_precios_a_habitaciones,
)

reserva_bp = Blueprint("reserva", __name__)


@reserva_bp.route("/buscar_habitaciones", methods=["POST"])
def buscar_habitaciones():
    """Recibe fecha_inicio, fecha_fin y pasajeros, valida el rango
    y devuelve la lista de habitaciones disponibles en formato JSON,
    incluyendo amenidades y opciones de precio (tarifas + promociones).
    """

    data = request.get_json()

    fecha_inicio_str = data.get("fecha_inicio")
    fecha_fin_str = data.get("fecha_fin")
    pasajeros_str = data.get("pasajeros")

    # ===== 1) Validación básica de presencia =====
    if not fecha_inicio_str or not fecha_fin_str or not pasajeros_str:
        return jsonify(
            ok=False,
            message="Faltan parámetros para la búsqueda."
        ), 400

    # ===== 2) Parseo y validación de tipos =====
    try:
        fecha_inicio = datetime.strptime(fecha_inicio_str, "%Y-%m-%d").date()
        fecha_fin = datetime.strptime(fecha_fin_str, "%Y-%m-%d").date()
        pasajeros = int(pasajeros_str)
    except ValueError:
        return jsonify(
            ok=False,
            message="Formato de datos inválido."
        ), 400

    hoy = date.today()
    limite_max = date(2026, 12, 31)

    # ===== 3) Validaciones de reglas de negocio de fechas =====
    if fecha_inicio < hoy:
        return jsonify(
            ok=False,
            message="La fecha de entrada no puede ser anterior a hoy."
        ), 400

    if fecha_fin <= fecha_inicio:
        return jsonify(
            ok=False,
            message="La fecha de salida debe ser posterior a la fecha de entrada."
        ), 400

    if fecha_inicio > limite_max or fecha_fin > limite_max:
        return jsonify(
            ok=False,
            message=(
                "Las disponibilidades solo están cargadas hasta el 31/12/2026. "
                "Elegí fechas dentro de ese rango."
            )
        ), 400

    # ===== 4) Consulta de habitaciones disponibles en la BD =====
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    # Regla de solapamiento:
    #   Hay solapamiento si:
    #     r.fecha_check_in  < fecha_fin_buscada
    #     Y
    #     r.fecha_check_out > fecha_inicio_buscada
    #
    # Una habitación está disponible si NO EXISTE reserva que cumpla eso.
    sql = """
    SELECT 
        h.id_habitacion,
        h.nombre,
        h.descripcion,
        h.capacidad_personas AS capacidad,
        h.imagen_principal
        FROM habitacion AS h
        WHERE h.capacidad_personas >= %s
        AND h.es_activa = 1
        AND NOT EXISTS (
          SELECT 1
          FROM reserva AS r
          WHERE r.id_habitacion = h.id_habitacion
            AND r.estado IN ('pendiente', 'confirmada')
            AND r.fecha_check_in  < %s
            AND r.fecha_check_out > %s
      )
    """

    params = (pasajeros, fecha_fin, fecha_inicio)

    try:
        cursor.execute(sql, params)
        habitaciones = cursor.fetchall()
    except Exception as e:
        print("Error al consultar disponibilidad:", e)
        cursor.close()
        conn.close()
        return jsonify(
            ok=False,
            message="Error al consultar la disponibilidad."
        ), 500

    # ===== 5) Asignación de imágenes =====
    # Si imagen_principal está cargada, la usamos tal cual.
    # Si no, asignamos f1/f2/f3 como demo.
    for index, hab in enumerate(habitaciones, start=1):
        if hab.get("imagen_principal"):
            hab["imagen"] = hab["imagen_principal"]
        else:
            # simple rotación de imágenes de demo
            if index % 3 == 1:
                hab["imagen"] = "f1.jpg"
            elif index % 3 == 2:
                hab["imagen"] = "f2.jpg"
            else:
                hab["imagen"] = "f3.jpg"

        # ya no necesitamos enviar imagen_principal al front
        hab.pop("imagen_principal", None)

    # ===== 6) Traer amenidades por habitación =====
    #   Para cada habitación disponible, buscamos sus amenities activos
    #   y los agregamos como lista en hab["amenidades"].
    for hab in habitaciones:
        cursor.execute(
            """
            SELECT a.nombre, a.icono
            FROM habitacion_amenidad ha
            JOIN amenidad a ON a.id_amenidad = ha.id_amenidad
            WHERE ha.id_habitacion = %s
              AND a.es_activa = 1
            """,
            (hab["id_habitacion"],),
        )
        amenidades = cursor.fetchall()  # lista de dicts con {nombre, icono}
        hab["amenidades"] = amenidades

    cursor.close()
    conn.close()

    # ===== 7) Calcular precios (tarifas + promociones) =====
    #   Delegamos el cálculo al servicio de precios.
    opciones_tarifa, noches = calcular_opciones_tarifa(fecha_inicio, fecha_fin)

    # Agregamos a cada habitación la clave "tarifas" con las
    # opciones calculadas (incluye precio_noche_final, total_final, etc.).
    habitaciones = adjuntar_precios_a_habitaciones(
        habitaciones,
        opciones_tarifa,
        noches
    )

    # ===== 8) Respuesta JSON al frontend =====
    return jsonify({
        "ok": True,
        "noches": noches,
        "habitaciones": habitaciones
    })


# -----------------------------------------------------------------------------
# Ruta: POST /reservas/crear
# Responsabilidad:
#   - Crear una reserva real en la tabla `reserva`.
#   - Usar la info enviada desde el frontend (precios.js / dashboard.js).
#   - Asociar la reserva al usuario logueado (session["usuario"]["id"]).
#
# Formato esperado del JSON de entrada:
# {
#   "id_habitacion": 1,
#   "id_tarifa": 2,
#   "id_promocion": null,        # opcional
#   "fecha_check_in": "2025-11-20",
#   "fecha_check_out": "2025-11-22",
#   "cantidad_huespedes": 2,
#   "noches": 2,
#   "monto_total": 123456.78
# }
# -----------------------------------------------------------------------------
@reserva_bp.route("/reservas/crear", methods=["POST"])
def crear_reserva():
    # 1) Verificar que el usuario esté logueado
    usuario = session.get("usuario")
    if not usuario:
        return jsonify(
            ok=False,
            message="Debes iniciar sesión para crear una reserva.",
            redirect=url_for("auth.login"),
        ), 401

    id_usuario = usuario["id"]

    # 2) Leer JSON enviado desde el frontend
    data = request.get_json() or {}

    id_habitacion = data.get("id_habitacion")
    id_tarifa = data.get("id_tarifa")
    id_promocion = data.get("id_promocion")  # puede ser None
    fecha_check_in_str = data.get("fecha_check_in")
    fecha_check_out_str = data.get("fecha_check_out")
    cantidad_huespedes = data.get("cantidad_huespedes")
    noches = data.get("noches")
    monto_total = data.get("monto_total")

    # 3) Validaciones básicas de presencia
    if not all([
        id_habitacion,
        id_tarifa,
        fecha_check_in_str,
        fecha_check_out_str,
        cantidad_huespedes,
        noches,
        monto_total,
    ]):
        return jsonify(
            ok=False,
            message="Faltan datos para crear la reserva.",
        ), 400

    # 4) Parseo de tipos (int, float, date)
    try:
        id_habitacion = int(id_habitacion)
        id_tarifa = int(id_tarifa)
        cantidad_huespedes = int(cantidad_huespedes)
        noches = int(noches)
        monto_total = float(monto_total)

        fecha_check_in = datetime.strptime(fecha_check_in_str, "%Y-%m-%d").date()
        fecha_check_out = datetime.strptime(fecha_check_out_str, "%Y-%m-%d").date()

    except (ValueError, TypeError):
        return jsonify(
            ok=False,
            message="Formato de datos inválido al crear la reserva.",
        ), 400

    # 5) Validaciones simples de negocio
    if fecha_check_out <= fecha_check_in:
        return jsonify(
            ok=False,
            message="La fecha de salida debe ser posterior a la de entrada.",
        ), 400

    if cantidad_huespedes <= 0:
        return jsonify(
            ok=False,
            message="La cantidad de huéspedes debe ser mayor a 0.",
        ), 400

    # 6) Generar un código de reserva "amigable" para el cliente
    #    Ejemplo: HH-<idUsuario>-20251117193045
    codigo_reserva = f"HH-{id_usuario}-{datetime.now().strftime('%Y%m%d%H%M%S')}"

    # 7) Insertar en la base de datos
    conn = get_connection()
    cursor = conn.cursor()

    insert_sql = """
        INSERT INTO reserva (
            codigo_reserva,
            id_usuario,
            id_habitacion,
            id_tarifa,
            id_promocion,
            fecha_check_in,
            fecha_check_out,
            cantidad_huespedes,
            estado,
            monto_total
        )
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """

    try:
        cursor.execute(
            insert_sql,
            (
                codigo_reserva,
                id_usuario,
                id_habitacion,
                id_tarifa,
                id_promocion,
                fecha_check_in,
                fecha_check_out,
                cantidad_huespedes,
                "confirmada",  # estado inicial
                monto_total,
            ),
        )
        conn.commit()

    except Exception as e:
        print("[ERROR] Al crear reserva:", e)
        conn.rollback()
        cursor.close()
        conn.close()
        return jsonify(
            ok=False,
            message="Ocurrió un error al guardar la reserva.",
        ), 500

    cursor.close()
    conn.close()

    # 8) Respuesta OK con URL de redirección a "Mis reservas"
    return jsonify(
        ok=True,
        message="Reserva creada correctamente.",
        redirect_url=url_for("mis_reservas.mis_reservas"),
    ), 201
