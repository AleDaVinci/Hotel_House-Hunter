-- ============================================================
-- Archivo  : install_all.sql
-- Proyecto : Sistema de reservas de hotel (MVP 2do parcial)
-- Objetivo : Crear la base de datos completa + cargar datos iniciales
--
-- Requisitos:
--   - Tener el servicio MySQL levantado (XAMPP u otro).
--   - Tener el cliente "mysql" disponible en consola.
--   - Ejecutar este archivo desde la carpeta /database o referenciar
--     la ruta correctamente (ver README).
--
-- Uso recomendado (desde la raíz del proyecto):
--   Get-Content database/install_BD.sql | & "C:\xampp\mysql\bin\mysql.exe" -u root
--
-- Este script:
--   1) Ejecuta schema.sql  -> crea la BD hotel_hunter y todas las tablas.
--   2) Ejecuta seed.sql    -> inserta datos iniciales usando ./inserts/*.sql
-- ============================================================
SET NAMES utf8mb4;
-- 1) Crear/Recrear la base de datos y todas las tablas
SOURCE ./database/schema.sql;

-- 2) Cargar datos iniciales (roles, usuarios, tarifas, promos, amenities, habitaciones, relaciones)
SOURCE ./database/seed.sql;

-- Fin del instalador de BD
