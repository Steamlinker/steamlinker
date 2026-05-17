// Rutas de gestion de perfil de usuario
// Permite editar perfil, agregar juegos y consultar datos del usuario

const express = require('express');
const pool = require('../db');
const { verificarToken } = require('./auth');
const steamService = require('../services/steamService');

const router = express.Router();

// PUT /perfil/editar
// Edita los datos del perfil del usuario logueado
router.put('/editar', verificarToken, async (req, res) => {
    const { descripcion, pais } = req.body;
    // Validación: la columna pais en la BD ha sido ampliada a varchar(100).
    // Limitar entrada por seguridad a 100 caracteres y devolver error claro si excede.
    if (pais && typeof pais === 'string' && pais.length > 100) {
        return res.status(400).json({ error: 'El valor de "pais" es demasiado largo. Máx 100 caracteres.' });
    }

    try {
        const resultado = await pool.query(
            `UPDATE usuarios 
             SET descrip_usu = $1, pais_usu = $2
             WHERE id_usu = $3
             RETURNING id_usu, username_usu, descrip_usu, pais_usu`,
            [descripcion || null, pais || null, req.usuario.id]
        );

        res.json(resultado.rows[0]);

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET /perfil/:id
// Devuelve el perfil publico de cualquier usuario
router.get('/:id', verificarToken, async (req, res) => {
    try {
        const usuario = await pool.query(
            `SELECT id_usu, username_usu, descrip_usu, pais_usu, 
                    repu_usu, totalrating_usu, tipo_usu, creadoen_usu,
                    perfil_publico, mostrar_biblioteca, notificaciones_amigos, 
                    dos_factor, correos_promocionales
             FROM usuarios WHERE id_usu = $1`,
            [req.params.id]
        );

        if (usuario.rows.length === 0) {
            return res.status(404).json({ error: 'Usuario no encontrado' });
        }

        // Traer los juegos del usuario
        const juegos = await pool.query(
            `SELECT j.appid, j.nom_jg, j.headerimg_jg, j.capsuleimg_jg,
                    uj.horas_usujg, uj.esfav_usujg
             FROM usuarios_juegos uj
             JOIN juegos j ON uj.appid = j.appid
             WHERE uj.id_usu = $1
             ORDER BY uj.esfav_usujg DESC, uj.horas_usujg DESC`,
            [req.params.id]
        );

        // Traer si tiene perfil de steam vinculado
        const steam = await pool.query(
            `SELECT steam_id, username_steperfil, avatar_url, perfil_url
             FROM perfiles_steam WHERE id_usu = $1`,
            [req.params.id]
        );

        res.json({
            ...usuario.rows[0],
            juegos: juegos.rows,
            steam: steam.rows[0] || null
        });

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// POST /perfil/steam/vincular
// Vincula la cuenta Steam del usuario con su perfil de SteamLinker
router.post('/steam/vincular', verificarToken, async (req, res) => {
    const { steamid } = req.body;
    if (!steamid) {
        return res.status(400).json({ error: 'SteamID o URL de Steam es obligatorio' });
    }

    try {
        const resolvedSteamId = await steamService.resolveSteamId(steamid);
        const perfilSteam = await steamService.getUserProfile(resolvedSteamId);

        await pool.query(
            `INSERT INTO perfiles_steam (id_usu, steam_id, username_steperfil, avatar_url, perfil_url)
             VALUES ($1, $2, $3, $4, $5)
             ON CONFLICT (id_usu) DO UPDATE SET
               steam_id = EXCLUDED.steam_id,
               username_steperfil = EXCLUDED.username_steperfil,
               avatar_url = EXCLUDED.avatar_url,
               perfil_url = EXCLUDED.perfil_url`,
            [
                req.usuario.id,
                perfilSteam.steamid,
                perfilSteam.username,
                perfilSteam.avatar,
                perfilSteam.profileUrl,
            ]
        );

        res.json(perfilSteam);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// POST /perfil/steam/importar
// Importa la biblioteca Steam vinculada al perfil del usuario
router.post('/steam/importar', verificarToken, async (req, res) => {
    try {
        const steamRow = await pool.query(
            'SELECT steam_id FROM perfiles_steam WHERE id_usu = $1',
            [req.usuario.id]
        );

        if (steamRow.rows.length === 0) {
            return res.status(400).json({ error: 'No hay cuenta Steam vinculada' });
        }

        const steamid = steamRow.rows[0].steam_id;
        const ownedGames = await steamService.getOwnedGames(steamid);

        const imported = [];
        for (const juego of ownedGames) {
            await pool.query(
                `INSERT INTO juegos (appid, nom_jg, headerimg_jg, capsuleimg_jg)
                 VALUES ($1, $2, $3, $4)
                 ON CONFLICT (appid) DO NOTHING`,
                [juego.appid, juego.name, juego.headerImg, juego.capsuleImg]
            );

            const result = await pool.query(
                `INSERT INTO usuarios_juegos (id_usu, appid, horas_usujg, esfav_usujg)
                 VALUES ($1, $2, $3, $4)
                 ON CONFLICT (id_usu, appid) DO UPDATE
                 SET horas_usujg = EXCLUDED.horas_usujg
                 RETURNING *`,
                [req.usuario.id, juego.appid, juego.hoursPlayed, false]
            );

            imported.push(result.rows[0]);
        }

        res.json({ mensaje: `Importados ${imported.length} juegos`, total: imported.length });
    } catch (err) {
        if (err.message?.includes('privada')) {
            return res.status(403).json({ error: 'La biblioteca de Steam es privada. Hazla pública para importarla.' });
        }
        res.status(500).json({ error: err.message });
    }
});

// DELETE /perfil/steam/desvincular
// Desvincula la cuenta Steam conectada al perfil del usuario
router.delete('/steam/desvincular', verificarToken, async (req, res) => {
    try {
        await pool.query(
            'DELETE FROM perfiles_steam WHERE id_usu = $1',
            [req.usuario.id]
        );
        res.json({ mensaje: 'Cuenta Steam desvinculada correctamente' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// POST /perfil/juegos/agregar
// Agrega un juego al perfil del usuario
// El juego se busca primero en la BD, si no existe se guarda automaticamente
router.post('/juegos/agregar', verificarToken, async (req, res) => {
    const { appid, nombre, headerimg, capsuleimg, horas, favorito } = req.body;

    if (!appid || !nombre) {
        return res.status(400).json({ error: 'appid y nombre son obligatorios' });
    }

    try {
        // Insertar el juego en la tabla juegos si no existe todavia
        await pool.query(
            `INSERT INTO juegos (appid, nom_jg, headerimg_jg, capsuleimg_jg)
             VALUES ($1, $2, $3, $4)
             ON CONFLICT (appid) DO NOTHING`,
            [appid, nombre, headerimg || null, capsuleimg || null]
        );

        // Agregar el juego al perfil del usuario
        const resultado = await pool.query(
            `INSERT INTO usuarios_juegos (id_usu, appid, horas_usujg, esfav_usujg)
             VALUES ($1, $2, $3, $4)
             ON CONFLICT (id_usu, appid) DO UPDATE 
             SET horas_usujg = $3, esfav_usujg = $4
             RETURNING *`,
            [req.usuario.id, appid, horas || 0, favorito || false]
        );

        res.status(201).json(resultado.rows[0]);

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// DELETE /perfil/juegos/:appid
// Elimina un juego del perfil del usuario
router.delete('/juegos/:appid', verificarToken, async (req, res) => {
    try {
        await pool.query(
            'DELETE FROM usuarios_juegos WHERE id_usu = $1 AND appid = $2',
            [req.usuario.id, req.params.appid]
        );

        res.json({ mensaje: 'Juego eliminado del perfil' });

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET /perfil/juegos/buscar?q=nombre
// Busca juegos en la Steam Store API
// No requiere API key, es publica
router.get('/juegos/buscar', verificarToken, async (req, res) => {
    const { q } = req.query;

    if (!q) {
        return res.status(400).json({ error: 'Parametro q es obligatorio' });
    }

    try {
        const axios = require('axios');
        const respuesta = await axios.get(
            `https://store.steampowered.com/api/storesearch/`,
            { params: { term: q, l: 'spanish', cc: 'CO' } }
        );

        const juegos = respuesta.data.items.map(j => ({
            appid: j.id,
            nombre: j.name,
            headerimg: `https://cdn.cloudflare.steamstatic.com/steam/apps/${j.id}/header.jpg`,
            capsuleimg: j.tiny_image
        }));

        res.json({ juegos, total: juegos.length });

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// PUT /perfil/privacidad
// Guarda los ajustes de privacidad del usuario
router.put('/privacidad', verificarToken, async (req, res) => {
    const {
        perfil_publico,
        mostrar_biblioteca,
        notificaciones_amigos,
        dos_factor,
        correos_promocionales
    } = req.body;

    try {
        const resultado = await pool.query(
            `UPDATE usuarios 
             SET perfil_publico = COALESCE($1, perfil_publico),
                 mostrar_biblioteca = COALESCE($2, mostrar_biblioteca),
                 notificaciones_amigos = COALESCE($3, notificaciones_amigos),
                 dos_factor = COALESCE($4, dos_factor),
                 correos_promocionales = COALESCE($5, correos_promocionales)
             WHERE id_usu = $6
             RETURNING perfil_publico, mostrar_biblioteca, notificaciones_amigos, dos_factor, correos_promocionales`,
            [
                perfil_publico ?? null,
                mostrar_biblioteca ?? null,
                notificaciones_amigos ?? null,
                dos_factor ?? null,
                correos_promocionales ?? null,
                req.usuario.id
            ]
        );

        if (resultado.rows.length === 0) {
            return res.status(404).json({ error: 'Usuario no encontrado' });
        }

        res.json({
            mensaje: 'Ajustes de privacidad guardados',
            privacidad: resultado.rows[0]
        });

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;