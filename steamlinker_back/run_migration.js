// Ejecutar migraciones SQL en db_migrations/
const pool = require('./src/db');
const fs = require('fs');
const path = require('path');

async function runMigrations() {
  const dir = path.join(__dirname, 'db_migrations');
  const files = fs
    .readdirSync(dir)
    .filter((f) => f.endsWith('.sql'))
    .sort();

  try {
    console.log('Ejecutando migraciones...');
    for (const file of files) {
      const sql = fs.readFileSync(path.join(dir, file), 'utf8');
      await pool.query(sql);
      console.log(`✓ ${file}`);
    }
    console.log('Migraciones completadas.');
    process.exit(0);
  } catch (err) {
    console.error('✗ Error en migración:', err.message);
    process.exit(1);
  }
}

runMigrations();
