# -----------------------------------------------------------------------------
# Archivo: app/routes/mis_reservas_routes.py
# Responsabilidad:
#   - Exponer la vista "Mis reservas" del cliente.
#   - Listar las reservas del usuario logueado.
#   - Permitir acciones sobre cada reserva (por ahora: cancelar).
#
# Alcance:
#   - Este módulo trabaja SOLO con reservas del cliente final.
#   - No calcula precios ni disponibilidades (eso sigue en reserva_routes.py).
#   - Usa la conexión MySQL centralizada en database/connection.py.
# -----------------------------------------------------------------------------

from flask import (
    Blueprint,
    render_template,
    redirect,
    url_for,
    session,
    flash,
)
from database.connection import get_connection

# Creamos un Blueprint específico para "Mis reservas"
mis_reservas_bp = Blueprint("mis_reservas", __name__)


# -----------------------------------------------------------------------------
# Ruta: GET /mis-reservas
# Responsabilidad:
#   - Mostrar todas las reservas del usuario logueado.
#   - Si no hay sesión, redirigir al login.
# -----------------------------------------------------------------------------
@mis_reservas_bp.route("/mis-reservas", methods=["GET"])
def mis_reservas():
    # 1) Verificar sesión
    usuario = session.get("usuario")
    if not usuario:
        # Si no hay usuario en sesión, se fuerza login
        return redirect(url_for("auth.login"))

    id_usuario = usuario["id"]

    # 2) Conectar a la BD y traer reservas del usuario
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

   
    query = """
        SELECT
            r.id_reserva,
            r.codigo_reserva,
            r.fecha_check_in,
            r.fecha_check_out,
            r.cantidad_huespedes,
            r.estado,
            r.monto_total,
            r.creado_en,
            h.nombre AS habitacion_nombre,
            t.nombre AS tarifa_nombre
        FROM reserva AS r
        JOIN habitacion AS h
            ON h.id_habitacion = r.id_habitacion
        JOIN tarifa AS t
            ON t.id_tarifa = r.id_tarifa
        WHERE r.id_usuario = %s
        ORDER BY r.fecha_check_in DESC
    """

    cursor.execute(query, (id_usuario,))
    reservas = cursor.fetchall()

    cursor.close()
    conn.close()

   
    return render_template(
        "mis_reservas.html",
        usuario=usuario,
        reservas=reservas,
    )


# -----------------------------------------------------------------------------
# Ruta: POST /reservas/<id_reserva>/cancelar
# Responsabilidad:
#   - Cambiar el estado de una reserva a "cancelada".
#   - Solo permite cancelar reservas del usuario logueado.
# -----------------------------------------------------------------------------
@mis_reservas_bp.route("/reservas/<int:id_reserva>/cancelar", methods=["POST"])
def cancelar_reserva(id_reserva):
    usuario = session.get("usuario")
    if not usuario:
        return redirect(url_for("auth.login"))

    id_usuario = usuario["id"]

    conn = get_connection()
    cursor = conn.cursor()

  
    update_sql = """
        UPDATE reserva
        SET estado = 'cancelada'
        WHERE id_reserva = %s
          AND id_usuario = %s
    """

    cursor.execute(update_sql, (id_reserva, id_usuario))
    conn.commit()

    if cursor.rowcount == 0:
        flash(
            "No se pudo cancelar la reserva (no encontrada o no te pertenece).",
            "error",
        )
    else:
        flash("La reserva fue cancelada correctamente.", "success")

    cursor.close()
    conn.close()

    # Siempre volvemos a la vista "Mis reservas"
    return redirect(url_for("mis_reservas.mis_reservas"))
