# -----------------------------------------------------------------------------
# Archivo: app.py
# Responsabilidad:
#   - Punto de entrada principal de la aplicación web.
#   - Configurar y arrancar la app Flask.
#   - Definir las primeras rutas (endpoints) de prueba.
#
# Alcance:
#   - En esta primera versión solo tiene una ruta '/' que:
#       * Verifica que Flask funciona.
#       * Prueba la conexión a la base de datos MySQL.
#   - Más adelante aquí vamos a:
#       * Registrar las rutas de login/signup.
#       * Registrar las rutas de búsqueda y reservas.
#       * Renderizar los templates HTML (landing, mis reservas, etc.).
# -----------------------------------------------------------------------------

from flask import Flask
from database.connection import get_connection

app = Flask(__name__)


@app.route("/")
def home():
    """
    Ruta de prueba para verificar que:
      - Flask está corriendo correctamente.
      - La conexión a la base de datos funciona.
    """
    try:
        conn = get_connection()
        cursor = conn.cursor()

        # Consulta simple: listar tablas de la base
        cursor.execute("SHOW TABLES;")
        tables = cursor.fetchall()

        cursor.close()
        conn.close()

        # Mostrar resultado simple en el navegador
        return f"Flask OK. Conectado a la BD. Tablas: {tables}"

    except Exception as e:
        # Si algo sale mal, mostramos el error en el navegador
        return f"Error al conectar con la BD: {e}"


if __name__ == "__main__":
    # Ejecutar la app en modo debug para desarrollo local
    app.run(debug=True)
