const express = require('express');
const pool = require('../db');
const { verificarToken } = require('./auth');

const router = express.Router();

function isAdminTipo(tipo) {
    return String(tipo || '').toLowerCase() === 'admin';
}

function requireAdmin(req, res, next) {
    if (!req.usuario || !isAdminTipo(req.usuario.tipo)) {
        return res.status(403).json({ error: 'Acceso denegado. Se requiere cuenta administrador.' });
    }
    next();
}

// GET /api/admin/estadisticas
router.get('/estadisticas', verificarToken, requireAdmin, async (req, res) => {
    try {
        const [
            usuarios,
            publicaciones,
            reportesTotal,
            reportesPendientes,
            familiasAceptadas,
            solicitudesPendientes,
            usuariosBaneados,
        ] = await Promise.all([
            pool.query('SELECT COUNT(*)::int AS n FROM usuarios'),
            pool.query('SELECT COUNT(*)::int AS n FROM publicaciones'),
            pool.query('SELECT COUNT(*)::int AS n FROM reportes'),
            pool.query(
                `SELECT COUNT(*)::int AS n FROM reportes
                 WHERE LOWER(estado_repor) IN ('pendiente', 'abierto')`
            ),
            pool.query(
                `SELECT COUNT(*)::int AS n FROM matches WHERE estado_match = 'Aceptada'`
            ),
            pool.query(
                `SELECT COUNT(*)::int AS n FROM matches WHERE estado_match = 'Pendiente'`
            ),
            pool.query(
                'SELECT COUNT(*)::int AS n FROM usuarios WHERE COALESCE(baneado_usu, FALSE) = TRUE'
            ),
        ]);

        res.json({
            totalUsuarios: usuarios.rows[0].n,
            totalPublicaciones: publicaciones.rows[0].n,
            totalReportes: reportesTotal.rows[0].n,
            reportesPendientes: reportesPendientes.rows[0].n,
            familiasFormadas: familiasAceptadas.rows[0].n,
            solicitudesPendientes: solicitudesPendientes.rows[0].n,
            usuariosBaneados: usuariosBaneados.rows[0].n,
        });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET /api/admin/usuarios
router.get('/usuarios', verificarToken, requireAdmin, async (req, res) => {
    try {
        const resultado = await pool.query(`
            SELECT
                u.id_usu,
                u.username_usu,
                u.email_usu,
                u.pais_usu,
                u.tipo_usu,
                u.repu_usu,
                u.totalrating_usu,
                u.creadoen_usu,
                COALESCE(u.baneado_usu, FALSE) AS baneado_usu,
                u.motivo_ban,
                u.fechaban_usu,
                ps.steam_id,
                (
                    SELECT COUNT(*)::int FROM matches m
                    WHERE m.estado_match = 'Aceptada'
                      AND (m.id_solicitante = u.id_usu OR m.id_receptor = u.id_usu)
                ) AS familias_aceptadas,
                (
                    SELECT COUNT(*)::int FROM publicaciones p WHERE p.id_usu = u.id_usu
                ) AS total_publicaciones
            FROM usuarios u
            LEFT JOIN perfiles_steam ps ON ps.id_usu = u.id_usu
            ORDER BY u.id_usu DESC
        `);

        res.json(resultado.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// POST /api/admin/usuarios/:id/ban
router.post('/usuarios/:id/ban', verificarToken, requireAdmin, async (req, res) => {
    const id = parseInt(req.params.id, 10);
    const motivo = (req.body.motivo || req.body.reason || 'Incumplimiento de normas').trim();

    if (!id || Number.isNaN(id)) {
        return res.status(400).json({ error: 'ID inválido' });
    }

    if (id === req.usuario.id) {
        return res.status(400).json({ error: 'No puedes banearte a ti mismo' });
    }

    try {
        const target = await pool.query(
            'SELECT id_usu, tipo_usu FROM usuarios WHERE id_usu = $1',
            [id]
        );
        if (target.rows.length === 0) {
            return res.status(404).json({ error: 'Usuario no encontrado' });
        }
        if (isAdminTipo(target.rows[0].tipo_usu)) {
            return res.status(403).json({ error: 'No se puede banear a otro administrador' });
        }

        const resultado = await pool.query(
            `UPDATE usuarios
             SET baneado_usu = TRUE,
                 motivo_ban = $1,
                 fechaban_usu = NOW()
             WHERE id_usu = $2
             RETURNING id_usu, username_usu, baneado_usu, motivo_ban, fechaban_usu`,
            [motivo, id]
        );

        res.json({ mensaje: 'Usuario baneado', usuario: resultado.rows[0] });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// POST /api/admin/usuarios/:id/unban
router.post('/usuarios/:id/unban', verificarToken, requireAdmin, async (req, res) => {
    const id = parseInt(req.params.id, 10);

    if (!id || Number.isNaN(id)) {
        return res.status(400).json({ error: 'ID inválido' });
    }

    try {
        const resultado = await pool.query(
            `UPDATE usuarios
             SET baneado_usu = FALSE,
                 motivo_ban = NULL,
                 fechaban_usu = NULL
             WHERE id_usu = $1
             RETURNING id_usu, username_usu, baneado_usu`,
            [id]
        );

        if (resultado.rows.length === 0) {
            return res.status(404).json({ error: 'Usuario no encontrado' });
        }

        res.json({ mensaje: 'Usuario desbaneado', usuario: resultado.rows[0] });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET /api/admin/familias — matches (familias formadas / en proceso)
router.get('/familias', verificarToken, requireAdmin, async (req, res) => {
    try {
        const resultado = await pool.query(`
            SELECT
                m.id_match,
                u1.username_usu AS solicitante,
                u2.username_usu AS receptor,
                m.estado_match,
                m.creadoen_match,
                p.titulo_publi
            FROM matches m
            JOIN usuarios u1 ON m.id_solicitante = u1.id_usu
            JOIN usuarios u2 ON m.id_receptor = u2.id_usu
            LEFT JOIN publicaciones p ON m.id_publi = p.id_publi
            ORDER BY m.id_match DESC
        `);

        res.json(resultado.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET /api/admin/solicitudes — matches pendientes con nombres
router.get('/solicitudes', verificarToken, requireAdmin, async (req, res) => {
    try {
        const resultado = await pool.query(`
            SELECT
                m.id_match,
                u1.username_usu AS solicitante,
                u2.username_usu AS receptor,
                m.estado_match,
                m.creadoen_match,
                p.titulo_publi
            FROM matches m
            JOIN usuarios u1 ON m.id_solicitante = u1.id_usu
            JOIN usuarios u2 ON m.id_receptor = u2.id_usu
            LEFT JOIN publicaciones p ON m.id_publi = p.id_publi
            WHERE m.estado_match = 'Pendiente'
            ORDER BY m.creadoen_match DESC
        `);

        res.json(resultado.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET /api/admin/reportes
router.get('/reportes', verificarToken, requireAdmin, async (req, res) => {
    try {
        const resultado = await pool.query(`
            SELECT
                r.id_repor,
                r.id_reportador,
                r.id_reportado,
                u1.username_usu AS reportador,
                u2.username_usu AS reportado,
                r.motivo_repor,
                r.estado_repor,
                r.creadoen_repor
            FROM reportes r
            JOIN usuarios u1 ON r.id_reportador = u1.id_usu
            JOIN usuarios u2 ON r.id_reportado = u2.id_usu
            ORDER BY r.id_repor DESC
        `);

        res.json(resultado.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// PUT /api/admin/reportes/:id
router.put('/reportes/:id', verificarToken, requireAdmin, async (req, res) => {
    const id = parseInt(req.params.id, 10);
    let { estado } = req.body;

    if (!estado) {
        return res.status(400).json({ error: 'estado es obligatorio' });
    }

    const mapa = {
        resuelto: 'Resuelto',
        resuelta: 'Resuelto',
        descartado: 'Descartado',
        descartada: 'Descartado',
        pendiente: 'Pendiente',
        abierto: 'Pendiente',
    };
    estado = mapa[String(estado).toLowerCase()] || estado;

    try {
        const resultado = await pool.query(
            `UPDATE reportes SET estado_repor = $1 WHERE id_repor = $2 RETURNING *`,
            [estado, id]
        );

        if (resultado.rows.length === 0) {
            return res.status(404).json({ error: 'Reporte no encontrado' });
        }

        res.json(resultado.rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET /api/admin/contenido
router.get('/contenido', verificarToken, requireAdmin, async (req, res) => {
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
            JOIN usuarios u ON p.id_usu = u.id_usu
            ORDER BY p.id_publi DESC
        `);

        res.json(resultado.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// PUT /api/admin/contenido/:id — cerrar o reabrir publicación
router.put('/contenido/:id', verificarToken, requireAdmin, async (req, res) => {
    const id = parseInt(req.params.id, 10);
    let activo = req.body.estado_publi;

    if (activo === undefined && req.body.estado !== undefined) {
        const e = String(req.body.estado).toLowerCase();
        activo = e === 'aprobado' || e === 'activa' || e === 'activo' || e === 'true';
    }

    if (typeof activo !== 'boolean') {
        return res.status(400).json({ error: 'estado_publi (boolean) o estado es obligatorio' });
    }

    try {
        const resultado = await pool.query(
            `UPDATE publicaciones SET estado_publi = $1 WHERE id_publi = $2 RETURNING *`,
            [activo, id]
        );

        if (resultado.rows.length === 0) {
            return res.status(404).json({ error: 'Publicación no encontrada' });
        }

        res.json(resultado.rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
