# ---------------------------------------------------------------------
# Archivo: app/routes/reserva_routes.py
# Responsabilidad:
#   - Manejar búsquedas de habitaciones disponibles
# ---------------------------------------------------------------------

from flask import Blueprint, request, jsonify
from database.connection import get_connection

reserva_bp = Blueprint("reserva", __name__)


@reserva_bp.route("/buscar_habitaciones", methods=["POST"])
def buscar_habitaciones():
    data = request.get_json()

    fecha_inicio = data.get("fecha_inicio")
    fecha_fin = data.get("fecha_fin")
    pasajeros = data.get("pasajeros")

    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    # 1) Traemos todas las habitaciones que soporten la cantidad de huéspedes
    cursor.execute("""
        SELECT id_habitacion, nombre, descripcion, capacidad
        FROM habitacion
        WHERE capacidad >= %s
    """, (pasajeros,))

    habitaciones = cursor.fetchall()

    disponibles = []

    # 2) Filtramos por solapamiento de fechas
    for hab in habitaciones:
        cursor.execute("""
            SELECT COUNT(*) AS cant FROM reserva
            WHERE id_habitacion = %s
            AND (
                (fecha_inicio <= %s AND fecha_fin >= %s)
                OR
                (fecha_inicio <= %s AND fecha_fin >= %s)
                OR
                (%s <= fecha_inicio AND %s >= fecha_inicio)
            )
        """, (
            hab["id_habitacion"],
            fecha_inicio, fecha_inicio,
            fecha_fin, fecha_fin,
            fecha_inicio, fecha_fin
        ))

        ocupado = cursor.fetchone()["cant"]

        if ocupado == 0:
            # para ahora asignamos imágenes f1,f2,f3,f4 fijo:
            hab["imagen"] = "f1.jpg" if hab["id_habitacion"] == 1 else \
                            "f2.jpg" if hab["id_habitacion"] == 2 else \
                            "f3.jpg"
            disponibles.append(hab)

    cursor.close()
    conn.close()

    return jsonify({"ok": True, "habitaciones": disponibles})
