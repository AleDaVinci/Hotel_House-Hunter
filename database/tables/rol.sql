-- ============================================================
-- Archivo  : rol.sql
-- Tabla    : rol
-- Motor    : MySQL 8.0 (compatible con MySQL Workbench)
-- Proyecto : Sistema de reservas de hotel (MVP 2do parcial)
--
-- Responsabilidad:
--   Esta tabla define los diferentes roles de usuario que
--   pueden operar dentro del sistema hotelero:
--   - administrador
--   - recepcionista
--   - huesped
--   - personal_de_limpieza
--
-- Alcance:
--   - Catálogo pequeño y estático de roles.
--   - Es referenciada por la tabla "usuario" para indicar
--     qué tipo de permisos/tareas puede realizar cada usuario.
--   - Incluye campos de auditoría básicos (creado_en, actualizado_en)
--     para saber cuándo se creó/modificó cada rol.
-- ============================================================

-- DROP TABLE IF EXISTS `rol`;

CREATE TABLE IF NOT EXISTS `rol` (
  `id_rol` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador único del rol',
  `nombre` VARCHAR(50) NOT NULL COMMENT 'Nombre corto del rol (administrador, recepcionista, etc.)',
  `descripcion` VARCHAR(255) NULL COMMENT 'Descripción funcional del rol dentro del sistema hotelero',
  `es_activo` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '1 = rol activo, 0 = rol deshabilitado',
  `creado_en` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de alta del registro',
  `actualizado_en` DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT 'Última fecha y hora de modificación',
  PRIMARY KEY (`id_rol`),
  UNIQUE KEY `uk_rol_nombre` (`nombre`)
) ENGINE=InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci
  COMMENT = 'Catálogo de roles de usuario del sistema de reservas de hotel';
