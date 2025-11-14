-- ============================================================
-- Archivo  : usuario.sql
-- Tabla    : usuario
-- Motor    : MySQL 8.0 (compatible con MySQL Workbench)
-- Proyecto : Sistema de reservas de hotel (MVP 2do parcial)
--
-- Responsabilidad:
--   Almacena los datos de los usuarios del sistema hotelero:
--   - huéspedes (clientes que reservan desde la web)
--   - administradores
--   - recepcionistas
--   - personal interno del hotel
--
-- Alcance:
--   - Gestionar credenciales de acceso (email + password hash).
--   - Relacionar cada usuario con un rol (FK a tabla "rol").
--   - Guardar información básica de contacto.
--   - Incluir campos de auditoría (creado_en, actualizado_en)
--     y un flag es_activo para habilitar/deshabilitar usuarios.
-- ============================================================
-- DROP TABLE IF EXISTS `usuario`;

CREATE TABLE IF NOT EXISTS `usuario` (
  `id_usuario` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador único del usuario',
  
  `id_rol` INT UNSIGNED NOT NULL COMMENT 'Rol asociado al usuario (FK a rol.id_rol)',
  
  `nombre` VARCHAR(100) NOT NULL COMMENT 'Nombre del usuario',
  `apellido` VARCHAR(100) NOT NULL COMMENT 'Apellido del usuario',
  
  `email` VARCHAR(150) NOT NULL COMMENT 'Correo electrónico único del usuario, usado para login',
  `password_hash` VARCHAR(255) NOT NULL COMMENT 'Contraseña encriptada/hasheada del usuario',
  
  `telefono` VARCHAR(30) NULL COMMENT 'Teléfono de contacto del usuario',
  
  `es_activo` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '1 = usuario activo, 0 = usuario deshabilitado',
  
  `creado_en` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creación del usuario',
  `actualizado_en` DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT 'Última fecha y hora de modificación',

  PRIMARY KEY (`id_usuario`),

  -- Cada email debe ser único para evitar duplicidad de cuentas
  UNIQUE KEY `uk_usuario_email` (`email`),

  -- Índice para la foreign key de rol
  KEY `idx_usuario_id_rol` (`id_rol`),

  CONSTRAINT `fk_usuario_rol`
    FOREIGN KEY (`id_rol`)
    REFERENCES `rol` (`id_rol`)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE=InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci
  COMMENT = 'Usuarios del sistema de reservas de hotel (internos y huéspedes)';
