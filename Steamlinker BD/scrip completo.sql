

--aqui comienza las tablas
CREATE TABLE usuarios (
	id_usu SERIAL PRIMARY KEY,
	username_usu VARCHAR(50) UNIQUE NOT NULL,
	email_usu VARCHAR(100) UNIQUE NOT NULL,
	pwhash_usu VARCHAR(255),
	descrip_usu TEXT,
	pais_usu VARCHAR(5),
	repu_usu DECIMAL(3,2) DEFAULT 0.0,
	totalrating_usu INTEGER DEFAULT 0,
	tipo_usu VARCHAR(20) DEFAULT 'Registrado',
	creadoen_usu TIMESTAMP DEFAULT NOW()
);

CREATE TABLE perfiles_steam(
	id_steperfil SERIAL PRIMARY KEY,
	id_usu INTEGER UNIQUE NOT NULL REFERENCES usuarios(id_usu) ON DELETE CASCADE,
	steam_id VARCHAR(20) UNIQUE NOT NULL,
	username_steperfil VARCHAR(50) NOT NULL,
	avatar_url VARCHAR(255),
	perfil_url VARCHAR(255),
	creadoen_steperfil TIMESTAMP DEFAULT NOW()
);

CREATE TABLE juegos (
	appid INTEGER PRIMARY KEY NOT NULL,
	nom_jg VARCHAR(150) NOT NULL,
	headerimg_jg VARCHAR(255),
	capsuleimg_jg VARCHAR(255)
);

CREATE TABLE usuarios_juegos (
	id_usujg SERIAL PRIMARY KEY,
	id_usu INTEGER NOT NULL REFERENCES usuarios(id_usu) ON DELETE CASCADE,
	appid INTEGER NOT NULL REFERENCES juegos(appid),
	horas_usujg INTEGER DEFAULT 0,
	esfav_usujg BOOLEAN DEFAULT FALSE,
	UNIQUE(id_usu, appid)
);

CREATE TABLE publicaciones (
	id_publi SERIAL PRIMARY KEY,
	id_usu INTEGER NOT NULL REFERENCES usuarios(id_usu) ON DELETE CASCADE,
	tipo_publi VARCHAR(30) NOT NULL CHECK(tipo_publi IN ('busco_familia','busco_miembros','otro')),
	titulo_publi VARCHAR(150) NOT NULL,
	descrip_publi TEXT,
	estado_publi BOOLEAN DEFAULT TRUE,
	paisfiltro_publi VARCHAR(10),
	creadoen_publi TIMESTAMP DEFAULT NOW()
);

CREATE TABLE publicacion_juegos (
	id_jgpubli SERIAL PRIMARY KEY,
	id_publi INTEGER NOT NULL REFERENCES publicaciones(id_publi) ON DELETE CASCADE,
	appid INTEGER NOT NULL REFERENCES juegos(appid)
);

CREATE TABLE matches(
	id_match SERIAL PRIMARY KEY,
	id_solicitante INTEGER NOT NULL REFERENCES usuarios(id_usu),
	id_receptor INTEGER NOT NULL REFERENCES usuarios(id_usu),
	id_publi INTEGER REFERENCES publicaciones(id_publi),
	estado_match VARCHAR(30) CHECK(estado_match IN ('Aceptada','Pendiente','Rechazada')) DEFAULT 'Pendiente',
	creadoen_match TIMESTAMP DEFAULT NOW(),
	CONSTRAINT no_automatch CHECK (id_solicitante <> id_receptor)
);

CREATE TABLE calificaciones(
	id_cali SERIAL PRIMARY KEY,
	id_match INTEGER NOT NULL REFERENCES matches(id_match),
	id_calificador INTEGER NOT NULL REFERENCES usuarios(id_usu),
	id_calificado INTEGER NOT NULL REFERENCES usuarios(id_usu),
	estrellas_cali DECIMAL(3,2) CHECK (estrellas_cali >= 0 AND estrellas_cali <= 5),
	confiable_cali BOOLEAN,
	logrocometido_cali BOOLEAN,
	comentario_cali TEXT,
	creadoen_cali TIMESTAMP DEFAULT NOW()
);

