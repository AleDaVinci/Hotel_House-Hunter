# -----------------------------------------------------------------------------
# Archivo: app/routes/mis_reservas_routes.py
# Responsabilidad:
#   - Exponer la vista "Mis reservas" del cliente.
#   - Listar las reservas del usuario logueado.
#   - Permitir acciones sobre cada reserva:
#       * Cancelar (estado = 'cancelada')
#       * Eliminar del listado (soft delete con es_visible = 0)
#   - Permitir buscar una reserva por código (desde el navbar) y
#     resaltar la card encontrada en la vista.
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
    request,   # <-- agregado para leer parámetros GET (codigo de búsqueda)
)
from database.connection import get_connection

# Creamos un Blueprint específico para "Mis reservas"
# Nombre del blueprint: "mis_reservas"
mis_reservas_bp = Blueprint("mis_reservas", __name__)


# -----------------------------------------------------------------------------
# Ruta: GET /mis-reservas
# Responsabilidad:
#   - Mostrar todas las reservas del usuario logueado.
#   - Solo mostrar reservas con es_visible = 1 (soft delete aplicado).
#   - Si no hay sesión, redirigir al login.
#   - Si viene un parámetro GET ?codigo=XXX:
#       * Intentar encontrar esa reserva en la lista del usuario.
#       * Si se encuentra, mandar highlight_id para resaltar la card.
#       * Si no, mandar mensaje_busqueda avisando que no se encontró.
# -----------------------------------------------------------------------------
@mis_reservas_bp.route("/mis-reservas", methods=["GET"])
def mis_reservas():
    # 1) Verificar sesión
    usuario = session.get("usuario")
    if not usuario:
        flash("Debes iniciar sesión para ver tus reservas.", "error")
        return redirect(url_for("auth.login"))

    id_usuario = usuario["id"]

    # 2) Leer parámetro de búsqueda proveniente del navbar (opcional)
    #    /mis-reservas?codigo=ABC123
    codigo_busqueda = request.args.get("codigo", "").strip()

    highlight_id = None        # id_reserva a resaltar (si se encuentra)
    mensaje_busqueda = None    # mensaje a mostrar si no se encuentra nada

    # 3) Conectar a la BD y traer reservas del usuario
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
          AND r.es_visible = 1
        ORDER BY r.fecha_check_in DESC
    """

    try:
        cursor.execute(query, (id_usuario,))
        reservas = cursor.fetchall()
    except Exception as e:
        print("[ERROR] Al listar reservas del usuario:", e)
        reservas = []
        flash("Ocurrió un error al obtener tus reservas.", "error")
    finally:
        cursor.close()
        conn.close()

    # 4) Si se hizo una búsqueda por código, intentamos encontrar la reserva
    if codigo_busqueda and reservas:
        for r in reservas:
            codigo_actual = (r.get("codigo_reserva") or "").strip()
            if codigo_actual.lower() == codigo_busqueda.lower():
                highlight_id = r.get("id_reserva")
                break

        if highlight_id is None:
            mensaje_busqueda = (
                f"No se encontró ninguna reserva con el código: {codigo_busqueda}"
            )

    # 5) Renderizar la plantilla con la lista de reservas + info de búsqueda
    return render_template(
        "mis_reservas.html",
        usuario=usuario,
        reservas=reservas,
        highlight_id=highlight_id,
        mensaje_busqueda=mensaje_busqueda,
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

        if cursor.rowcount == 0:
            flash(
                "No se pudo cancelar la reserva (no encontrada o no te pertenece).",
                "error",
            )
        else:
            flash("La reserva fue cancelada correctamente.", "success")

    except Exception as e:
        print("[ERROR] Al cancelar reserva:", e)
        conn.rollback()
        flash("Ocurrió un error al cancelar la reserva.", "error")
    finally:
        cursor.close()
        conn.close()

    # Siempre volvemos a la vista "Mis reservas"
    return redirect(url_for("mis_reservas.mis_reservas"))


# -----------------------------------------------------------------------------
# Ruta: POST /reservas/<int:id_reserva>/eliminar
# Responsabilidad:
#   - Soft delete: marcar la reserva como "no visible" para el usuario,
#     sin borrarla físicamente de la base de datos.
#   - Se usa cuando el usuario presiona el icono de tacho de basura
#     en el cuadro de "Mis reservas".
# -----------------------------------------------------------------------------
@mis_reservas_bp.route("/reservas/<int:id_reserva>/eliminar", methods=["POST"])
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

        if cursor.rowcount == 0:
            flash(
                "No se pudo eliminar la reserva del listado (no encontrada o no te pertenece).",
                "error",
            )
        else:
            flash("La reserva fue eliminada de tu listado.", "success")

    except Exception as e:
        print("[ERROR] Al hacer soft delete de reserva:", e)
        conn.rollback()
        flash("Ocurrió un error al eliminar la reserva del listado.", "error")
    finally:
        cursor.close()
        conn.close()

    return redirect(url_for("mis_reservas.mis_reservas"))
