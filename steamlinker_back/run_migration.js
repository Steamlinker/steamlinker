// Ejecutar migraciones SQL
const pool = require('./src/db');
const fs = require('fs');
const path = require('path');

async function runMigrations() {
  try {
    console.log('Ejecutando migraciones...');

    // Leer el archivo de migración
    const migrationFile = path.join(__dirname, 'db_migrations', '002_add_privacy_settings.sql');
    const sql = fs.readFileSync(migrationFile, 'utf8');

    // Ejecutar la migración
    await pool.query(sql);
    console.log('✓ Migración ejecutada exitosamente');
    process.exit(0);
  } catch (err) {
    console.error('✗ Error en migración:', err.message);
    process.exit(1);
  }
}

runMigrations();
