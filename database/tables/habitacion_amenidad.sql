-- ============================================================
-- Archivo  : habitacion_amenidad.sql
-- Tabla    : habitacion_amenidad
-- Motor    : MySQL 8.0 (compatible con MySQL Workbench)
-- Proyecto : Sistema de reservas de hotel (MVP 2do parcial)
--
-- Responsabilidad:
--   Modelar la relación muchos a muchos (N:N) entre:
--     - habitacion
--     - amenidad
--
-- Alcance:
--   - Cada fila indica que una determinada habitación
--     ofrece un determinado amenity.
--   - No almacena información adicional compleja, solo
--     las claves foráneas y campos de auditoría básicos.
-- ============================================================

-- Nota:
-- Esta tabla depende de:
--   - habitacion (id_habitacion)
--   - amenidad (id_amenidad)
-- Deben existir antes de crear esta tabla.
--
-- DROP TABLE IF EXISTS `habitacion_amenidad`;  -- (usar solo en pruebas)

CREATE TABLE IF NOT EXISTS `habitacion_amenidad` (
  `id_habitacion` INT UNSIGNED NOT NULL COMMENT 'FK a habitacion.id_habitacion',
  `id_amenidad` INT UNSIGNED NOT NULL COMMENT 'FK a amenidad.id_amenidad',

  `creado_en` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creación del vínculo',

  -- Clave primaria compuesta para evitar duplicados
  PRIMARY KEY (`id_habitacion`, `id_amenidad`),

  -- Índices para optimizar búsquedas por cada lado
  KEY `idx_hab_amen_id_amenidad` (`id_amenidad`),

  CONSTRAINT `fk_hab_amen_habitacion`
    FOREIGN KEY (`id_habitacion`)
    REFERENCES `habitacion` (`id_habitacion`)
    ON UPDATE CASCADE
    ON DELETE CASCADE,

  CONSTRAINT `fk_hab_amen_amenidad`
    FOREIGN KEY (`id_amenidad`)
    REFERENCES `amenidad` (`id_amenidad`)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE=InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci
  COMMENT = 'Relación N:N entre habitaciones del hotel y sus amenities';
