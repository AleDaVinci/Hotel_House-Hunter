-- ============================================================
-- Archivo  : promocion_inserts.sql
-- Tabla    : promocion
-- Objetivo : Cargar promociones de temporada de verano e invierno.
-- ============================================================

USE `hotel_hunter`;

INSERT INTO `promocion`
  (`id_tarifa`, `nombre`, `descripcion`,
   `porcentaje_descuento`, `noches_minimas`,
   `fecha_desde`, `fecha_hasta`, `es_activa`)
VALUES
  (
    (SELECT `id_tarifa` FROM `tarifa` WHERE `nombre` = 'Base Reembolsable'),
    'Promo Verano',
    'Descuento especial para estadías en temporada de verano.',
    15.00,
    3,
    '2025-12-15',
    '2026-03-15',
    1
  ),
  (
    (SELECT `id_tarifa` FROM `tarifa` WHERE `nombre` = 'No Reembolsable Web'),
    'Promo Invierno',
    'Descuento especial para estadías en temporada de invierno.',
    20.00,
    1,
    '2026-06-01',
    '2026-08-31',
    1
  );
