# -----------------------------------------------------------------------------
# Archivo: app.py
# Responsabilidad:
#   - Punto de entrada principal de la aplicación web.
#   - Crear la instancia de Flask.
#   - Registrar los blueprints de rutas.
#
# Alcance:
#   - En esta versión:
#       * Registra las rutas principales (landing/login/dashboard).
#       * Registra las rutas de autenticación.
#       * Registra las rutas de búsqueda de habitaciones / precios.
#       * Registra las rutas de "Mis reservas" (listado y cancelar).
#       * Configura una clave secreta para manejar sesiones.
# -----------------------------------------------------------------------------

from flask import Flask
from app.routes.main_routes import main_bp          # Rutas principales (landing, dashboard)
from app.routes.auth_routes import auth_bp          # Login / Logout
from app.routes.reserva_routes import reserva_bp    # Búsqueda de habitaciones / precios
from app.routes.mis_reservas_routes import mis_reservas_bp  # Vista "Mis reservas" cliente
from app.routes.modificar_reserva_routes import modificar_reserva_bp  # Modificar reservas existentes

# Crear instancia de la aplicación Flask
app = Flask(__name__)

# Clave secreta necesaria para usar 'session' (login, flash, etc.).
# En producción esto debe ser un valor complejo y secreto.
app.secret_key = "clave-super-secreta-cambiar-en-produccion"

# Registrar blueprints
app.register_blueprint(main_bp)
app.register_blueprint(auth_bp)
app.register_blueprint(reserva_bp)
app.register_blueprint(mis_reservas_bp)
app.register_blueprint(modificar_reserva_bp)



if __name__ == "__main__":
    # Ejecutar la app en modo debug para desarrollo local
    app.run(debug=True)
