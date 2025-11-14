-- ============================================================
-- Archivo  : tarifa_inserts.sql
-- Tabla    : tarifa
-- Objetivo : Cargar tarifas base reembolsable y no reembolsable.
-- ============================================================

USE `hotel_hunter`;

INSERT INTO `tarifa`
  (`nombre`, `descripcion`, `monto_noche`, `moneda`,
   `es_reembolsable`, `noches_minimas`,
   `fecha_desde`, `fecha_hasta`, `es_activa`)
VALUES
  (
    'Base Reembolsable',
    'Tarifa estándar reembolsable, flexible en cambios y cancelaciones.',
    50000.00,
    'ARS',
    1,
    NULL,
    '2025-01-01',
    NULL,
    1
  ),
  (
    'No Reembolsable Web',
    'Tarifa con descuento exclusiva web, no admite reembolso.',
    43000.00,
    'ARS',
    0,
    NULL,
    '2025-01-01',
    NULL,
    1
  );
