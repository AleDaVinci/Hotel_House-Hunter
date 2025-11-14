# -----------------------------------------------------------------------------
# Archivo: database/connection.py
# Responsabilidad:
#   - Centralizar la lógica de conexión a la base de datos MySQL.
#   - Leer la configuración desde el archivo .env (variables de entorno).
#   - Proveer una función get_connection() para que la use la app Flask.
#
# Alcance:
#   - Este módulo NO sabe nada de Flask, solo maneja la conexión a la BD.
#   - Será utilizado por las rutas y servicios del backend.
# -----------------------------------------------------------------------------

import os
from dotenv import load_dotenv
import mysql.connector
from mysql.connector import Error

# Cargar variables de entorno definidas en el archivo .env
load_dotenv()


def get_connection():
    """
    Crea y devuelve una nueva conexión a la base de datos MySQL.

    Si ocurre un error al conectar, lanza la excepción para que
    sea manejada por la capa superior (por ejemplo, Flask).
    """
    try:
        connection = mysql.connector.connect(
            host=os.getenv("DB_HOST", "localhost"),
            port=os.getenv("DB_PORT", 3306),
            user=os.getenv("DB_USER"),
            password=os.getenv("DB_PASSWORD"),
            database=os.getenv("DB_NAME")
        )

        if connection.is_connected():
            return connection
        else:
            raise Exception("La conexión a MySQL no se pudo establecer.")

    except Error as e:
        # En desarrollo imprimimos el error para depurar
        print(f"[ERROR] No se pudo conectar a la BD: {e}")
        raise
