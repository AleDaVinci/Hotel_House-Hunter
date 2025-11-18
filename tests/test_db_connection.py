# ---------------------------------------------------------------------------
# Archivo: tests/test_db_connection.py
# Responsabilidad:
#   - Verificar que la función get_connection() establece una conexión
#     válida contra la base de datos MySQL.
#   - Ejecutar un SELECT 1 simple para comprobar que la BD responde.
#
# Alcance:
#   - Usa la misma configuración (.env) que la aplicación Flask.
#   - No modifica datos, solo lee (consulta de prueba).
# ---------------------------------------------------------------------------

import unittest
from mysql.connector import Error
from database.connection import get_connection


class TestDBConnection(unittest.TestCase):
    """
    Pruebas unitarias básicas para la conexión a la base de datos.
    """

    def test_get_connection_and_select_1(self):
        """
        Verifica que:
        - get_connection() devuelve una conexión válida.
        - La conexión está marcada como 'conectada'.
        - Se puede ejecutar un SELECT 1 sin errores.
        """
        connection = None

        try:
            # Intentar obtener la conexión usando la función del proyecto
            connection = get_connection()

            # La conexión no debe ser None
            self.assertIsNotNone(
                connection,
                "get_connection() devolvió None, se esperaba una conexión válida."
            )

            # La conexión debe estar marcada como conectada
            self.assertTrue(
                connection.is_connected(),
                "La conexión a MySQL debería estar activa (is_connected() == True)."
            )

            # Ejecutar un SELECT 1 simple
            cursor = connection.cursor()
            cursor.execute("SELECT 1")
            result = cursor.fetchone()

            # Debe devolver al menos una fila y el valor 1
            self.assertIsNotNone(result, "SELECT 1 no devolvió ninguna fila.")
            self.assertEqual(result[0], 1, "El resultado de SELECT 1 debería ser 1.")

        except Error as e:
            self.fail(f"No se pudo conectar a la BD o ejecutar SELECT 1: {e}")

        finally:
            # Cerrar la conexión si está abierta
            if connection is not None and connection.is_connected():
                connection.close()


if __name__ == "__main__":
    unittest.main()
