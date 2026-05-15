const express = require('express');
const pool = require('../db');
const { verificarToken } = require('./auth');

const router = express.Router();

// POST /reportes/crear
// Crea un reporte contra otro usuario
router.post('/crear', verificarToken, async (req, res) => {
    const { id_reportado, motivo } = req.body;

    if (!id_reportado || !motivo) {
        return res.status(400).json({ error: 'id_reportado y motivo son obligatorios' });
    }

    if (id_reportado === req.usuario.id) {
        return res.status(400).json({ error: 'No puedes reportarte a ti mismo' });
    }

    try {
        const resultado = await pool.query(
            `INSERT INTO reportes (id_reportador, id_reportado, motivo_repor)
             VALUES ($1, $2, $3)
             RETURNING *`,
            [req.usuario.id, id_reportado, motivo]
        );

        res.status(201).json(resultado.rows[0]);

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET /reportes/admin
// Lista todos los reportes pendientes, solo para administradores
router.get('/admin', verificarToken, async (req, res) => {
    if (req.usuario.tipo !== 'Admin') {
        return res.status(403).json({ error: 'Acceso denegado' });
    }

    try {
        const resultado = await pool.query(
            `SELECT r.*,
                    u1.username_usu AS reportador_username,
                    u2.username_usu AS reportado_username
             FROM reportes r
             JOIN usuarios u1 ON r.id_reportador = u1.id_usu
             JOIN usuarios u2 ON r.id_reportado = u2.id_usu
             WHERE r.estado_repor = 'Pendiente'
             ORDER BY r.creadoen_repor DESC`
        );

        res.json({ reportes: resultado.rows, total: resultado.rows.length });

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// PUT /reportes/:id/resolver
// Marca un reporte como resuelto, solo para administradores
router.put('/:id/resolver', verificarToken, async (req, res) => {
    if (req.usuario.tipo !== 'Admin') {
        return res.status(403).json({ error: 'Acceso denegado' });
    }

    try {
        const resultado = await pool.query(
            `UPDATE reportes SET estado_repor = 'Resuelto'
             WHERE id_repor = $1
             RETURNING *`,
            [req.params.id]
        );

        if (resultado.rows.length === 0) {
            return res.status(404).json({ error: 'Reporte no encontrado' });
        }

        res.json(resultado.rows[0]);

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;