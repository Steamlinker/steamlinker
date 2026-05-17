// Punto de entrada del servidor Steamlinker
// Configura Express, middlewares y rutas

require('dotenv').config();
require('./db');

const express = require('express');
const cors = require('cors');
const adminRoutes = require('./routes/admin');

const { router: authRoutes } = require('./routes/auth');
const perfilRoutes = require('./routes/perfil');
const publicacionesRoutes = require('./routes/publicaciones');
const matchesRoutes = require('./routes/matches');
const chatRoutes = require('./routes/chat');
const calificacionesRoutes = require('./routes/calificaciones');
const reportesRoutes = require('./routes/reportes');
const amistadRoutes = require('./routes/amistad');

const app = express();
const PORT = process.env.PORT || 3000;

// Middlewares globales
// Middlewares globales
app.use(cors({
    origin: '*',
    credentials: false
}));
app.use(express.json());

// Rutas
app.use('/auth', authRoutes);
app.use('/perfil', perfilRoutes);
app.use('/publicaciones', publicacionesRoutes);
app.use('/matches', matchesRoutes);
app.use('/chat', chatRoutes);
app.use('/calificaciones', calificacionesRoutes);
app.use('/reportes', reportesRoutes);
app.use('/amistad', amistadRoutes);
app.use('/api/admin', adminRoutes);
// Ruta de salud
app.get('/health', (req, res) => {
    res.json({ status: 'ok', message: 'Steamlinker API corriendo' });
});

app.listen(PORT, () => {
    console.log(`Steamlinker backend corriendo en http://localhost:${PORT}`);
    console.log('Endpoints disponibles:');
    console.log('  POST /auth/registro');
    console.log('  POST /auth/login');
    console.log('  GET  /auth/perfil');
    console.log('  GET  /health');
});

