// Ejecuta migraciones SQL pendientes en db_migrations/
const fs = require('fs');
const path = require('path');
const pool = require('./db');

async function ensureMigrationsTable() {
    await pool.query(`
        CREATE TABLE IF NOT EXISTS schema_migrations (
            filename VARCHAR(255) PRIMARY KEY,
            aplicada_en TIMESTAMP DEFAULT NOW()
        )
    `);
}

async function runMigrations() {
    const dir = path.join(__dirname, '..', 'db_migrations');
    if (!fs.existsSync(dir)) {
        console.warn('Carpeta db_migrations no encontrada, se omiten migraciones.');
        return;
    }

    await ensureMigrationsTable();

    const files = fs
        .readdirSync(dir)
        .filter((f) => f.endsWith('.sql'))
        .sort();

    for (const file of files) {
        const ya = await pool.query(
            'SELECT 1 FROM schema_migrations WHERE filename = $1',
            [file]
        );
        if (ya.rows.length > 0) continue;

        const sql = fs.readFileSync(path.join(dir, file), 'utf8');
        await pool.query(sql);
        await pool.query(
            'INSERT INTO schema_migrations (filename) VALUES ($1)',
            [file]
        );
        console.log(`Migración aplicada: ${file}`);
    }
}

module.exports = { runMigrations };