CREATE TABLE chat(
	id_chat SERIAL PRIMARY KEY,
	id_participante1 INTEGER NOT NULL REFERENCES usuarios(id_usu),
	id_participante2 INTEGER NOT NULL REFERENCES usuarios(id_usu),
	creadoen_chat TIMESTAMP DEFAULT NOW(),
	CONSTRAINT no_chat_duplicado UNIQUE (id_participante1, id_participante2),
	CONSTRAINT no_autochat CHECK (id_participante1 <> id_participante2)
);

CREATE TABLE mensaje(
	id_mensaje SERIAL PRIMARY KEY,
	id_chat INTEGER NOT NULL REFERENCES chat(id_chat),
	id_emisor INTEGER NOT NULL REFERENCES usuarios(id_usu),
	parent_mensaje INTEGER REFERENCES mensaje(id_mensaje),
	mensaje_chat TEXT,
	tipo_mensaje VARCHAR(20) DEFAULT 'texto',
	creadoen_mensaje TIMESTAMP DEFAULT NOW()
);

CREATE TABLE reportes(
	id_repor SERIAL PRIMARY KEY,
	id_reportador INTEGER NOT NULL REFERENCES usuarios(id_usu),
	id_reportado INTEGER NOT NULL REFERENCES usuarios(id_usu),
	motivo_repor TEXT NOT NULL,
	estado_repor VARCHAR(20) DEFAULT 'Pendiente',
	creadoen_repor TIMESTAMP DEFAULT NOW(),
	CONSTRAINT no_autoreporte CHECK (id_reportador <> id_reportado)
);

CREATE TABLE amistad(
	id_amistad SERIAL PRIMARY KEY,
	id_solicitante INTEGER NOT NULL REFERENCES usuarios(id_usu),
	id_receptor INTEGER NOT NULL REFERENCES usuarios(id_usu),
	estado_amistad VARCHAR(30) DEFAULT 'Pendiente',
	creadoen_amistad TIMESTAMP DEFAULT NOW(),
	CONSTRAINT no_autoamistad CHECK (id_solicitante <> id_receptor)
);

-- aqui termina , hasta aqui vas a ejecutar 

-- Borrar tablas sin dropear la base 
DROP TABLE IF EXISTS amistad CASCADE;
DROP TABLE IF EXISTS reportes CASCADE;
DROP TABLE IF EXISTS mensaje CASCADE;
DROP TABLE IF EXISTS chat CASCADE;
DROP TABLE IF EXISTS calificaciones CASCADE;
DROP TABLE IF EXISTS matches CASCADE;
DROP TABLE IF EXISTS publicacion_juegos CASCADE;
DROP TABLE IF EXISTS publicaciones CASCADE;
DROP TABLE IF EXISTS usuarios_juegos CASCADE;
DROP TABLE IF EXISTS juegos CASCADE;
DROP TABLE IF EXISTS perfiles_steam CASCADE;
DROP TABLE IF EXISTS usuarios CASCADE;

-- comprobar que las tablas existen
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public'
ORDER BY table_name;

-- Poblacion temporal para pruebas de humo 

-- Usuarios de prueba
INSERT INTO usuarios (username_usu, email_usu, pwhash_usu, descrip_usu, pais_usu, tipo_usu) VALUES
('Camiko31', 'camilo@gmail.com', 'hash123', 'Jugador competitivo busco familia', 'CO', 'Registrado'),
('MiguelJ', 'miguel@gmail.com', 'hash456', 'Tengo familia con buenos juegos', 'CO', 'Registrado'),
('SeanP', 'sean@gmail.com', 'hash789', 'Busco miembros activos', 'MX', 'Registrado'),
('ChrisB', 'chris@gmail.com', 'hashABC', 'Admin del sistema', 'CO', 'Admin'),
('JesusG', 'jesus@gmail.com', 'hashDEF', 'Jugador casual', 'AR', 'Registrado');

