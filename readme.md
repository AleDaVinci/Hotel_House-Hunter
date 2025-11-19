# Hotel House Hunter – Módulo Cliente

Este repositorio contiene el módulo cliente de la aplicación web del hotel House Hunter.
Desde esta interfaz el cliente podrá registrarse, buscar habitaciones, crear reservas, modificarlas o cancelarlas, ver sus reservas y acceder a información del hotel.

Este README explica cómo levantar el proyecto desde cero, incluso sin tener Python ni Flask instalados.

------------------------------------------------------------
INSTALACIÓN INICIAL (PC SIN PYTHON NI FLASK)
------------------------------------------------------------

1. INSTALAR PYTHON
   - Ir a https://www.python.org/downloads/
   - Descargar versión 3.10 o superior.
   - Activar “Add Python to PATH”.
   - Verificar instalación:
     python --version

2. INSTALAR GIT
   - Descargar desde https://git-scm.com/downloads
   - Verificar instalación:
     git --version

------------------------------------------------------------
CLONAR EL REPOSITORIO
------------------------------------------------------------

git clone https://github.com/AleDaVinci/Hotel_House-Hunter.git
cd Hotel_House-Hunter
git checkout modulo-cliente

Abrir VS Code:
code .

------------------------------------------------------------
CREAR Y ACTIVAR ENTORNO VIRTUAL (venv)
------------------------------------------------------------

(Instalar virtualenv si fuera necesario)
pip install virtualenv

Crear entorno:
python -m venv venv

Activar entorno:

PowerShell:
.
env\Scripts\Activate.ps1

CMD:
venv\Scripts\activate

Linux/Mac:
source venv/bin/activate

------------------------------------------------------------
INSTALAR DEPENDENCIAS (FLASK, DOTENV, MYSQL CONNECTOR)
------------------------------------------------------------

Con requirements.txt:
pip install -r requirements.txt

Manual:
pip install flask
pip install python-dotenv
pip install mysql-connector-python

------------------------------------------------------------
CONFIGURAR BASE DE DATOS MYSQL
------------------------------------------------------------

Revisar documento:
Documentacion-Base-De-Datos

Incluye instrucciones para:
- Crear BD
- Ejecutar install_BD.sql
- Usar PowerShell o CMD
- Usar MySQL de XAMPP o instalación oficial

Ejemplo PowerShell (XAMPP):
Get-Content ./database/install_BD.sql | & "C:\xampp\mysql\bin\mysql.exe" -u root

------------------------------------------------------------
ARCHIVO .ENV (si aplica)
------------------------------------------------------------

DB_HOST=localhost
DB_USER=root
DB_PASSWORD=
DB_NAME=hotel_house_hunter
FLASK_ENV=development

------------------------------------------------------------
EJECUTAR LA APLICACIÓN
------------------------------------------------------------

python app.py

Acceder desde el navegador:
http://127.0.0.1:5000/

------------------------------------------------------------
FUNCIONALIDADES DEL MÓDULO CLIENTE
------------------------------------------------------------

- Registro e inicio de sesión
- Búsqueda de habitaciones por fecha y huéspedes
- Crear reservas
- Modificar o cancelar reservas
- Panel “Mis Reservas” con estado, fechas e importe
- Fotos, descripción, servicios y contacto del hotel

------------------------------------------------------------
NOTAS FINALES
------------------------------------------------------------

- Este módulo es el MVP del cliente web.
- No incluye panel administrativo.
