# -----------------------------------------------------------------------------
# Archivo: app/routes/auth_routes.py
# Responsabilidad:
#   - Manejar login, logout y registro de usuarios.
#   - Validar credenciales contra la BD.
#   - Crear sesiones de usuario.
# -----------------------------------------------------------------------------

from flask import Blueprint, render_template, request, redirect, url_for, session, flash
from database.connection import get_connection
from werkzeug.security import generate_password_hash, check_password_hash


auth_bp = Blueprint("auth", __name__, url_prefix="/auth")


# ------------ LOGIN (GET y POST) ------------
@auth_bp.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "GET":
        return render_template("login.html", usuario=None)

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

   
    if not check_password_hash(user["password_hash"], password):
        flash("Contraseña incorrecta.", "error")
        return redirect(url_for("auth.login"))

    session["usuario"] = {
        "id": user["id_usuario"],
        "nombre": user["nombre"],
        "apellido": user["apellido"],
        "email": user["email"]
    }

    return redirect(url_for("main.dashboard"))


# ------------ LOGOUT ------------
@auth_bp.route("/logout")
def logout():
    session.clear()
    return redirect(url_for("auth.login"))

# =================== RUTA SIGNUP (REGISTRO) ===================

@auth_bp.route('/signup', methods=['GET', 'POST'])
def signup():
    """
    Vista de registro de usuarios (huéspedes).
    - GET: muestra el formulario de registro.
    - POST: valida datos, crea usuario en BD y loguea al usuario.
    """
    if request.method == 'GET':
        return render_template('signup.html')

    # --- POST: procesar formulario ---
    nombre = request.form.get('nombre', '').strip()
    apellido = request.form.get('apellido', '').strip()
    email = request.form.get('email', '').strip().lower()
    telefono = request.form.get('telefono', '').strip()
    password = request.form.get('password', '')
    password_confirm = request.form.get('password_confirm', '')

    # Validaciones básicas del lado servidor
    errores = []

    if not nombre:
        errores.append("El nombre es obligatorio.")
    if not apellido:
        errores.append("El apellido es obligatorio.")
    if not email:
        errores.append("El email es obligatorio.")
    if not password:
        errores.append("La contraseña es obligatoria.")
    if password and len(password) < 6:
        errores.append("La contraseña debe tener al menos 6 caracteres.")
    if password != password_confirm:
        errores.append("Las contraseñas no coinciden.")

    if errores:
        for e in errores:
            flash(e, 'error')
        # Devolvemos el formulario con lo que el usuario ya escribió (excepto password)
        return render_template(
            'signup.html',
            form_data={
                "nombre": nombre,
                "apellido": apellido,
                "email": email,
                "telefono": telefono
            }
        )

    # Si las validaciones pasan, interactuamos con la BD
    cnx = get_connection()
    cursor = cnx.cursor(dictionary=True)

    try:
        # 1) Verificar que el email no exista
        cursor.execute(
            "SELECT id_usuario FROM usuario WHERE email = %s",
            (email,)
        )
        existente = cursor.fetchone()
        if existente:
            flash("Ya existe un usuario registrado con ese email.", "error")
            return render_template(
                'signup.html',
                form_data={
                    "nombre": nombre,
                    "apellido": apellido,
                    "email": email,
                    "telefono": telefono
                }
            )

        # 2) Obtener id_rol correspondiente al huésped
        cursor.execute(
            "SELECT id_rol FROM rol WHERE nombre = %s LIMIT 1",
            ("huesped",)
        )
        rol = cursor.fetchone()
        if not rol:
            flash("Error interno: no se encontró el rol 'huesped' en la base de datos.", "error")
            return render_template(
                'signup.html',
                form_data={
                    "nombre": nombre,
                    "apellido": apellido,
                    "email": email,
                    "telefono": telefono
                }
            )

        id_rol_huesped = rol["id_rol"]

        # 3) Insertar el nuevo usuario
        password_hash = generate_password_hash(password)

        insert_query = """
            INSERT INTO usuario (id_rol, nombre, apellido, email, password_hash, telefono, es_activo)
            VALUES (%s, %s, %s, %s, %s, %s, 1)
        """
        cursor.execute(
            insert_query,
            (id_rol_huesped, nombre, apellido, email, password_hash, telefono if telefono else None)
        )
        cnx.commit()

        nuevo_id = cursor.lastrowid

    except Exception as ex:
        cnx.rollback()
        print("Error en signup:", ex)
        flash("Ocurrió un error al registrar el usuario. Intenta nuevamente.", "error")
        return render_template(
            'signup.html',
            form_data={
                "nombre": nombre,
                "apellido": apellido,
                "email": email,
                "telefono": telefono
            }
        )
    finally:
        cursor.close()

    # 4) Loguear automáticamente al usuario recién creado
    session["usuario"] = {
    "id": nuevo_id,
    "nombre": nombre,
    "apellido": apellido,
    "email": email
}

    flash("Cuenta creada correctamente. ¡Bienvenido!", "success")
    return redirect(url_for('main.dashboard'))