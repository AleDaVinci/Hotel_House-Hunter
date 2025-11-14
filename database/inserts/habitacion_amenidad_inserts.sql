-- ============================================================
-- Archivo  : habitacion_amenidad_inserts.sql
-- Tabla    : habitacion_amenidad
-- Objetivo : Relacionar habitaciones con amenities .
-- ============================================================

USE `hotel_hunter`;

INSERT INTO `habitacion_amenidad` (`id_habitacion`, `id_amenidad`)
VALUES
  -- ========================================================
  -- SGL-101 - Single Estándar 101
  -- ========================================================
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'SGL-101'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'WiFi')
  ),
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'SGL-101'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'TV por cable')
  ),
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'SGL-101'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'Aire acondicionado')
  ),
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'SGL-101'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'Calefacción')
  ),

  -- ========================================================
  -- SGL-102 - Single Estándar 102
  -- ========================================================
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'SGL-102'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'WiFi')
  ),
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'SGL-102'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'TV por cable')
  ),
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'SGL-102'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'Aire acondicionado')
  ),
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'SGL-102'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'Calefacción')
  ),

  -- ========================================================
  -- DBL-201 - Doble Estándar 201
  -- ========================================================
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'DBL-201'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'WiFi')
  ),
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'DBL-201'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'TV por cable')
  ),
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'DBL-201'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'Aire acondicionado')
  ),
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'DBL-201'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'Calefacción')
  ),
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'DBL-201'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'Desayuno incluido')
  ),
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'DBL-201'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'Caja fuerte')
  ),

  -- ========================================================
  -- DBL-202 - Doble Twin 202
  -- ========================================================
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'DBL-202'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'WiFi')
  ),
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'DBL-202'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'TV por cable')
  ),
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'DBL-202'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'Aire acondicionado')
  ),
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'DBL-202'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'Calefacción')
  ),
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'DBL-202'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'Desayuno incluido')
  ),
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'DBL-202'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'Caja fuerte')
  ),

  -- ========================================================
  -- TPL-301 - Triple Familiar 301
  -- ========================================================
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'TPL-301'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'WiFi')
  ),
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'TPL-301'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'TV por cable')
  ),
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'TPL-301'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'Aire acondicionado')
  ),
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'TPL-301'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'Calefacción')
  ),
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'TPL-301'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'Desayuno incluido')
  ),
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'TPL-301'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'Caja fuerte')
  ),
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'TPL-301'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'Frigobar')
  ),
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'TPL-301'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'Secador de pelo')
  ),

  -- ========================================================
  -- TPL-302 - Triple Superior 302
  -- ========================================================
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'TPL-302'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'WiFi')
  ),
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'TPL-302'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'TV por cable')
  ),
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'TPL-302'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'Aire acondicionado')
  ),
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'TPL-302'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'Calefacción')
  ),
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'TPL-302'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'Desayuno incluido')
  ),
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'TPL-302'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'Caja fuerte')
  ),
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'TPL-302'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'Frigobar')
  ),
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'TPL-302'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'Secador de pelo')
  ),
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'TPL-302'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'Servicio a la habitación')
  ),

  -- ========================================================
  -- QDL-401 - Cuádruple Familiar 401
  -- ========================================================
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'QDL-401'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'WiFi')
  ),
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'QDL-401'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'TV por cable')
  ),
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'QDL-401'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'Aire acondicionado')
  ),
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'QDL-401'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'Calefacción')
  ),
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'QDL-401'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'Desayuno incluido')
  ),
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'QDL-401'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'Caja fuerte')
  ),
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'QDL-401'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'Frigobar')
  ),
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'QDL-401'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'Secador de pelo')
  ),
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'QDL-401'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'Servicio a la habitación')
  ),
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'QDL-401'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'Piscina')
  ),

  -- ========================================================
  -- QDL-402 - Cuádruple Superior 402
  -- ========================================================
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'QDL-402'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'WiFi')
  ),
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'QDL-402'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'TV por cable')
  ),
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'QDL-402'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'Aire acondicionado')
  ),
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'QDL-402'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'Calefacción')
  ),
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'QDL-402'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'Desayuno incluido')
  ),
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'QDL-402'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'Caja fuerte')
  ),
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'QDL-402'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'Frigobar')
  ),
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'QDL-402'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'Secador de pelo')
  ),
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'QDL-402'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'Servicio a la habitación')
  ),
  (
    (SELECT h.id_habitacion FROM habitacion h WHERE h.codigo = 'QDL-402'),
    (SELECT a.id_amenidad FROM amenidad a WHERE a.nombre = 'Piscina')
  );
