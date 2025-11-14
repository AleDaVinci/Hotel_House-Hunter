-- ============================================================
-- Archivo  : seed.sql
-- Proyecto : Sistema de reservas de hotel
-- Objetivo : Ejecutar todos los inserts iniciales del proyecto.
-- ============================================================

USE `hotel_hunter`;

-- Opcional: desactivar restricciones de FK mientras insertamos
SET @OLD_FOREIGN_KEY_CHECKS = @@FOREIGN_KEY_CHECKS;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- Cargar datos base
-- ============================================================

-- Roles
 SOURCE ./database/inserts/rol_inserts.sql;

-- Usuarios iniciales
 SOURCE ./database/inserts/usuario_inserts.sql;

-- Tarifas
SOURCE ./database/inserts/tarifa_inserts.sql;

-- Promociones
SOURCE ./database/inserts/promocion_inserts.sql;

-- Amenities
SOURCE ./database/inserts/amenidad_inserts.sql;

-- Habitaciones
SOURCE ./database/inserts/habitacion_inserts.sql;

-- Relación habitaciones ↔ amenities
SOURCE ./database/inserts/habitacion_amenidad_inserts.sql;

-- ============================================================
-- Restaurar FOREIGN_KEY_CHECKS
-- ============================================================
SET FOREIGN_KEY_CHECKS = @OLD_FOREIGN_KEY_CHECKS;
