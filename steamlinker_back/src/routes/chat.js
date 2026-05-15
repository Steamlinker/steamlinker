// Rutas del sistema de chat
// Maneja conversaciones y mensajes entre usuarios

const express = require('express');
const pool = require('../db');
const { verificarToken } = require('./auth');

const router = express.Router();

// GET /chat/conversaciones
// Lista todas las conversaciones del usuario logueado
router.get('/conversaciones', verificarToken, async (req, res) => {
    try {
        const resultado = await pool.query(
            `SELECT c.*,
                    u1.username_usu AS username_participante1,
                    u2.username_usu AS username_participante2,
                    -- Ultimo mensaje de la conversacion
                    (SELECT mensaje_chat FROM mensaje 
                     WHERE id_chat = c.id_chat 
                     ORDER BY creadoen_mensaje DESC LIMIT 1) AS ultimo_mensaje,
                    (SELECT creadoen_mensaje FROM mensaje 
                     WHERE id_chat = c.id_chat 
                     ORDER BY creadoen_mensaje DESC LIMIT 1) AS fecha_ultimo_mensaje
             FROM chat c
             JOIN usuarios u1 ON c.id_participante1 = u1.id_usu
             JOIN usuarios u2 ON c.id_participante2 = u2.id_usu
             WHERE c.id_participante1 = $1 OR c.id_participante2 = $1
             ORDER BY fecha_ultimo_mensaje DESC NULLS LAST`,
            [req.usuario.id]
        );

        res.json({ conversaciones: resultado.rows, total: resultado.rows.length });

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET /chat/:id/mensajes
// Trae todos los mensajes de una conversacion
router.get('/:id/mensajes', verificarToken, async (req, res) => {
    try {
        // Verificar que el usuario pertenece a este chat
        const chat = await pool.query(
            `SELECT * FROM chat WHERE id_chat = $1 
             AND (id_participante1 = $2 OR id_participante2 = $2)`,
            [req.params.id, req.usuario.id]
        );

        if (chat.rows.length === 0) {
            return res.status(403).json({ error: 'No tienes acceso a este chat' });
        }

        const mensajes = await pool.query(
            `SELECT m.*, u.username_usu AS emisor_username
             FROM mensaje m
             JOIN usuarios u ON m.id_emisor = u.id_usu
             WHERE m.id_chat = $1
             ORDER BY m.creadoen_mensaje ASC`,
            [req.params.id]
        );

        res.json({ mensajes: mensajes.rows, total: mensajes.rows.length });

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// POST /chat/:id/mensaje
// Envia un mensaje en una conversacion
router.post('/:id/mensaje', verificarToken, async (req, res) => {
    const { mensaje, tipo, parent_mensaje } = req.body;

    if (!mensaje) {
        return res.status(400).json({ error: 'El mensaje no puede estar vacio' });
    }

    try {
        // Verificar que el usuario pertenece a este chat
        const chat = await pool.query(
            `SELECT * FROM chat WHERE id_chat = $1
             AND (id_participante1 = $2 OR id_participante2 = $2)`,
            [req.params.id, req.usuario.id]
        );

        if (chat.rows.length === 0) {
            return res.status(403).json({ error: 'No tienes acceso a este chat' });
        }

        const resultado = await pool.query(
            `INSERT INTO mensaje (id_chat, id_emisor, mensaje_chat, tipo_mensaje, parent_mensaje)
             VALUES ($1, $2, $3, $4, $5)
             RETURNING *`,
            [req.params.id, req.usuario.id, mensaje, tipo || 'texto', parent_mensaje || null]
        );

        res.status(201).json(resultado.rows[0]);

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// POST /chat/iniciar
// Inicia una conversacion con otro usuario directamente
// No requiere match previo
router.post('/iniciar', verificarToken, async (req, res) => {
    const { id_receptor } = req.body;

    if (!id_receptor) {
        return res.status(400).json({ error: 'id_receptor es obligatorio' });
    }

    try {
        // Verificar que no exista ya un chat entre estos dos usuarios
        const existe = await pool.query(
            `SELECT * FROM chat 
             WHERE (id_participante1 = $1 AND id_participante2 = $2)
             OR (id_participante1 = $2 AND id_participante2 = $1)`,
            [req.usuario.id, id_receptor]
        );

        if (existe.rows.length > 0) {
            return res.json({ chat: existe.rows[0], mensaje: 'Chat ya existente' });
        }

        const resultado = await pool.query(
            `INSERT INTO chat (id_participante1, id_participante2)
             VALUES ($1, $2) RETURNING *`,
            [req.usuario.id, id_receptor]
        );

        res.status(201).json({ chat: resultado.rows[0], mensaje: 'Chat creado' });

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;