-- Comentarios en publicaciones (mínimo viable social)
CREATE TABLE IF NOT EXISTS comentario_publicacion (
    id_coment SERIAL PRIMARY KEY,
    id_publi INTEGER NOT NULL REFERENCES publicaciones(id_publi) ON DELETE CASCADE,
    id_usu INTEGER NOT NULL REFERENCES usuarios(id_usu) ON DELETE CASCADE,
    id_padre INTEGER REFERENCES comentario_publicacion(id_coment) ON DELETE CASCADE,
    texto_coment TEXT NOT NULL,
    creadoen_coment TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_comentario_publicacion_publi
    ON comentario_publicacion (id_publi, creadoen_coment ASC);
