-- ============================================================
-- Archivo  : promocion.sql
-- Tabla    : promocion
-- Motor    : MySQL 8.0 (compatible con MySQL Workbench)
-- Proyecto : Sistema de reservas de hotel (MVP 2do parcial)
--
-- Responsabilidad:
--   Define promociones/descuentos que se aplican sobre una
--   tarifa base para reducir el precio por noche.
--
-- Alcance:
--   - Porcentaje de descuento sobre la tarifa.
--   - Fechas de vigencia de la promoción.
--   - Condiciones simples como noches mínimas.
--   - Relación con la tabla "tarifa" (FK id_tarifa).
--
--   NOTA:
--   La lógica para aplicar la mejor promoción y combinarla con
--   la tarifa se resolverá en el backend (Python/Flask).
-- ============================================================

-- DROP TABLE IF EXISTS `promocion`;

CREATE TABLE IF NOT EXISTS `promocion` (
  `id_promocion` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador único de la promoción',

  `id_tarifa` INT UNSIGNED NOT NULL COMMENT 'Tarifa sobre la cual se aplica la promoción (FK a tarifa.id_tarifa)',

  `nombre` VARCHAR(100) NOT NULL COMMENT 'Nombre de la promoción (ej: Promo Verano 10%, Black Friday)',
  `descripcion` VARCHAR(255) NULL COMMENT 'Descripción breve de las condiciones de la promoción',

  -- Descuento expresado en porcentaje.
  -- Ejemplos: 10.00 = 10%, 25.50 = 25,5%
  `porcentaje_descuento` DECIMAL(5,2) NOT NULL COMMENT 'Porcentaje de descuento sobre la tarifa base (0 - 100)',

  `noches_minimas` SMALLINT UNSIGNED NULL COMMENT 'Cantidad mínima de noches para aplicar la promo (NULL si no aplica)',

  `fecha_desde` DATE NOT NULL COMMENT 'Fecha de inicio de vigencia de la promoción',
  `fecha_hasta` DATE NOT NULL COMMENT 'Fecha de fin de vigencia de la promoción',

  `es_activa` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '1 = promoción activa/usable, 0 = deshabilitada',

  `creado_en` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creación del registro',
  `actualizado_en` DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT 'Última fecha y hora de modificación',

  PRIMARY KEY (`id_promocion`),

  -- Índice para la foreign key de tarifa
  KEY `idx_promocion_id_tarifa` (`id_tarifa`),

  CONSTRAINT `fk_promocion_tarifa`
    FOREIGN KEY (`id_tarifa`)
    REFERENCES `tarifa` (`id_tarifa`)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,

  -- Check para evitar valores de porcentaje fuera de rango lógico
  CONSTRAINT `chk_promocion_porcentaje_descuento`
    CHECK (`porcentaje_descuento` >= 0.00 AND `porcentaje_descuento` <= 100.00)
) ENGINE=InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci
  COMMENT = 'Promociones de descuento aplicadas sobre tarifas base';
