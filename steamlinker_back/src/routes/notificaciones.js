const express = require('express');
const pool = require('../db');
const { verificarToken } = require('./auth');

const router = express.Router();

// GET /notificaciones
router.get('/', verificarToken, async (req, res) => {
    const { filtro } = req.query;

    try {
        let consulta = `
            SELECT * FROM notificaciones
            WHERE id_usu = $1
        `;
        const params = [req.usuario.id];

        if (filtro === 'no_leidas') {
            consulta += ` AND leida_noti = FALSE`;
        } else if (filtro === 'interesantes') {
            consulta += ` AND interes_noti = 1`;
        }

        consulta += ` ORDER BY creadoen_noti DESC LIMIT 100`;

        const resultado = await pool.query(consulta, params);
        const noLeidas = await pool.query(
            `SELECT COUNT(*)::int AS total FROM notificaciones
             WHERE id_usu = $1 AND leida_noti = FALSE`,
            [req.usuario.id]
        );

        res.json({
            notificaciones: resultado.rows,
            total: resultado.rows.length,
            no_leidas: noLeidas.rows[0].total,
        });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET /notificaciones/contador
router.get('/contador', verificarToken, async (req, res) => {
    try {
        const resultado = await pool.query(
            `SELECT COUNT(*)::int AS total FROM notificaciones
             WHERE id_usu = $1 AND leida_noti = FALSE`,
            [req.usuario.id]
        );
        res.json({ no_leidas: resultado.rows[0].total });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// PUT /notificaciones/leer-todas
router.put('/leer-todas', verificarToken, async (req, res) => {
    try {
        await pool.query(
            `UPDATE notificaciones SET leida_noti = TRUE WHERE id_usu = $1`,
            [req.usuario.id]
        );
        res.json({ mensaje: 'Todas marcadas como leídas' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// PUT /notificaciones/:id/leida
router.put('/:id/leida', verificarToken, async (req, res) => {
    const { leida } = req.body;

    try {
        const resultado = await pool.query(
            `UPDATE notificaciones SET leida_noti = $1
             WHERE id_noti = $2 AND id_usu = $3
             RETURNING *`,
            [leida !== false, req.params.id, req.usuario.id]
        );

        if (resultado.rows.length === 0) {
            return res.status(404).json({ error: 'Notificación no encontrada' });
        }

        res.json(resultado.rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// PUT /notificaciones/:id/interes
router.put('/:id/interes', verificarToken, async (req, res) => {
    const { interes } = req.body;

    let valor = null;
    if (interes === true || interes === 1 || interes === 'true') valor = 1;
    if (interes === false || interes === -1 || interes === 'false') valor = -1;

    try {
        const resultado = await pool.query(
            `UPDATE notificaciones SET interes_noti = $1
             WHERE id_noti = $2 AND id_usu = $3
             RETURNING *`,
            [valor, req.params.id, req.usuario.id]
        );

        if (resultado.rows.length === 0) {
            return res.status(404).json({ error: 'Notificación no encontrada' });
        }

        res.json(resultado.rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
