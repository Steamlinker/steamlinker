const pool = require('../db');

/**
 * Crea una notificación para un usuario.
 */
async function crearNotificacion({
    idUsuario,
    tipo,
    titulo,
    cuerpo,
    refTipo = null,
    refId = null,
    avatar = null,
}) {
    await pool.query(
        `INSERT INTO notificaciones
         (id_usu, tipo_noti, titulo_noti, cuerpo_noti, ref_tipo, ref_id, avatar_noti)
         VALUES ($1, $2, $3, $4, $5, $6, $7)`,
        [idUsuario, tipo, titulo, cuerpo || null, refTipo, refId, avatar]
    );
}

async function usernameDe(idUsu) {
    const r = await pool.query(
        'SELECT username_usu FROM usuarios WHERE id_usu = $1',
        [idUsu]
    );
    return r.rows[0]?.username_usu || 'Un usuario';
}

module.exports = { crearNotificacion, usernameDe };
