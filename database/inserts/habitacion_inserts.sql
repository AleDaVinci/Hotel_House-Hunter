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
  -- Single 1 (f1)
  (
    'SGL-101',
    'Single Estándar 101',
    'Cálida habitación single para 1 huésped, con cama confortable, baño privado completo, WiFi de alta velocidad y calefacción central. Ubicada en el primer piso, ofrece un ambiente tranquilo con vista a las montañas fueguinas.',
    '1',
    '101',
    1,
    'Single',
    (SELECT `id_tarifa` FROM `tarifa` WHERE `nombre` = 'Base Reembolsable'),
    'habitaciones/f1.jpg',
    1
  ),

  -- Single 2 (f2)
  (
    'SGL-102',
    'Single Estándar 102',
    'Habitación single pensada para 1 huésped, con cama cómoda, baño privado completo, escritorio funcional, TV LED y WiFi. Ideal para viajes de trabajo, con iluminación natural y vista parcial al Canal Beagle.',
    '1',
    '102',
    1,
    'Single',
    (SELECT `id_tarifa` FROM `tarifa` WHERE `nombre` = 'No Reembolsable Web'),
    'habitaciones/f2.jpg',
    1
  ),

  -- Doble 1 (f3)
  (
    'DBL-201',
    'Doble Estándar 201',
    'Amplia habitación doble con cama Queen para hasta 2 huéspedes, baño privado completo, TV LED, WiFi y calefacción central. Ubicada en el segundo piso, ofrece una cómoda área de descanso y vista al Canal Beagle.',
    '2',
    '201',
    2,
    'Queen',
    (SELECT `id_tarifa` FROM `tarifa` WHERE `nombre` = 'Base Reembolsable'),
    'habitaciones/f3.jpg',
    1
  ),

  -- Doble 2 (f4)
  (
    'DBL-202',
    'Doble Twin 202',
    'Cálida habitación doble con dos camas individuales, ideal para amigos o compañeros de viaje. Cuenta con baño privado completo, WiFi, TV LED y calefacción central. Desde el segundo piso se disfruta una agradable vista a las montañas.',
    '2',
    '202',
    2,
    'Twin',
    (SELECT `id_tarifa` FROM `tarifa` WHERE `nombre` = 'No Reembolsable Web'),
    'habitaciones/f4.jpg',
    1
  ),

  -- Triple 1 (f5)
  (
    'TPL-301',
    'Triple Familiar 301',
    'Habitación triple para hasta 3 huéspedes, equipada con cama matrimonial y cama single, baño privado completo, WiFi, TV LED y espacio de guardado. Ideal para familias pequeñas, con vista abierta hacia el Canal Beagle.',
    '3',
    '301',
    3,
    'Matrimonial + Single',
    (SELECT `id_tarifa` FROM `tarifa` WHERE `nombre` = 'Base Reembolsable'),
    'habitaciones/f5.jpg',
    1
  ),

  -- Triple 2 (f6)
  (
    'TPL-302',
    'Triple Superior 302',
    'Habitación triple superior con cama matrimonial y cama single, pensada para 3 huéspedes que buscan mayor confort. Incluye baño privado completo, escritorio de apoyo, WiFi, TV LED y una acogedora vista a las montañas.',
    '3',
    '302',
    3,
    'Matrimonial + Single',
    (SELECT `id_tarifa` FROM `tarifa` WHERE `nombre` = 'No Reembolsable Web'),
    'habitaciones/f6.jpg',
    1
  ),

  -- Cuádruple 1 (f7)
  (
    'QDL-401',
    'Cuádruple Familiar 401',
    'Espaciosa habitación cuádruple con 2 camas matrimoniales para hasta 4 huéspedes, baño privado completo, WiFi, TV LED y calefacción central. Ideal para familias, ubicada en el cuarto piso con una destacada vista al Canal Beagle.',
    '4',
    '401',
    4,
    '2 Matrimoniales',
    (SELECT `id_tarifa` FROM `tarifa` WHERE `nombre` = 'Base Reembolsable'),
    'habitaciones/f7.jpg',
    1
  ),

  -- Cuádruple 2 (f8)
  (
    'QDL-402',
    'Cuádruple Superior 402',
    'Cuádruple superior con 2 camas matrimoniales para hasta 4 huéspedes, baño privado completo, WiFi, TV LED y área de descanso extendida. Perfecta para estadías en familia, con una vista privilegiada a las montañas y alrededores.',
    '4',
    '402',
    4,
    '2 Matrimoniales',
    (SELECT `id_tarifa` FROM `tarifa` WHERE `nombre` = 'No Reembolsable Web'),
    'habitaciones/f8.jpg',
    1
  );
