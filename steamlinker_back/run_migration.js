// Ejecutar migraciones SQL en db_migrations/
// Uso: node run_migration.js
const { runMigrations } = require('./src/migrate');

runMigrations()
    .then(() => {
        console.log('Migraciones completadas.');
        process.exit(0);
    })
    .catch((err) => {
        console.error('Error en migración:', err.message);
        process.exit(1);
    });
