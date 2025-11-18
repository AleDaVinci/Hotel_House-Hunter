# ---------------------------------------------------------------------------
# Archivo: tests/test_crear_reserva.py
# Responsabilidad:
#   - Probar el flujo de creación de una reserva mediante la ruta
#     POST /reservas/crear del blueprint "reserva".
#   - Verificar validaciones básicas y que se intente ejecutar un INSERT
#     en la tabla `reserva`.
#
# Alcance:
#   - Usa un cliente de pruebas de Flask (test_client).
#   - Mockea la función get_connection() para no depender de la BD real.
#   - Simula un usuario logueado usando la sesión de Flask.
# ---------------------------------------------------------------------------

import unittest
from unittest.mock import patch
from flask import Flask, Blueprint
from app.routes.reserva_routes import reserva_bp


class FakeCursor:
    """
    Cursor falso para simular ejecuciones contra la base de datos.

    Guarda la última query y parámetros con los que fue invocado.
    """

    def __init__(self):
        self.last_query = None
        self.last_params = None
        self.closed = False

    def execute(self, query, params=None):
        self.last_query = query
        self.last_params = params or ()

    def fetchone(self):
        return None

    def fetchall(self):
        return []

    def close(self):
        self.closed = True


class FakeConnection:
    """
    Conexión falsa para simular la conexión MySQL en los tests.

    Devuelve un FakeCursor y permite commit/rollback sin hacer nada real.
    """

    def __init__(self):
        self.cursor_obj = FakeCursor()
        self.committed = False
        self.rolled_back = False
        self.closed = False

    def cursor(self, dictionary=False):
        return self.cursor_obj

    def commit(self):
        self.committed = True

    def rollback(self):
        self.rolled_back = True

    def close(self):
        self.closed = True


class TestCrearReservaRoute(unittest.TestCase):
    """
    Pruebas unitarias para la ruta POST /reservas/crear.
    """

    def setUp(self):
        """
        Crea una app Flask mínima para registrar el blueprint de reservas
        y un blueprint dummy de 'mis_reservas' para que url_for funcione.
        """
        self.app = Flask(__name__)
        self.app.config["TESTING"] = True
        self.app.secret_key = "testing-secret-key"

        # Blueprint real que estamos testeando
        self.app.register_blueprint(reserva_bp)

        # Blueprint dummy para que url_for("mis_reservas.mis_reservas") no falle
        mis_reservas_bp = Blueprint("mis_reservas", __name__)

        @mis_reservas_bp.route("/mis-reservas")
        def mis_reservas():
            return "OK"

        self.app.register_blueprint(mis_reservas_bp)

        self.client = self.app.test_client()

    @patch("app.routes.reserva_routes.get_connection")
    def test_crear_reserva_exito(self, mock_get_connection):
        """
        Caso feliz:
        - Usuario logueado en la sesión.
        - Datos completos y válidos.
        - Se espera respuesta 201 y ok=True.
        - Se espera que se haya ejecutado un INSERT en la tabla reserva.
        """
        # 1) Preparar fake connection que va a usar la ruta
        fake_conn = FakeConnection()
        mock_get_connection.return_value = fake_conn

        # 2) Simular un usuario logueado en la sesión
        with self.client.session_transaction() as sess:
            sess["usuario"] = {
                "id": 99,
                "nombre": "Usuario Test",
                "email": "test@example.com",
            }

        # 3) Construir el payload JSON válido
        payload = {
            "id_habitacion": 1,
            "id_tarifa": 1,
            "id_promocion": None,
            "fecha_check_in": "2025-11-20",
            "fecha_check_out": "2025-11-22",
            "cantidad_huespedes": 2,
            "noches": 2,
            "monto_total": 123456.78,
        }

        # 4) Hacer la petición POST a la ruta /reservas/crear
        response = self.client.post(
            "/reservas/crear",
            json=payload,
        )

        # 5) Validar respuesta HTTP
        self.assertEqual(
            response.status_code,
            201,
            f"Se esperaba status 201 al crear una reserva, se obtuvo {response.status_code}",
        )

        data = response.get_json()
        self.assertIsNotNone(data, "La respuesta debería contener JSON.")

        self.assertTrue(
            data.get("ok"),
            "Se esperaba ok=True en la respuesta al crear una reserva.",
        )
        self.assertIn(
            "redirect_url",
            data,
            "La respuesta debería incluir redirect_url hacia Mis reservas.",
        )

        # 6) Verificar que se haya ejecutado un INSERT en la tabla reserva
        last_query = fake_conn.cursor_obj.last_query
        self.assertIsNotNone(
            last_query,
            "No se ejecutó ninguna query sobre la BD en crear_reserva.",
        )
        self.assertIn(
            "INSERT INTO reserva",
            last_query,
            "Se esperaba que la query ejecutada fuera un INSERT en la tabla `reserva`.",
        )

        # 7) Verificar que se haya llamado a commit()
        self.assertTrue(
            fake_conn.committed,
            "Se esperaba que la conexión hiciera commit() tras crear la reserva.",
        )


if __name__ == "__main__":
    unittest.main()
