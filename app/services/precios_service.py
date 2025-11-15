# ---------------------------------------------------------------------
# Archivo: app/services/precios_service.py
# Responsabilidad:
#   - Calcular opciones de precio para una búsqueda:
#       * Tarifas activas (reembolsable / no reembolsable)
#       * Promociones vigentes para el rango de fechas
#       * Precio final por noche (con o sin promo)
#   - Adjuntar esas opciones de tarifa a cada habitación disponible.
# ---------------------------------------------------------------------

from datetime import date
from database.connection import get_connection


def calcular_opciones_tarifa(fecha_inicio: date, fecha_fin: date):
    """
    Devuelve:
      - lista de dicts con tarifas + promo aplicada (si corresponde)
      - cantidad de noches del rango buscado
    """
    noches = (fecha_fin - fecha_inicio).days

    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    # 1) Traer todas las tarifas activas
    cursor.execute("SELECT * FROM tarifa WHERE es_activa = 1")
    tarifas = cursor.fetchall()

    # 2) Traer promociones activas que se crucen con el rango de fechas
    cursor.execute(
        """
        SELECT *
        FROM promocion
        WHERE es_activa = 1
          AND fecha_desde <= %s
          AND fecha_hasta >= %s
        """,
        (fecha_fin, fecha_inicio),
    )
    promos_raw = cursor.fetchall()

    cursor.close()
    conn.close()

    # Agrupamos promos por tarifa
    promos_por_tarifa = {}
    for p in promos_raw:
        promos_por_tarifa.setdefault(p["id_tarifa"], []).append(p)

    opciones = []

    for t in tarifas:
        base_noche = float(t["monto_noche"])
        mejor_promo = None
        precio_noche_final = base_noche

        promos_t = promos_por_tarifa.get(t["id_tarifa"], [])

        for promo in promos_t:
            noches_min = promo["noches_minimas"]
            if noches_min is not None and noches < noches_min:
                continue  # no cumple noches mínimas, sigo con otra promo

            porc = float(promo["porcentaje_descuento"])
            precio_con_desc = base_noche * (1 - porc / 100.0)

            # Me quedo con la promo de mayor porcentaje
            if (
                mejor_promo is None
                or porc > float(mejor_promo["porcentaje_descuento"])
            ):
                mejor_promo = promo
                precio_noche_final = precio_con_desc

        opciones.append(
            {
                "id_tarifa": t["id_tarifa"],
                "nombre": t["nombre"],
                "es_reembolsable": bool(t["es_reembolsable"]),
                "monto_noche": base_noche,
                "precio_noche_final": precio_noche_final,
                "promo_aplicada": mejor_promo,
            }
        )

    return opciones, noches


def adjuntar_precios_a_habitaciones(habitaciones, opciones_tarifa, noches: int):
    """
    A cada dict de habitación le agrega una clave 'tarifas' con
    la lista de opciones de tarifa + totales calculados.
    """
    for hab in habitaciones:
        hab["tarifas"] = []

        for opt in opciones_tarifa:
            total_base = opt["monto_noche"] * noches
            total_final = opt["precio_noche_final"] * noches

            hab["tarifas"].append(
                {
                    "id_tarifa": opt["id_tarifa"],
                    "nombre": opt["nombre"],
                    "es_reembolsable": opt["es_reembolsable"],
                    "monto_noche": opt["monto_noche"],
                    "precio_noche_final": opt["precio_noche_final"],
                    "total_base": total_base,
                    "total_final": total_final,
                    "promo_aplicada": opt["promo_aplicada"],
                }
            )

    return habitaciones
