// Rutas del sistema de matches
// Maneja solicitudes entre usuarios

const express = require('express');
const pool = require('../db');
const { verificarToken } = require('./auth');

const router = express.Router();

// POST /matches/enviar
// Envia una solicitud de match a otro usuario
router.post('/enviar', verificarToken, async (req, res) => {
    const { id_receptor, id_publi } = req.body;

    if (!id_receptor) {
        return res.status(400).json({ error: 'id_receptor es obligatorio' });
    }

    // Verificar que no se este enviando a si mismo (el constraint lo hace tambien)
    if (id_receptor === req.usuario.id) {
        return res.status(400).json({ error: 'No puedes enviarte una solicitud a ti mismo' });
    }

    try {
        // Verificar que no exista ya un match pendiente entre estos dos usuarios
        const existe = await pool.query(
            `SELECT id_match FROM matches 
             WHERE id_solicitante = $1 AND id_receptor = $2 
             AND estado_match = 'Pendiente'`,
            [req.usuario.id, id_receptor]
        );

        if (existe.rows.length > 0) {
            return res.status(409).json({ error: 'Ya tienes una solicitud pendiente con este usuario' });
        }

        const resultado = await pool.query(
            `INSERT INTO matches (id_solicitante, id_receptor, id_publi)
             VALUES ($1, $2, $3)
             RETURNING *`,
            [req.usuario.id, id_receptor, id_publi || null]
        );

        res.status(201).json(resultado.rows[0]);

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET /matches/recibidos
// Lista las solicitudes recibidas por el usuario logueado
router.get('/recibidos', verificarToken, async (req, res) => {
    try {
        const resultado = await pool.query(
            `SELECT m.*, 
                    u.username_usu AS solicitante_username,
                    u.repu_usu AS solicitante_reputacion,
                    u.pais_usu AS solicitante_pais
             FROM matches m
             JOIN usuarios u ON m.id_solicitante = u.id_usu
             WHERE m.id_receptor = $1
             ORDER BY m.creadoen_match DESC`,
            [req.usuario.id]
        );

        res.json({ matches: resultado.rows, total: resultado.rows.length });

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET /matches/enviados
// Lista las solicitudes enviadas por el usuario logueado
router.get('/enviados', verificarToken, async (req, res) => {
    try {
        const resultado = await pool.query(
            `SELECT m.*, 
                    u.username_usu AS receptor_username,
                    u.repu_usu AS receptor_reputacion,
                    u.pais_usu AS receptor_pais
             FROM matches m
             JOIN usuarios u ON m.id_receptor = u.id_usu
             WHERE m.id_solicitante = $1
             ORDER BY m.creadoen_match DESC`,
            [req.usuario.id]
        );

        res.json({ matches: resultado.rows, total: resultado.rows.length });

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// PUT /matches/:id/responder
// Acepta o rechaza una solicitud de match
router.put('/:id/responder', verificarToken, async (req, res) => {
    const { estado } = req.body;

    if (!estado || !['Aceptada', 'Rechazada'].includes(estado)) {
        return res.status(400).json({ error: 'estado debe ser Aceptada o Rechazada' });
    }

    try {
        const resultado = await pool.query(
            `UPDATE matches SET estado_match = $1
             WHERE id_match = $2 AND id_receptor = $3
             RETURNING *`,
            [estado, req.params.id, req.usuario.id]
        );

        if (resultado.rows.length === 0) {
            return res.status(404).json({ error: 'Match no encontrado o no eres el receptor' });
        }

        // Si se acepta el match, crear un chat entre los dos usuarios automaticamente
        if (estado === 'Aceptada') {
            const match = resultado.rows[0];
            await pool.query(
                `INSERT INTO chat (id_participante1, id_participante2)
                 VALUES ($1, $2)
                 ON CONFLICT DO NOTHING`,
                [match.id_solicitante, match.id_receptor]
            );
        }

        res.json(resultado.rows[0]);

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;