-- Tabla de notificaciones in-app
CREATE TABLE IF NOT EXISTS notificaciones (
    id_noti SERIAL PRIMARY KEY,
    id_usu INTEGER NOT NULL REFERENCES usuarios(id_usu) ON DELETE CASCADE,
    tipo_noti VARCHAR(30) NOT NULL,
    titulo_noti VARCHAR(150) NOT NULL,
    cuerpo_noti TEXT,
    leida_noti BOOLEAN DEFAULT FALSE,
    interes_noti SMALLINT,
    ref_tipo VARCHAR(30),
    ref_id INTEGER,
    avatar_noti VARCHAR(12),
    creadoen_noti TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notificaciones_usuario
    ON notificaciones (id_usu, leida_noti, creadoen_noti DESC);
