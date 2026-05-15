// Rutas de publicaciones
// Permite crear, listar, filtrar y cerrar publicaciones

const express = require('express');
const pool = require('../db');
const { verificarToken } = require('./auth');

const router = express.Router();

// POST /publicaciones/crear
// Crea una nueva publicacion con sus juegos asociados
router.post('/crear', verificarToken, async (req, res) => {
    const { tipo, titulo, descripcion, pais, juegos } = req.body;

    if (!tipo || !titulo) {
        return res.status(400).json({ error: 'tipo y titulo son obligatorios' });
    }

    try {
        // Crear la publicacion
        const resultado = await pool.query(
            `INSERT INTO publicaciones (id_usu, tipo_publi, titulo_publi, descrip_publi, paisfiltro_publi)
             VALUES ($1, $2, $3, $4, $5)
             RETURNING *`,
            [req.usuario.id, tipo, titulo, descripcion || null, pais || null]
        );

        const publicacion = resultado.rows[0];

        // Asociar los juegos a la publicacion si se enviaron
        if (juegos && juegos.length > 0) {
            for (const juego of juegos) {
                // Guardar el juego si no existe
                await pool.query(
                    `INSERT INTO juegos (appid, nom_jg, headerimg_jg, capsuleimg_jg)
                     VALUES ($1, $2, $3, $4)
                     ON CONFLICT (appid) DO NOTHING`,
                    [juego.appid, juego.nombre, juego.headerimg || null, juego.capsuleimg || null]
                );

                // Asociar el juego a la publicacion
                await pool.query(
                    `INSERT INTO publicacion_juegos (id_publi, appid) VALUES ($1, $2)`,
                    [publicacion.id_publi, juego.appid]
                );
            }
        }

        res.status(201).json(publicacion);

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET /publicaciones/buscar
// Busca publicaciones con filtros opcionales
// Parametros: tipo, pais, appid, orden (recientes | reputacion)
router.get('/buscar', async (req, res) => {
    const { tipo, pais, appid, orden } = req.query;

    try {
        // Construir la consulta dinamicamente segun los filtros
        let consulta = `
            SELECT DISTINCT p.*, 
                   u.username_usu, u.repu_usu, u.pais_usu,
                   COUNT(pj.appid) as total_juegos
            FROM publicaciones p
            JOIN usuarios u ON p.id_usu = u.id_usu
            LEFT JOIN publicacion_juegos pj ON p.id_publi = pj.id_publi
            WHERE p.estado_publi = TRUE
        `;

        const parametros = [];
        let contador = 1;

        if (tipo) {
            consulta += ` AND p.tipo_publi = $${contador}`;
            parametros.push(tipo);
            contador++;
        }

        if (pais) {
            consulta += ` AND p.paisfiltro_publi = $${contador}`;
            parametros.push(pais);
            contador++;
        }

        if (appid) {
            consulta += ` AND pj.appid = $${contador}`;
            parametros.push(parseInt(appid));
            contador++;
        }

        consulta += ` GROUP BY p.id_publi, u.username_usu, u.repu_usu, u.pais_usu`;

        // Ordenar por fecha o reputacion del autor
        if (orden === 'reputacion') {
            consulta += ` ORDER BY u.repu_usu DESC`;
        } else {
            consulta += ` ORDER BY p.creadoen_publi DESC`;
        }

        const resultado = await pool.query(consulta, parametros);

        // Traer los juegos de cada publicacion
        const publicaciones = await Promise.all(
            resultado.rows.map(async (pub) => {
                const juegos = await pool.query(
                    `SELECT j.appid, j.nom_jg, j.headerimg_jg
                     FROM publicacion_juegos pj
                     JOIN juegos j ON pj.appid = j.appid
                     WHERE pj.id_publi = $1`,
                    [pub.id_publi]
                );
                return { ...pub, juegos: juegos.rows };
            })
        );

        res.json({ publicaciones, total: publicaciones.length });

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET /publicaciones/:id
// Devuelve una publicacion especifica con todos sus detalles
router.get('/:id', async (req, res) => {
    try {
        const resultado = await pool.query(
            `SELECT p.*, u.username_usu, u.repu_usu, u.pais_usu
             FROM publicaciones p
             JOIN usuarios u ON p.id_usu = u.id_usu
             WHERE p.id_publi = $1`,
            [req.params.id]
        );

        if (resultado.rows.length === 0) {
            return res.status(404).json({ error: 'Publicacion no encontrada' });
        }

        const juegos = await pool.query(
            `SELECT j.appid, j.nom_jg, j.headerimg_jg, j.capsuleimg_jg
             FROM publicacion_juegos pj
             JOIN juegos j ON pj.appid = j.appid
             WHERE pj.id_publi = $1`,
            [req.params.id]
        );

        res.json({ ...resultado.rows[0], juegos: juegos.rows });

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// PUT /publicaciones/:id/cerrar
// Cierra una publicacion para que no aparezca en busquedas
router.put('/:id/cerrar', verificarToken, async (req, res) => {
    try {
        const resultado = await pool.query(
            `UPDATE publicaciones SET estado_publi = FALSE
             WHERE id_publi = $1 AND id_usu = $2
             RETURNING *`,
            [req.params.id, req.usuario.id]
        );

        if (resultado.rows.length === 0) {
            return res.status(404).json({ error: 'Publicacion no encontrada o no te pertenece' });
        }

        res.json({ mensaje: 'Publicacion cerrada', publicacion: resultado.rows[0] });

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;