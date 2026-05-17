-- Tabla usuario

CREATE TABLE usuarios (
	
	id_usu SERIAL PRIMARY KEY,
	username_usu VARCHAR(50) UNIQUE NOT NULL,
	email_usu VARCHAR(100) UNIQUE NOT NULL,
	pwhash_usu VARCHAR (255),
	descrip_usu TEXT,
	pais_usu VARCHAR(5),
	repu_usu DECIMAL(3,2) DEFAULT 0.0,
	totalrating_usu INTEGER DEFAULT 0,
	tipo_usu VARCHAR(20) DEFAULT 'Registrado',
	creadoen_usu TIMESTAMP DEFAULT NOW()
	
);

-- Tabla perfiles_steam
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
	headerimg_jg VARCHAR(255) ,
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

	id_publi SERIAL PRIMARY KEY ,
	id_usu INTEGER NOT NULL REFERENCES usuarios(id_usu) ON DELETE CASCADE,
	tipo_publi VARCHAR(30) NOT NULL CHECK(tipo_publi IN ('buscar familia','Busco miembros','otro')),
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
	estado_match VARCHAR(30) CHECK(estado_match IN ('Activa','Pendiente','Rechazada')) DEFAULT 'Pendiente',
	creadoen_match TIMESTAMP DEFAULT NOW()

);


CREATE TABLE calificaciones(

	id_cali SERIAL PRIMARY KEY,
	id_match INTEGER NOT NULL REFERENCES matches(id_match),
	id_calificador INTEGER NOT NULL REFERENCES usuarios(id_usu),
	id_calificado INTEGER NOT NULL REFERENCES usuarios(id_usu),
	estrellas_cali DECIMAL(3,2) CHECK (estrellas_cali>=0 and estrellas_cali<=5),
	confiable_cali BOOLEAN,
	logrocometido_cali BOOLEAN,
	comentario_cali TEXT,
	creadoen_cali TIMESTAMP DEFAULT NOW()
	
);

CREATE TABLE chat(

	id_chat SERIAL PRIMARY KEY,
	id_participante1 INTEGER NOT NULL REFERENCES usuarios(id_usu),
	id_participante2 INTEGER NOT NULL REFERENCES usuarios(id_usu),
	creadoen_chat TIMESTAMP DEFAULT NOW()

);

CREATE TABLE mensaje(

	id_mensaje SERIAL PRIMARY KEY,
	id_chat INTEGER NOT NULL REFERENCES chat(id_chat),
	id_emisor INTEGER NOT NULL REFERENCES usuarios(id_usu),
	parent_mensaje INTEGER REFERENCES mensaje(id_mensaje),
	mensaje_chat TEXT,
	tipo_mensaje VARCHAR(20) DEFAULT 'Texto',
	creadoen_mensaje TIMESTAMP DEFAULT NOW()

);

CREATE TABLE reportes(

	id_repor SERIAL PRIMARY KEY,
	id_reportador INTEGER NOT NULL REFERENCES usuarios(id_usu),
	id_reportado INTEGER NOT NULL REFERENCES usuarios(id_usu),
	motivo_repor TEXT NOT NULL,
	estado_repor VARCHAR(20) DEFAULT 'Pendiente',
	creadoen_repor TIMESTAMP DEFAULT NOW()

);

CREATE TABLE amistad(

	id_amistad SERIAL PRIMARY KEY,
	id_solicitante INTEGER NOT NULL REFERENCES usuarios(id_usu),
	id_receptor INTEGER NOT NULL REFERENCES usuarios(id_usu),
	estado_amistad VARCHAR(30) DEFAULT 'Pendiente',
	creadoen_amistad TIMESTAMP DEFAULT NOW()

);

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

