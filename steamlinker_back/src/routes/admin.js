const express = require('express');

const router = express.Router();

const pool = require('../db');

const { verificarToken } = require('./auth');




// =========================
// MIDDLEWARE ADMIN
// =========================

function requireAdmin(req, res, next) {

    if (!req.usuario || req.usuario.tipo !== 'admin') {

        return res.status(403).json({
            error: 'Acceso denegado'
        });

    }

    next();
}




// =========================
// ESTADISTICAS
// =========================

router.get(
    '/estadisticas',
    verificarToken,
    requireAdmin,
    async (req, res) => {

        try {

            const usuarios = await pool.query(
                'SELECT COUNT(*) FROM usuarios'
            );

            const publicaciones = await pool.query(
                'SELECT COUNT(*) FROM publicaciones'
            );

            const reportes = await pool.query(
                'SELECT COUNT(*) FROM reportes'
            );

            res.json({
                totalUsuarios: usuarios.rows[0].count,
                totalPublicaciones: publicaciones.rows[0].count,
                totalReportes: reportes.rows[0].count
            });

        } catch (err) {

            res.status(500).json({
                error: err.message
            });

        }

    }
);




// =========================
// USUARIOS
// =========================

router.get(
    '/usuarios',
    verificarToken,
    requireAdmin,
    async (req, res) => {

        try {

            const resultado = await pool.query(`
                SELECT 
                    id_usu,
                    username_usu,
                    email_usu,
                    pais_usu,
                    tipo_usu,
                    creadoen_usu
                FROM usuarios
                ORDER BY id_usu DESC
            `);

            res.json(resultado.rows);

        } catch (err) {

            res.status(500).json({
                error: err.message
            });

        }

    }
);




// =========================
// REPORTES
// =========================

router.get(
    '/reportes',
    verificarToken,
    requireAdmin,
    async (req, res) => {

        try {

            const resultado = await pool.query(`
                SELECT 
                    r.id_repor,
                    u1.username_usu AS reportador,
                    u2.username_usu AS reportado,
                    r.motivo_repor,
                    r.estado_repor,
                    r.creadoen_repor
                FROM reportes r
                JOIN usuarios u1
                    ON r.id_reportador = u1.id_usu
                JOIN usuarios u2
                    ON r.id_reportado = u2.id_usu
                ORDER BY r.id_repor DESC
            `);

            res.json(resultado.rows);

        } catch (err) {

            res.status(500).json({
                error: err.message
            });

        }

    }
);

router.get(
    '/familias',
    verificarToken,
    requireAdmin,
    async (req, res) => {

        try {

            const resultado = await pool.query(`
                SELECT
                    m.id_match,
                    u1.username_usu AS solicitante,
                    u2.username_usu AS receptor,
                    m.estado_match,
                    m.creadoen_match
                FROM matches m
                JOIN usuarios u1
                    ON m.id_solicitante = u1.id_usu
                JOIN usuarios u2
                    ON m.id_receptor = u2.id_usu
                ORDER BY m.id_match DESC
            `);

            res.json(resultado.rows);

        } catch (err) {

            res.status(500).json({
                error: err.message
            });

        }

    }
);

router.get(
    '/solicitudes',
    verificarToken,
    requireAdmin,
    async (req, res) => {

        try {

            const resultado = await pool.query(`
                SELECT
                    id_match,
                    estado_match,
                    creadoen_match
                FROM matches
                WHERE estado_match = 'Pendiente'
                ORDER BY id_match DESC
            `);

            res.json(resultado.rows);

        } catch (err) {

            res.status(500).json({
                error: err.message
            });

        }

    }
);
// =========================
// CONTENIDO / PUBLICACIONES
// =========================

router.get(
    '/contenido',
    verificarToken,
    requireAdmin,
    async (req, res) => {

        try {

            const resultado = await pool.query(`
                SELECT
                    p.id_publi,
                    p.titulo_publi,
                    p.tipo_publi,
                    p.estado_publi,
                    p.creadoen_publi,
                    u.username_usu
                FROM publicaciones p
                JOIN usuarios u
                    ON p.id_usu = u.id_usu
                ORDER BY p.id_publi DESC
            `);

            res.json(resultado.rows);

        } catch (err) {

            res.status(500).json({
                error: err.message
            });

        }

    }
);

module.exports = router;