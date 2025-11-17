# -----------------------------------------------------------------------------
# Archivo: app/routes/mis_reservas_routes.py
# Responsabilidad:
#   - Manejar la vista "Mis reservas" del usuario logueado.
#   - Listar solo las reservas visibles (soft delete con campo es_visible).
#   - Permitir cancelar una reserva (estado = 'cancelada').
#   - Permitir eliminarla del listado del usuario (es_visible = 0).
#
# Alcance:
#   - Se accede desde el navbar y desde redirecciones del flujo de reserva.
#   - Trabaja junto con la plantilla templates/mis_reservas.html.
# -----------------------------------------------------------------------------

from flask import (
    Blueprint,
    render_template,
    session,
    redirect,
    url_for,
    flash,
)
from database.connection import get_connection

mis_reservas_bp = Blueprint("mis_reservas", __name__, url_prefix="/mis-reservas")


# -----------------------------------------------------------------------------
# Ruta: GET /mis-reservas/
# Responsabilidad:
#   - Mostrar el listado de reservas del usuario logueado.
#   - Solo mostrar reservas con es_visible = 1 (soft delete aplicado).
# -----------------------------------------------------------------------------
@mis_reservas_bp.route("/", methods=["GET"])
def mis_reservas():
    usuario = session.get("usuario")
    if not usuario:
        flash("Debes iniciar sesión para ver tus reservas.", "error")
        return redirect(url_for("auth.login"))

    id_usuario = usuario["id"]

    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    sql = """
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
        JOIN habitacion AS h ON h.id_habitacion = r.id_habitacion
        JOIN tarifa     AS t ON t.id_tarifa     = r.id_tarifa
        WHERE r.id_usuario = %s
          AND r.es_visible = 1
        ORDER BY r.fecha_check_in DESC
    """

    try:
        cursor.execute(sql, (id_usuario,))
        reservas = cursor.fetchall()
    except Exception as e:
        print("[ERROR] Al listar reservas del usuario:", e)
        reservas = []
        flash("Ocurrió un error al obtener tus reservas.", "error")
    finally:
        cursor.close()
        conn.close()

    return render_template(
        "mis_reservas.html",
        usuario=usuario,
        reservas=reservas,
    )


# -----------------------------------------------------------------------------
# Ruta: POST /mis-reservas/cancelar/<id_reserva>
# Responsabilidad:
#   - Cambiar el estado de la reserva a 'cancelada'.
#   - No elimina la fila ni la oculta: sigue visible para que el usuario
#     pueda verla y, si quiere, eliminarla del listado con el tacho.
# -----------------------------------------------------------------------------
@mis_reservas_bp.route("/cancelar/<int:id_reserva>", methods=["POST"])
def cancelar_reserva(id_reserva):
    usuario = session.get("usuario")
    if not usuario:
        flash("Debes iniciar sesión para gestionar tus reservas.", "error")
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

    try:
        cursor.execute(update_sql, (id_reserva, id_usuario))
        conn.commit()
        flash("La reserva fue cancelada correctamente.", "success")
    except Exception as e:
        print("[ERROR] Al cancelar reserva:", e)
        conn.rollback()
        flash("Ocurrió un error al cancelar la reserva.", "error")
    finally:
        cursor.close()
        conn.close()

    return redirect(url_for("mis_reservas.mis_reservas"))


# -----------------------------------------------------------------------------
# Ruta: POST /mis-reservas/eliminar/<id_reserva>
# Responsabilidad:
#   - Soft delete: marcar la reserva como "no visible" para el usuario,
#     sin borrarla físicamente de la base de datos.
#   - Se usa cuando el usuario presiona el icono de tacho de basura
#     en el cuadro de "Mis reservas".
# -----------------------------------------------------------------------------
@mis_reservas_bp.route("/eliminar/<int:id_reserva>", methods=["POST"])
def eliminar_reserva(id_reserva):
    usuario = session.get("usuario")
    if not usuario:
        flash("Debes iniciar sesión para gestionar tus reservas.", "error")
        return redirect(url_for("auth.login"))

    id_usuario = usuario["id"]

    conn = get_connection()
    cursor = conn.cursor()

    update_sql = """
        UPDATE reserva
        SET es_visible = 0
        WHERE id_reserva = %s
          AND id_usuario = %s
    """

    try:
        cursor.execute(update_sql, (id_reserva, id_usuario))
        conn.commit()
        flash("La reserva fue eliminada de tu listado.", "success")
    except Exception as e:
        print("[ERROR] Al hacer soft delete de reserva:", e)
        conn.rollback()
        flash("Ocurrió un error al eliminar la reserva del listado.", "error")
    finally:
        cursor.close()
        conn.close()

    return redirect(url_for("mis_reservas.mis_reservas"))
