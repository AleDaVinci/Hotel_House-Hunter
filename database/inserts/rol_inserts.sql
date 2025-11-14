-- ============================================================
-- Archivo  : rol_inserts.sql
-- Tabla    : rol
-- Objetivo : Cargar los roles básicos del sistema hotelero.
-- ============================================================

USE `hotel_hunter`;

INSERT INTO `rol` (`nombre`, `descripcion`, `es_activo`)
VALUES
  ('administrador',       'Acceso completo al sistema, gestión de usuarios, habitaciones y reservas', 1),
  ('recepcionista',       'Gestiona check-in, check-out y reservas de huéspedes', 1),
  ('huesped',             'Cliente del hotel con acceso a sus reservas y datos personales', 1),
  ('personal_de_limpieza','Accede a información sobre tareas de limpieza y estado de habitaciones', 1);
