# -----------------------------------------------------------------------------
# Archivo: app.py
# Responsabilidad:
#   - Punto de entrada principal de la aplicación web.
#   - Crear la instancia de Flask.
#   - Registrar los blueprints de rutas.
#
# Alcance:
#   - En esta versión inicial:
#       * Registra las rutas principales (landing/login).
#       * Configura una clave secreta para manejar sesiones.
# -----------------------------------------------------------------------------

from flask import Flask
from app.routes.main_routes import main_bp  # importamos el blueprint "main"
from app.routes.auth_routes import auth_bp

# Crear instancia de la aplicación Flask
app = Flask(__name__)

# Clave secreta necesaria para usar 'session' (login, flash, etc.)
# En producción esto debe ser un valor complejo y secreto.
app.secret_key = "clave-super-secreta-cambiar-en-produccion"

# Registrar el blueprint con las rutas principales
app.register_blueprint(main_bp)
app.register_blueprint(auth_bp)


if __name__ == "__main__":
    # Ejecutar la app en modo debug para desarrollo local
    app.run(debug=True)
