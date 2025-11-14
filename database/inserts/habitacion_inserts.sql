-- ============================================================
-- Archivo  : habitacion_inserts.sql
-- Tabla    : habitacion
-- Objetivo : Cargar habitaciones (2 single, 2 dobles, 2 triples, 2 cuádruples).
-- ============================================================

USE `hotel_hunter`;

INSERT INTO `habitacion`
  (`codigo`, `nombre`, `descripcion`,
   `piso`, `numero`,
   `capacidad_personas`, `tipo_cama`,
   `id_tarifa`,
   `imagen_principal`,
   `es_activa`)
VALUES
  -- Singles
  (
    'SGL-101',
    'Single Estándar 101',
    'Habitación single estándar con vista interna.',
    '1',
    '101',
    1,
    'Single',
    (SELECT `id_tarifa` FROM `tarifa` WHERE `nombre` = 'Base Reembolsable'),
    '/static/img/habitaciones/single_101.jpg',
    1
  ),
  (
    'SGL-102',
    'Single Estándar 102',
    'Habitación single estándar, ideal para viajes de trabajo.',
    '1',
    '102',
    1,
    'Single',
    (SELECT `id_tarifa` FROM `tarifa` WHERE `nombre` = 'No Reembolsable Web'),
    '/static/img/habitaciones/single_102.jpg',
    1
  ),

  -- Dobles
  (
    'DBL-201',
    'Doble Estándar 201',
    'Habitación doble con cama matrimonial.',
    '2',
    '201',
    2,
    'Queen',
    (SELECT `id_tarifa` FROM `tarifa` WHERE `nombre` = 'Base Reembolsable'),
    '/static/img/habitaciones/doble_201.jpg',
    1
  ),
  (
    'DBL-202',
    'Doble Twin 202',
    'Habitación doble con dos camas individuales.',
    '2',
    '202',
    2,
    'Twin',
    (SELECT `id_tarifa` FROM `tarifa` WHERE `nombre` = 'No Reembolsable Web'),
    '/static/img/habitaciones/doble_202.jpg',
    1
  ),

  -- Triples
  (
    'TPL-301',
    'Triple Familiar 301',
    'Habitación triple ideal para familias pequeñas.',
    '3',
    '301',
    3,
    'Matrimonial + Single',
    (SELECT `id_tarifa` FROM `tarifa` WHERE `nombre` = 'Base Reembolsable'),
    '/static/img/habitaciones/triple_301.jpg',
    1
  ),
  (
    'TPL-302',
    'Triple Superior 302',
    'Habitación triple con mayor espacio y cómodo escritorio.',
    '3',
    '302',
    3,
    'Matrimonial + Single',
    (SELECT `id_tarifa` FROM `tarifa` WHERE `nombre` = 'No Reembolsable Web'),
    '/static/img/habitaciones/triple_302.jpg',
    1
  ),

  -- Cuádruples
  (
    'QDL-401',
    'Cuádruple Familiar 401',
    'Habitación cuádruple ideal para familias.',
    '4',
    '401',
    4,
    '2 Matrimoniales',
    (SELECT `id_tarifa` FROM `tarifa` WHERE `nombre` = 'Base Reembolsable'),
    '/static/img/habitaciones/cuadruple_401.jpg',
    1
  ),
  (
    'QDL-402',
    'Cuádruple Superior 402',
    'Habitación cuádruple con mayor confort y espacio.',
    '4',
    '402',
    4,
    '2 Matrimoniales',
    (SELECT `id_tarifa` FROM `tarifa` WHERE `nombre` = 'No Reembolsable Web'),
    '/static/img/habitaciones/cuadruple_402.jpg',
    1
  );
