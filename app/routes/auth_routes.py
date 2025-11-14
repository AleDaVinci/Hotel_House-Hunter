# -----------------------------------------------------------------------------
# Archivo: app/routes/auth_routes.py
# Responsabilidad:
#   - Manejar login, logout y registro de usuarios.
#   - Validar credenciales contra la BD.
#   - Crear sesiones de usuario.
# -----------------------------------------------------------------------------

from flask import Blueprint, render_template, request, redirect, url_for, session, flash
from database.connection import get_connection
import hashlib

auth_bp = Blueprint("auth", __name__, url_prefix="/auth")


# ------------ FUNCIÓN UTIL: HASH DE CONTRASEÑAS ------------
def hash_password(password: str) -> str:
    return hashlib.sha256(password.encode()).hexdigest()


# ------------ LOGIN (GET y POST) ------------
@auth_bp.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "GET":
        return render_template("login.html", usuario=None)

    # POST - Procesar login
    email = request.form.get("email")
    password = request.form.get("password")

    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute(
        "SELECT * FROM usuario WHERE email = %s",
        (email,)
    )
    user = cursor.fetchone()

    cursor.close()
    conn.close()

    if not user:
        flash("Usuario no encontrado.", "error")
        return redirect(url_for("auth.login"))

    if user["password"] != hash_password(password):
        flash("Contraseña incorrecta.", "error")
        return redirect(url_for("auth.login"))

    # Guardar datos en sesión
    session["usuario"] = {
        "id": user["id_usuario"],
        "nombre": user["nombre"],
        "apellido": user["apellido"],
        "email": user["email"]
    }

    return redirect(url_for("main.dashboard"))  # Vista principal logueado


# ------------ LOGOUT ------------
@auth_bp.route("/logout")
def logout():
    session.clear()
    return redirect(url_for("auth.login"))
