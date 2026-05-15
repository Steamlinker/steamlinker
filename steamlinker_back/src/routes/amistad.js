const express = require('express');
const pool = require('../db');
const { verificarToken } = require('./auth');

const router = express.Router();

// POST /amistad/enviar
// Envia una solicitud de amistad
router.post('/enviar', verificarToken, async (req, res) => {
    const { id_receptor } = req.body;

    if (!id_receptor) {
        return res.status(400).json({ error: 'id_receptor es obligatorio' });
    }

    if (id_receptor === req.usuario.id) {
        return res.status(400).json({ error: 'No puedes enviarte una solicitud a ti mismo' });
    }

    try {
        const existe = await pool.query(
            `SELECT id_amistad FROM amistad
             WHERE (id_solicitante = $1 AND id_receptor = $2)
             OR (id_solicitante = $2 AND id_receptor = $1)`,
            [req.usuario.id, id_receptor]
        );

        if (existe.rows.length > 0) {
            return res.status(409).json({ error: 'Ya existe una solicitud entre estos usuarios' });
        }

        const resultado = await pool.query(
            `INSERT INTO amistad (id_solicitante, id_receptor)
             VALUES ($1, $2) RETURNING *`,
            [req.usuario.id, id_receptor]
        );

        res.status(201).json(resultado.rows[0]);

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET /amistad/solicitudes
// Lista las solicitudes de amistad recibidas pendientes
router.get('/solicitudes', verificarToken, async (req, res) => {
    try {
        const resultado = await pool.query(
            `SELECT a.*, u.username_usu AS solicitante_username, u.repu_usu
             FROM amistad a
             JOIN usuarios u ON a.id_solicitante = u.id_usu
             WHERE a.id_receptor = $1 AND a.estado_amistad = 'Pendiente'
             ORDER BY a.creadoen_amistad DESC`,
            [req.usuario.id]
        );

        res.json({ solicitudes: resultado.rows, total: resultado.rows.length });

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET /amistad/amigos
// Lista todos los amigos del usuario logueado
router.get('/amigos', verificarToken, async (req, res) => {
    try {
        const resultado = await pool.query(
            `SELECT a.*,
                    CASE 
                        WHEN a.id_solicitante = $1 THEN u2.username_usu
                        ELSE u1.username_usu
                    END AS amigo_username,
                    CASE 
                        WHEN a.id_solicitante = $1 THEN u2.id_usu
                        ELSE u1.id_usu
                    END AS amigo_id,
                    CASE 
                        WHEN a.id_solicitante = $1 THEN u2.repu_usu
                        ELSE u1.repu_usu
                    END AS amigo_reputacion
             FROM amistad a
             JOIN usuarios u1 ON a.id_solicitante = u1.id_usu
             JOIN usuarios u2 ON a.id_receptor = u2.id_usu
             WHERE (a.id_solicitante = $1 OR a.id_receptor = $1)
             AND a.estado_amistad = 'Aceptada'
             ORDER BY a.creadoen_amistad DESC`,
            [req.usuario.id]
        );

        res.json({ amigos: resultado.rows, total: resultado.rows.length });

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// PUT /amistad/:id/responder
// Acepta o rechaza una solicitud de amistad
router.put('/:id/responder', verificarToken, async (req, res) => {
    const { estado } = req.body;

    if (!estado || !['Aceptada', 'Rechazada'].includes(estado)) {
        return res.status(400).json({ error: 'estado debe ser Aceptada o Rechazada' });
    }

    try {
        const resultado = await pool.query(
            `UPDATE amistad SET estado_amistad = $1
             WHERE id_amistad = $2 AND id_receptor = $3
             RETURNING *`,
            [estado, req.params.id, req.usuario.id]
        );

        if (resultado.rows.length === 0) {
            return res.status(404).json({ error: 'Solicitud no encontrada o no eres el receptor' });
        }

        res.json(resultado.rows[0]);

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
