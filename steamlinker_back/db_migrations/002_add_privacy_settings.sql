-- Migration: agregar campos de privacidad a la tabla usuarios
-- Añade 5 columnas booleanas para gestionar preferencias de privacidad

BEGIN;

ALTER TABLE usuarios
  ADD COLUMN IF NOT EXISTS perfil_publico BOOLEAN DEFAULT true,
  ADD COLUMN IF NOT EXISTS mostrar_biblioteca BOOLEAN DEFAULT true,
  ADD COLUMN IF NOT EXISTS notificaciones_amigos BOOLEAN DEFAULT true,
  ADD COLUMN IF NOT EXISTS dos_factor BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS correos_promocionales BOOLEAN DEFAULT true;

COMMIT;

-- Ejecutar con: psql -U <usuario> -d <basedatos> -f 002_add_privacy_settings.sql
