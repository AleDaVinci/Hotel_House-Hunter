-- ============================================================
-- Archivo  : amenidad_inserts.sql
-- Tabla    : amenidad
-- Objetivo : Cargar amenities .
-- ============================================================

USE `hotel_hunter`;

INSERT INTO `amenidad`
  (`nombre`, `descripcion`, `icono`, `es_activa`)
VALUES
  ('WiFi',                'Conexión WiFi de alta velocidad en todo el hotel.', '/static/img/icons/wifi.svg', 1),
  ('TV por cable',        'Televisor con canales por cable y streaming.',      '/static/img/icons/tv.svg', 1),
  ('Aire acondicionado',  'Aire acondicionado frío/calor regulable.',          '/static/img/icons/air.svg', 1),
  ('Calefacción',         'Sistema de calefacción central.',                   '/static/img/icons/heat.svg', 1),
  ('Desayuno incluido',   'Desayuno buffet incluido en la estadía.',           '/static/img/icons/breakfast.svg', 1),
  ('Caja fuerte',         'Caja de seguridad en la habitación.',               '/static/img/icons/safe.svg', 1),
  ('Frigobar',            'Frigobar con bebidas y snacks.',                    '/static/img/icons/fridge.svg', 1),
  ('Secador de pelo',     'Secador de pelo en el baño.',                       '/static/img/icons/hairdryer.svg', 1),
  ('Servicio a la habitación', 'Room service disponible en horarios definidos.', '/static/img/icons/room_service.svg', 1),
  ('Piscina',             'Acceso a piscina climatizada (según temporada).',   '/static/img/icons/pool.svg', 1);