-- Perfil steam de prueba
INSERT INTO perfiles_steam (id_usu, steam_id, username_steperfil, avatar_url, perfil_url) VALUES
(1, '76561198000001', 'Camiko31_steam', 'https://avatar.url/1', 'https://steamcommunity.com/id/camiko31'),
(2, '76561198000002', 'MiguelJ_steam', 'https://avatar.url/2', 'https://steamcommunity.com/id/miguelj');

-- Juegos de prueba
INSERT INTO juegos (appid, nom_jg, headerimg_jg, capsuleimg_jg) VALUES
(814380, 'Sekiro Shadows Die Twice', 'https://cdn.cloudflare.steamstatic.com/steam/apps/814380/header.jpg', 'https://cdn.cloudflare.steamstatic.com/steam/apps/814380/capsule_231x87.jpg'),
(1245620, 'Elden Ring', 'https://cdn.cloudflare.steamstatic.com/steam/apps/1245620/header.jpg', 'https://cdn.cloudflare.steamstatic.com/steam/apps/1245620/capsule_231x87.jpg'),
(1593500, 'God of War', 'https://cdn.cloudflare.steamstatic.com/steam/apps/1593500/header.jpg', 'https://cdn.cloudflare.steamstatic.com/steam/apps/1593500/capsule_231x87.jpg'),
(1145360, 'Hades', 'https://cdn.cloudflare.steamstatic.com/steam/apps/1145360/header.jpg', 'https://cdn.cloudflare.steamstatic.com/steam/apps/1145360/capsule_231x87.jpg');

-- Juegos por usuario
INSERT INTO usuarios_juegos (id_usu, appid, horas_usujg, esfav_usujg) VALUES
(1, 814380, 85, TRUE),
(1, 1245620, 120, TRUE),
(1, 1593500, 48, FALSE),
(2, 814380, 200, TRUE),
(2, 1145360, 60, FALSE),
(3, 1245620, 90, TRUE),
(3, 1593500, 30, FALSE);

-- Publicaciones
INSERT INTO publicaciones (id_usu, tipo_publi, titulo_publi, descrip_publi, paisfiltro_publi) VALUES
(1, 'busco_familia', 'Busco familia con Elden Ring y Sekiro', 'Soy jugador activo, busco familia con juegos de accion', 'CO'),
(2, 'busco_miembros', 'Tengo familia con God of War', 'Tenemos 3 espacios disponibles, buscamos jugadores activos', 'CO'),
(3, 'otro', 'Alguien para jugar Elden Ring esta noche?', 'Busco compañero para explorar el mapa', NULL);

-- Juegos de cada publicacion
INSERT INTO publicacion_juegos (id_publi, appid) VALUES
(1, 814380),
(1, 1245620),
(2, 1593500),
(3, 1245620);

-- Matches
INSERT INTO matches (id_solicitante, id_receptor, id_publi, estado_match) VALUES
(1, 2, 2, 'Pendiente'),
(3, 1, 1, 'Aceptada');

-- Calificaciones
INSERT INTO calificaciones (id_match, id_calificador, id_calificado, estrellas_cali, confiable_cali, logrocometido_cali, comentario_cali) VALUES
(2, 3, 1, 4.5, TRUE, TRUE, 'Muy buen jugador, cumplio con lo que buscaba'),
(2, 1, 3, 5.0, TRUE, TRUE, 'Excelente persona, muy activo');

-- Chat
INSERT INTO chat (id_participante1, id_participante2) VALUES
(1, 2),
(1, 3);

