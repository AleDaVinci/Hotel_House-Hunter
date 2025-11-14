-- ============================================================
-- Archivo  : schema.sql
-- Proyecto : Sistema de reservas de hotel (MVP 2do parcial)
-- Motor    : MySQL 8.0 (MySQL Workbench + XAMPP)
--
-- Responsabilidad:
--   - Crear el schema (base de datos) completo del sistema.
--   - Definir todas las tablas en el orden correcto para que
--     las FOREIGN KEY no fallen.
--   - No carga datos (no INSERTs), solo DDL (estructura).
--
-- Instrucciones rápidas (MySQL Workbench):
--   1) Abrir MySQL Workbench.
--   2) Conectarse al servidor MySQL de XAMPP (localhost, root, etc.).
--   3) Abrir este archivo schema.sql.
--   4) Ejecutar todo el script.
-- ============================================================

-- ============================================================
-- 1) Crear schema (base de datos)
-- ============================================================
DROP DATABASE IF EXISTS `hotel_hunter`;
CREATE DATABASE `hotel_hunter`
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE `hotel_hunter`;

-- ============================================================
-- Opcional: desactivar checks de FK durante recreación
-- ============================================================
SET @OLD_FOREIGN_KEY_CHECKS = @@FOREIGN_KEY_CHECKS;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- 2) Tabla: rol
-- ============================================================
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

-- ============================================================
-- 3) Tabla: usuario
-- ============================================================
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

  UNIQUE KEY `uk_usuario_email` (`email`),
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

-- ============================================================
-- 4) Tabla: tarifa
-- ============================================================
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

-- ============================================================
-- 5) Tabla: promocion
-- ============================================================
CREATE TABLE IF NOT EXISTS `promocion` (
  `id_promocion` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador único de la promoción',

  `id_tarifa` INT UNSIGNED NOT NULL COMMENT 'Tarifa sobre la cual se aplica la promoción (FK a tarifa.id_tarifa)',

  `nombre` VARCHAR(100) NOT NULL COMMENT 'Nombre de la promoción (ej: Promo Verano 10%, Black Friday)',
  `descripcion` VARCHAR(255) NULL COMMENT 'Descripción breve de las condiciones de la promoción',

  `porcentaje_descuento` DECIMAL(5,2) NOT NULL COMMENT 'Porcentaje de descuento sobre la tarifa base (0 - 100)',
  `noches_minimas` SMALLINT UNSIGNED NULL COMMENT 'Cantidad mínima de noches para aplicar la promo (NULL si no aplica)',

  `fecha_desde` DATE NOT NULL COMMENT 'Fecha de inicio de vigencia de la promoción',
  `fecha_hasta` DATE NOT NULL COMMENT 'Fecha de fin de vigencia de la promoción',

  `es_activa` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '1 = promoción activa/usable, 0 = deshabilitada',

  `creado_en` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creación del registro',
  `actualizado_en` DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT 'Última fecha y hora de modificación',

  PRIMARY KEY (`id_promocion`),
  KEY `idx_promocion_id_tarifa` (`id_tarifa`),

  CONSTRAINT `fk_promocion_tarifa`
    FOREIGN KEY (`id_tarifa`)
    REFERENCES `tarifa` (`id_tarifa`)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,

  CONSTRAINT `chk_promocion_porcentaje_descuento`
    CHECK (`porcentaje_descuento` >= 0.00 AND `porcentaje_descuento` <= 100.00)
) ENGINE=InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci
  COMMENT = 'Promociones de descuento aplicadas sobre tarifas base';

-- ============================================================
-- 6) Tabla: amenidad
-- ============================================================
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

-- ============================================================
-- 7) Tabla: habitacion
-- ============================================================
CREATE TABLE IF NOT EXISTS `habitacion` (
  `id_habitacion` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Identificador único de la habitación',

  `codigo` VARCHAR(20) NOT NULL COMMENT 'Código interno de la habitación (ej: STD-101, DLX-203)',
  `nombre` VARCHAR(100) NOT NULL COMMENT 'Nombre comercial de la habitación (ej: Doble Standard, Suite Deluxe)',

  `descripcion` VARCHAR(255) NOT NULL COMMENT 'Descripción breve de la habitación para mostrar en la web',

  `piso` VARCHAR(20) NULL COMMENT 'Piso o planta donde se encuentra (ej: 1, 2, 3, planta baja)',
  `numero` VARCHAR(10) NULL COMMENT 'Número de la habitación dentro del piso (ej: 101, 203B)',

  `capacidad_personas` SMALLINT UNSIGNED NOT NULL COMMENT 'Cantidad máxima de huéspedes que admite la habitación',
  `tipo_cama` VARCHAR(50) NULL COMMENT 'Tipo de cama principal (ej: Queen, King, Twin)',

  `id_tarifa` INT UNSIGNED NOT NULL COMMENT 'Tarifa base asociada a la habitación (FK a tarifa.id_tarifa)',

  `imagen_principal` VARCHAR(255) NULL COMMENT 'Ruta a la imagen principal de la habitación (archivo estático en Flask)',

  `es_activa` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '1 = habitación visible y reservable, 0 = deshabilitada',

  `creado_en` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creación del registro',
  `actualizado_en` DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT 'Última fecha y hora de modificación',

  PRIMARY KEY (`id_habitacion`),

  UNIQUE KEY `uk_habitacion_codigo` (`codigo`),
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

-- ============================================================
-- 8) Tabla: habitacion_amenidad (tabla pivote N:N)
-- ============================================================
CREATE TABLE IF NOT EXISTS `habitacion_amenidad` (
  `id_habitacion` INT UNSIGNED NOT NULL COMMENT 'FK a habitacion.id_habitacion',
  `id_amenidad` INT UNSIGNED NOT NULL COMMENT 'FK a amenidad.id_amenidad',

  `creado_en` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creación del vínculo',

  PRIMARY KEY (`id_habitacion`, `id_amenidad`),

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

-- ============================================================
-- 9) Tabla: reserva
-- ============================================================
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

  `estado` VARCHAR(20) NOT NULL DEFAULT 'pendiente' COMMENT 'Estado actual de la reserva',

  `monto_total` DECIMAL(10,2) NOT NULL COMMENT 'Importe total calculado para toda la estadía (n noches)',

  `creado_en` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora de creación de la reserva',
  `actualizado_en` DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT 'Última fecha y hora de modificación',

  PRIMARY KEY (`id_reserva`),

  UNIQUE KEY `uk_reserva_codigo` (`codigo_reserva`),

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

-- ============================================================
-- Restaurar valor original de FOREIGN_KEY_CHECKS
-- ============================================================
SET FOREIGN_KEY_CHECKS = @OLD_FOREIGN_KEY_CHECKS;
