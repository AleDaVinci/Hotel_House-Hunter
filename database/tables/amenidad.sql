-- ============================================================
-- Archivo  : amenidad.sql
-- Tabla    : amenidad
-- Motor    : MySQL 8.0 (compatible con MySQL Workbench)
-- Proyecto : Sistema de reservas de hotel (MVP 2do parcial)
--
-- Responsabilidad:
--   Catálogo general de amenities disponibles en el hotel
--   (ej: WiFi, TV, Aire Acondicionado, Caja Fuerte, Frigobar).
--
-- Alcance:
--   - Tabla simple de catálogo.
--   - Será usada por la tabla intermedia "habitacion_amenidad"
--     para relacionar amenities con habitaciones (N:N).
--   - Solo contiene nombre, icono y descripción.
-- ============================================================

-- DROP TABLE IF EXISTS `amenidad`;  -- (usar solo en pruebas)

CREATE TABLE IF NOT EXISTS `amenidad` (
  `id_amenidad` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador único del amenity',

  `nombre` VARCHAR(100) NOT NULL COMMENT 'Nombre del amenity (ej: WiFi, TV, Aire acondicionado)',
  `descripcion` VARCHAR(255) NULL COMMENT 'Descripción breve del servicio o característica',
  
  `icono` VARCHAR(150) NULL COMMENT 'Ruta a un icono opcional para mostrar en la web (static/img/icons)',

  `es_activa` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '1 = amenity disponible, 0 = amenity deshabilitado',

  `creado_en` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creación del registro',
  `actualizado_en` DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT 'Última fecha y hora de modificación',

  PRIMARY KEY (`id_amenidad`),

  UNIQUE KEY `uk_amenidad_nombre` (`nombre`)
) ENGINE=InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci
  COMMENT = 'Catálogo de amenities disponibles en el hotel';
