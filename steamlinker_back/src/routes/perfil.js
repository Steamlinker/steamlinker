// Rutas de gestion de perfil de usuario
// Permite editar perfil, agregar juegos y consultar datos del usuario

const express = require('express');
const pool = require('../db');
const { verificarToken } = require('./auth');

const router = express.Router();

// PUT /perfil/editar
// Edita los datos del perfil del usuario logueado
router.put('/editar', verificarToken, async (req, res) => {
    const { descripcion, pais } = req.body;

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
                    repu_usu, totalrating_usu, tipo_usu, creadoen_usu
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

module.exports = router;