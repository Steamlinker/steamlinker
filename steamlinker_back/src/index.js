// Punto de entrada del servidor Steamlinker

require('dotenv').config();
require('./db');

const os = require('os');
const path = require('path');
const express = require('express');
const cors = require('cors');
const pool = require('./db');
const adminRoutes = require('./routes/admin');
const { validateEnv, parseCorsOrigins, isProduction } = require('./config/env');
const { securityHeaders } = require('./middleware/security');
const { runMigrations } = require('./migrate');

const { router: authRoutes } = require('./routes/auth');
const perfilRoutes = require('./routes/perfil');
const publicacionesRoutes = require('./routes/publicaciones');
const matchesRoutes = require('./routes/matches');
const chatRoutes = require('./routes/chat');
const calificacionesRoutes = require('./routes/calificaciones');
const reportesRoutes = require('./routes/reportes');
const amistadRoutes = require('./routes/amistad');
const notificacionesRoutes = require('./routes/notificaciones');

validateEnv();

const app = express();
const PORT = process.env.PORT || 3000;
const corsOrigins = parseCorsOrigins();

if (isProduction()) {
    app.set('trust proxy', 1);
}

app.use(securityHeaders);

app.use(
    cors({
        origin(origin, callback) {
            if (!origin) return callback(null, true);
            if (!isProduction()) return callback(null, true);
            if (!corsOrigins || corsOrigins.length === 0) {
                return callback(null, false);
            }
            if (corsOrigins.includes(origin)) {
                return callback(null, true);
            }
            return callback(null, false);
        },
        credentials: true,
    })
);

app.use(express.json({ limit: '1mb' }));

app.use('/admin', express.static(path.join(__dirname, '../public/admin')));

app.use('/auth', authRoutes);
app.use('/perfil', perfilRoutes);
app.use('/publicaciones', publicacionesRoutes);
app.use('/matches', matchesRoutes);
app.use('/chat', chatRoutes);
app.use('/calificaciones', calificacionesRoutes);
app.use('/reportes', reportesRoutes);
app.use('/amistad', amistadRoutes);
app.use('/notificaciones', notificacionesRoutes);
app.use('/api/admin', adminRoutes);

app.get('/health', async (req, res) => {
    try {
        await pool.query('SELECT 1');
        res.json({
            status: 'ok',
            environment: process.env.NODE_ENV || 'development',
            database: 'connected',
            timestamp: new Date().toISOString(),
        });
    } catch (err) {
        res.status(503).json({
            status: 'degraded',
            database: 'disconnected',
            error: isProduction() ? 'Database unavailable' : err.message,
        });
    }
});

async function start() {
    try {
        await runMigrations();
    } catch (err) {
        console.error('Error al ejecutar migraciones:', err.message);
        process.exit(1);
    }

    const host = process.env.HOST || '0.0.0.0';

    const server = app.listen(PORT, host, () => {
        const env = process.env.NODE_ENV || 'development';
        console.log(`Steamlinker API en http://localhost:${PORT} (${env})`);
        if (isProduction() && corsOrigins && corsOrigins.length > 0) {
            console.log('CORS permitidos:', corsOrigins.join(', '));
        } else if (!isProduction()) {
            console.log('CORS: todos los orígenes (solo desarrollo)');
            const lan = getLanAddresses();
            if (lan.length > 0) {
                console.log('Red local (móvil físico):');
                for (const ip of lan) {
                    console.log(`  http://${ip}:${PORT}`);
                }
            }
            console.log('Emulador Android → http://10.0.2.2:' + PORT);
        }
        console.log('GET /health');
        if (!isProduction()) {
            console.log(`Panel admin: http://localhost:${PORT}/admin/`);
        }
    });

    server.on('error', (err) => {
        if (err.code === 'EADDRINUSE') {
            console.error(`\nPuerto ${PORT} ya en uso (otra instancia del backend u otro proceso).`);
            console.error('  Cierra la otra terminal con npm run dev / npm start, o ejecuta:');
            console.error(`  netstat -ano | findstr :${PORT}`);
            console.error('  taskkill /PID <pid> /F');
            console.error(`  También puedes cambiar PORT en .env\n`);
            process.exit(1);
        }
        console.error(err);
        process.exit(1);
    });
}

function getLanAddresses() {
    const ips = [];
    for (const iface of Object.values(os.networkInterfaces())) {
        for (const addr of iface || []) {
            if (addr.family === 'IPv4' && !addr.internal) {
                ips.push(addr.address);
            }
        }
    }
    return ips;
}

start();
