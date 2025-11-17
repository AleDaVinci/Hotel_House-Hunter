# -----------------------------------------------------------------------------
# Archivo: app/routes/main_routes.py
# Responsabilidad:
#   - Definir las rutas principales (públicas) de la aplicación:
#       * Landing / Login (ruta "/")
#       * Otras vistas públicas en el futuro (contacto, etc.).
#
# Alcance:
#   - Por ahora solo maneja la ruta raíz "/".
# -----------------------------------------------------------------------------

from flask import Blueprint, render_template, session
from flask import Blueprint, render_template, session, redirect, url_for

# Creamos un Blueprint para agrupar estas rutas bajo el nombre "main"
main_bp = Blueprint("main", __name__)


@main_bp.route("/")
def landing_login():
    """
    Ruta principal de la aplicación.
    Muestra la landing con el formulario de login centrado sobre
    un fondo con imagen, siguiendo el diseño de Figma.
    """
    # En el futuro, cuando tengamos login real, aquí leeremos datos
    # del usuario desde 'session'. Por ahora solo renderizamos HTML.
    usuario = session.get("usuario")  # dict con nombre/apellido, si existiera

    return render_template("login.html", usuario=usuario)

@main_bp.route("/dashboard")
def dashboard():
    usuario = session.get("usuario")
    if not usuario:
        return redirect(url_for("auth.login"))

    return render_template("dashboard.html", usuario=usuario)

