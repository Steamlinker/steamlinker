// Conexion a PostgreSQL usando el modulo pg
// Este archivo exporta un pool de conexiones que se reutiliza en toda la app

const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
    host:     process.env.DB_HOST,
    port:     process.env.DB_PORT,
    database: process.env.DB_NAME,
    user:     process.env.DB_USER,
    password: process.env.DB_PASSWORD,
});

// Verificar que la conexion funciona al iniciar
pool.connect((err, client, release) => {
    if (err) {
        console.log('Error conectando a PostgreSQL:', err.message);
    } else {
        console.log('Conexion a PostgreSQL exitosa');
        release();
    }
});

module.exports = pool;

