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
    'scrypt:32768:8:1$UC9BKN1oHsp8mDYF$0976b1ef1d3056c00155b61580c3da669d15c17e694d06e8c2c74a4f8009a66ff1913a8a545b9ea3c7eb526315369e9fdb4d649b11cfc922dc2a6b32dc8ca758',
    '+54 11 1234 5678',
    1
  );

