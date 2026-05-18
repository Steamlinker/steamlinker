-- Columnas de moderación en usuarios (idempotente)
ALTER TABLE usuarios ADD COLUMN IF NOT EXISTS baneado_usu BOOLEAN DEFAULT FALSE;
ALTER TABLE usuarios ADD COLUMN IF NOT EXISTS motivo_ban TEXT;
ALTER TABLE usuarios ADD COLUMN IF NOT EXISTS fechaban_usu TIMESTAMP;
