-- ============================================================
-- Archivo  : tarifa.sql
-- Tabla    : tarifa
-- Motor    : MySQL 8.0 (compatible con MySQL Workbench)
-- Proyecto : Sistema de reservas de hotel (MVP 2do parcial)
--
-- Responsabilidad:
--   Define las tarifas base que se pueden asociar a una o
--   varias habitaciones del hotel.
--
-- Alcance:
--   - Monto base por noche.
--   - Información sobre reembolsabilidad.
--   - Fechas de vigencia (opcional).
--   - Noches mínimas (opcional).
--   - Esta tabla es referenciada por "habitacion.id_tarifa".
--
--   NOTA:
--   Los descuentos o reglas especiales (promociones) se
--   manejarán en una tabla aparte (promocion), y la lógica
--   de cálculo final se resolverá en el backend.
-- ============================================================

-- DROP TABLE IF EXISTS `tarifa`;

CREATE TABLE IF NOT EXISTS `tarifa` (
  `id_tarifa` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador único de la tarifa',

  `nombre` VARCHAR(100) NOT NULL COMMENT 'Nombre de la tarifa (ej: Base Standard, No Reembolsable, Temporada Alta)',
  `descripcion` VARCHAR(255) NULL COMMENT 'Descripción breve de las condiciones de la tarifa',

  `monto_noche` DECIMAL(10,2) NOT NULL COMMENT 'Monto base por noche asociado a esta tarifa',
  `moneda` CHAR(3) NOT NULL DEFAULT 'ARS' COMMENT 'Código de moneda ISO 4217 (ej: ARS, USD)',

  `es_reembolsable` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '1 = tarifa reembolsable, 0 = no reembolsable',
  `noches_minimas` SMALLINT UNSIGNED NULL COMMENT 'Cantidad mínima de noches para aplicar esta tarifa (NULL si no aplica)',

  `fecha_desde` DATE NULL COMMENT 'Fecha de inicio de vigencia de la tarifa (NULL = sin límite inferior)',
  `fecha_hasta` DATE NULL COMMENT 'Fecha de fin de vigencia de la tarifa (NULL = sin límite superior)',

  `es_activa` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '1 = tarifa vigente/usable, 0 = deshabilitada',

  `creado_en` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creación del registro',
  `actualizado_en` DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT 'Última fecha y hora de modificación',

  PRIMARY KEY (`id_tarifa`),

  UNIQUE KEY `uk_tarifa_nombre` (`nombre`)
) ENGINE=InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci
  COMMENT = 'Tarifas base por noche que se asignan a las habitaciones del hotel';
