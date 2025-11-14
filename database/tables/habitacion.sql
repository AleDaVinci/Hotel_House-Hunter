-- ============================================================
-- Archivo  : habitacion.sql
-- Tabla    : habitacion
-- Motor    : MySQL 8.0 (compatible con MySQL Workbench)
-- Proyecto : Sistema de reservas de hotel (MVP 2do parcial)
--
-- Responsabilidad:
--   Representa las habitaciones físicas del hotel que pueden
--   ser reservadas por los huéspedes.
--
-- Alcance:
--   - Información principal de cada habitación (nombre, código,
--     capacidad, descripción, tipo de cama).
--   - Referencia a una imagen principal de la habitación
--     (ruta de archivo estática en el proyecto Flask).
--   - Referencia a una tarifa base (FK a tabla "tarifa").
--   - La relación con amenities se modelará mediante una tabla
--     intermedia "habitacion_amenidad" (N:N), no con un FK directo.
-- ============================================================

-- DROP TABLE IF EXISTS `habitacion`;

CREATE TABLE IF NOT EXISTS `habitacion` (
  `id_habitacion` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador único de la habitación',

  `codigo` VARCHAR(20) NOT NULL COMMENT 'Código interno de la habitación (ej: STD-101, DLX-203)',
  `nombre` VARCHAR(100) NOT NULL COMMENT 'Nombre comercial de la habitación (ej: Doble Standard, Suite Deluxe)',

  `descripcion` VARCHAR(255) NOT NULL COMMENT 'Descripción breve de la habitación para mostrar en la web',

  `piso` VARCHAR(20) NULL COMMENT 'Piso o planta donde se encuentra (ej: 1, 2, 3, planta baja)',
  `numero` VARCHAR(10) NULL COMMENT 'Número de la habitación dentro del piso (ej: 101, 203B)',

  `capacidad_personas` SMALLINT UNSIGNED NOT NULL COMMENT 'Cantidad máxima de huéspedes que admite la habitación',

  `tipo_cama` VARCHAR(50) NULL COMMENT 'Tipo de cama principal (ej: Queen, King, Twin)',

  -- FK a la tabla de tarifas (precio por noche, políticas, etc.)
  `id_tarifa` INT UNSIGNED NOT NULL COMMENT 'Tarifa base asociada a la habitación (FK a tarifa.id_tarifa)',

  `imagen_principal` VARCHAR(255) NULL COMMENT 'Ruta a la imagen principal de la habitación (archivo estático en Flask)',

  `es_activa` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '1 = habitación visible y reservable, 0 = deshabilitada',

  `creado_en` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creación del registro',
  `actualizado_en` DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT 'Última fecha y hora de modificación',

  PRIMARY KEY (`id_habitacion`),

  -- Evita duplicar códigos de habitación
  UNIQUE KEY `uk_habitacion_codigo` (`codigo`),

  -- Índice para la foreign key de tarifa
  KEY `idx_habitacion_id_tarifa` (`id_tarifa`),

  CONSTRAINT `fk_habitacion_tarifa`
    FOREIGN KEY (`id_tarifa`)
    REFERENCES `tarifa` (`id_tarifa`)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE=InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci
  COMMENT = 'Habitaciones del hotel disponibles para reserva';
