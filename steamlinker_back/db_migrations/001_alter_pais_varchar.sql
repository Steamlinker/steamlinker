-- Migration: ampliar longitud de columna pais_usu en la tabla usuarios
-- Cambia character varying(5) a character varying(100)

BEGIN;

ALTER TABLE usuarios
  ALTER COLUMN pais_usu TYPE character varying(100);

COMMIT;

-- Ejecutar con: psql -U <usuario> -d <basedatos> -f 001_alter_pais_varchar.sql
