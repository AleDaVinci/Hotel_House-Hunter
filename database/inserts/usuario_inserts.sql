-- ============================================================
-- Archivo  : usuario_inserts.sql
-- Tabla    : usuario
-- Objetivo : Crear un usuario administrador inicial para el sistema.
-- ============================================================

USE `hotel_hunter`;

INSERT INTO `usuario`
  (`id_rol`, `nombre`, `apellido`, `email`, `password_hash`, `telefono`, `es_activo`)
VALUES
  (
    (SELECT `id_rol` FROM `rol` WHERE `nombre` = 'administrador'),
    'Admin',
    'Sistema',
    'admin@admin.com',
    SHA2('admin', 256), 
    '+54 11 1234 5678',
    1
  );

