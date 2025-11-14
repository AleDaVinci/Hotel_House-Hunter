-- ============================================================
-- Archivo  : reserva.sql
-- Tabla    : reserva
-- Motor    : MySQL 8.0 (compatible con MySQL Workbench)
-- Proyecto : Sistema de reservas de hotel (MVP 2do parcial)
--
-- Responsabilidad:
--   Representa las reservas realizadas por los huéspedes
--   sobre las habitaciones del hotel.
--
-- Alcance:
--   - Guarda la relación entre:
--       * usuario (huésped)
--       * habitación
--       * tarifa aplicada
--       * promoción aplicada (opcional)
--   - Almacena fechas de check-in / check-out.
--   - Registra la cantidad de huéspedes.
--   - Registra el importe total calculado en el momento de la reserva.
--   - Mantiene un estado de la reserva (pendiente, confirmada, cancelada, finalizada).
--
-- ============================================================

-- DROP TABLE IF EXISTS `reserva`; 

CREATE TABLE IF NOT EXISTS `reserva` (
  `id_reserva` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador único de la reserva',

  `codigo_reserva` VARCHAR(20) NOT NULL COMMENT 'Código visible para el cliente (ej: ABC123, H2024-0001)',

  `id_usuario` INT UNSIGNED NOT NULL COMMENT 'Usuario que realizó la reserva (FK a usuario.id_usuario)',
  `id_habitacion` INT UNSIGNED NOT NULL COMMENT 'Habitación reservada (FK a habitacion.id_habitacion)',

  `id_tarifa` INT UNSIGNED NOT NULL COMMENT 'Tarifa aplicada en el momento de la reserva (FK a tarifa.id_tarifa)',
  `id_promocion` INT UNSIGNED NULL COMMENT 'Promoción aplicada (si corresponde, FK a promocion.id_promocion)',

  `fecha_check_in` DATE NOT NULL COMMENT 'Fecha de ingreso (check-in) del huésped',
  `fecha_check_out` DATE NOT NULL COMMENT 'Fecha de salida (check-out) del huésped',

  `cantidad_huespedes` SMALLINT UNSIGNED NOT NULL COMMENT 'Cantidad de huéspedes incluidos en la reserva',

  -- Estados sugeridos:
  --   pendiente   = creada, en proceso de pago/confirmación
  --   confirmada  = reserva confirmada
  --   cancelada   = anulada por el usuario o el hotel
  --   finalizada  = estadía completada
  `estado` VARCHAR(20) NOT NULL DEFAULT 'pendiente' COMMENT 'Estado actual de la reserva',

  `monto_total` DECIMAL(10,2) NOT NULL COMMENT 'Importe total calculado para toda la estadía (n noches)',

  `creado_en` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creación de la reserva',
  `actualizado_en` DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT 'Última fecha y hora de modificación',

  PRIMARY KEY (`id_reserva`),

  -- Cada código de reserva debe ser único
  UNIQUE KEY `uk_reserva_codigo` (`codigo_reserva`),

  -- Índices para foreign keys
  KEY `idx_reserva_id_usuario` (`id_usuario`),
  KEY `idx_reserva_id_habitacion` (`id_habitacion`),
  KEY `idx_reserva_id_tarifa` (`id_tarifa`),
  KEY `idx_reserva_id_promocion` (`id_promocion`),

  CONSTRAINT `fk_reserva_usuario`
    FOREIGN KEY (`id_usuario`)
    REFERENCES `usuario` (`id_usuario`)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,

  CONSTRAINT `fk_reserva_habitacion`
    FOREIGN KEY (`id_habitacion`)
    REFERENCES `habitacion` (`id_habitacion`)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,

  CONSTRAINT `fk_reserva_tarifa`
    FOREIGN KEY (`id_tarifa`)
    REFERENCES `tarifa` (`id_tarifa`)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,

  CONSTRAINT `fk_reserva_promocion`
    FOREIGN KEY (`id_promocion`)
    REFERENCES `promocion` (`id_promocion`)
    ON UPDATE CASCADE
    ON DELETE SET NULL,

  -- Validaciones básicas (MySQL 8.0 ya soporta CHECK)
  CONSTRAINT `chk_reserva_fechas`
    CHECK (`fecha_check_out` > `fecha_check_in`),

  CONSTRAINT `chk_reserva_cantidad_huespedes`
    CHECK (`cantidad_huespedes` > 0),

  CONSTRAINT `chk_reserva_estado`
    CHECK (`estado` IN ('pendiente','confirmada','cancelada','finalizada'))
) ENGINE=InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci
  COMMENT = 'Reservas de habitaciones realizadas por los usuarios del sistema';