-- Mensajes
INSERT INTO mensaje (id_chat, id_emisor, mensaje_chat, tipo_mensaje) VALUES
(1, 1, 'Hola, vi tu publicacion, me interesa unirme', 'texto'),
(1, 2, 'Claro, cuentame mas sobre ti', 'texto'),
(1, 1, 'Tengo 200 horas en God of War', 'texto'),
(2, 3, 'Oye tienes Elden Ring?', 'texto'),
(2, 1, 'Si, llevamos 120 horas', 'texto');

-- Reportes
INSERT INTO reportes (id_reportador, id_reportado, motivo_repor, estado_repor) VALUES
(3, 2, 'Dijo que tenia juegos que no tenia en su familia', 'Pendiente');

-- Amistad
INSERT INTO amistad (id_solicitante, id_receptor, estado_amistad) VALUES
(1, 3, 'Aceptada'),
(2, 3, 'Pendiente');

-- eliminacion de poblacion temporal sin borrar las tablas
DELETE FROM amistad;
DELETE FROM reportes;
DELETE FROM mensaje;
DELETE FROM chat;
DELETE FROM calificaciones;
DELETE FROM matches;
DELETE FROM publicacion_juegos;
DELETE FROM publicaciones;
DELETE FROM usuarios_juegos;
DELETE FROM perfiles_steam;
DELETE FROM juegos;
DELETE FROM usuarios;
--------------------------------------
-- Consultas para pruebas de humo

-- 1. Ver todos los usuarios con sus juegos
SELECT u.username_usu, j.nom_jg, uj.horas_usujg, uj.esfav_usujg
FROM usuarios u
JOIN usuarios_juegos uj ON u.id_usu = uj.id_usu
JOIN juegos j ON uj.appid = j.appid
ORDER BY u.username_usu;

--2. Ver publicaciones con sus juegos requeridos
SELECT p.titulo_publi, p.tipo_publi, j.nom_jg
FROM publicaciones p
JOIN publicacion_juegos pj ON p.id_publi = pj.id_publi
JOIN juegos j ON pj.appid = j.appid;

-- 3. Ver matches con los usuarios involucrados
SELECT 
    u1.username_usu AS solicitante,
    u2.username_usu AS receptor,
    m.estado_match
FROM matches m
JOIN usuarios u1 ON m.id_solicitante = u1.id_usu
JOIN usuarios u2 ON m.id_receptor = u2.id_usu;

--4. Ver calificaciones con nombres
SELECT 
    u1.username_usu AS calificador,
    u2.username_usu AS calificado,
    c.estrellas_cali,
    c.comentario_cali
FROM calificaciones c
JOIN usuarios u1 ON c.id_calificador = u1.id_usu
JOIN usuarios u2 ON c.id_calificado = u2.id_usu;

--5. Ver conversaciones con sus mensajes

SELECT 
    u1.username_usu AS participante1,
    u2.username_usu AS participante2,
    em.username_usu AS emisor,
    ms.mensaje_chat,
    ms.creadoen_mensaje
FROM mensaje ms
JOIN chat c ON ms.id_chat = c.id_chat
JOIN usuarios u1 ON c.id_participante1 = u1.id_usu
JOIN usuarios u2 ON c.id_participante2 = u2.id_usu
JOIN usuarios em ON ms.id_emisor = em.id_usu
ORDER BY ms.creadoen_mensaje;


--
SELECT * FROM usuarios;
SELECT * FROM juegos; 
SELECT * FROM ;
SELECT * FROM ;
SELECT * FROM ;
--
SELECT 'usuarios' as tabla, COUNT(*) as registros FROM usuarios
UNION ALL
SELECT 'publicaciones', COUNT(*) FROM publicaciones
UNION ALL
SELECT 'matches', COUNT(*) FROM matches
UNION ALL
SELECT 'mensaje', COUNT(*) FROM mensaje
UNION ALL
SELECT 'juegos', COUNT(*) FROM juegos
UNION ALL
SELECT 'amistad', COUNT(*) FROM amistad
UNION ALL
SELECT 'reportes', COUNT(*) FROM reportes
UNION ALL
SELECT 'calificaciones', COUNT(*) FROM calificaciones;
