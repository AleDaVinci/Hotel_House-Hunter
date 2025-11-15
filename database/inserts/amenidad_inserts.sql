-- ============================================================
-- Archivo  : amenidad_inserts.sql
-- Tabla    : amenidad
-- Objetivo : Cargar amenities .
-- ============================================================

USE `hotel_hunter`;

INSERT INTO `amenidad`
  (`nombre`, `descripcion`, `icono`, `es_activa`)
VALUES
  ('WiFi',
   'Conexión WiFi de alta velocidad en todo el hotel.',
   'https://unpkg.com/lucide-static@latest/icons/wifi.svg',
   1),

  ('TV por cable',
   'Televisor con canales por cable y streaming.',
   'https://unpkg.com/lucide-static@latest/icons/tv.svg',
   1),

  ('Aire acondicionado',
   'Aire acondicionado frío/calor regulable.',
   'https://unpkg.com/lucide-static@latest/icons/wind.svg',
   1),

  ('Calefacción',
   'Sistema de calefacción central.',
   'https://unpkg.com/lucide-static@latest/icons/flame.svg',
   1),

  ('Desayuno incluido',
   'Desayuno buffet incluido en la estadía.',
   'https://unpkg.com/lucide-static@latest/icons/utensils-crossed.svg',
   1),

  ('Caja fuerte',
   'Caja de seguridad en la habitación.',
   'https://unpkg.com/lucide-static@latest/icons/shield.svg',
   1),

  ('Frigobar',
   'Frigobar con bebidas y snacks.',
   'https://unpkg.com/lucide-static@latest/icons/ice-cream.svg',
   1),

  ('Secador de pelo',
   'Secador de pelo en el baño.',
   'https://unpkg.com/lucide-static@latest/icons/fan.svg',
   1),

  ('Servicio a la habitación',
   'Room service disponible en horarios definidos.',
   'https://unpkg.com/lucide-static@latest/icons/concierge-bell.svg',
   1),

  ('Piscina',
   'Acceso a piscina climatizada (según temporada).',
   'https://unpkg.com/lucide-static@latest/icons/waves.svg',
   1);