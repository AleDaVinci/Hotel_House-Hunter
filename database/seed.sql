-- ============================================================
-- Archivo  : seed.sql
-- Proyecto : Sistema de reservas de hotel
-- Objetivo : Ejecutar todos los inserts iniciales del proyecto.
-- ============================================================

USE `hotel_reservas`;

-- Opcional: desactivar restricciones de FK mientras insertamos
SET @OLD_FOREIGN_KEY_CHECKS = @@FOREIGN_KEY_CHECKS;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- Cargar datos base
-- ============================================================

-- Roles
SOURCE ./inserts/rol_inserts.sql;

-- Usuarios iniciales
SOURCE ./inserts/usuario_inserts.sql;

-- Tarifas
SOURCE ./inserts/tarifa_inserts.sql;

-- Promociones
SOURCE ./inserts/promocion_inserts.sql;

-- Amenities
SOURCE ./inserts/amenidad_inserts.sql;

-- Habitaciones
SOURCE ./inserts/habitacion_inserts.sql;

-- Relación habitaciones ↔ amenities
SOURCE ./inserts/habitacion_amenidad_inserts.sql;

-- ============================================================
-- Restaurar FOREIGN_KEY_CHECKS
-- ============================================================
SET FOREIGN_KEY_CHECKS = @OLD_FOREIGN_KEY_CHECKS;
