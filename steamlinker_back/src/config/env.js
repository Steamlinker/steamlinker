// Validación de variables de entorno al arranque

if (!process.env.NODE_ENV) {
    process.env.NODE_ENV = 'development';
}

const REQUIRED_ALWAYS = ['DB_HOST', 'DB_NAME', 'DB_USER', 'DB_PASSWORD'];

const REQUIRED_PRODUCTION = ['JWT_SECRET', 'STEAM_API_KEY'];

function isProduction() {
    return process.env.NODE_ENV === 'production';
}

function validateEnv() {
    const missing = [];

    for (const key of REQUIRED_ALWAYS) {
        if (!process.env[key] || String(process.env[key]).trim() === '') {
            missing.push(key);
        }
    }

    if (isProduction()) {
        for (const key of REQUIRED_PRODUCTION) {
            if (!process.env[key] || String(process.env[key]).trim() === '') {
                missing.push(key);
            }
        }

        if (!process.env.CORS_ORIGINS || process.env.CORS_ORIGINS.trim() === '') {
            console.warn(
                '[env] CORS_ORIGINS vacío en producción: solo se permitirá el mismo origen del APP_URL.'
            );
        }

        if (process.env.JWT_SECRET && process.env.JWT_SECRET.length < 32) {
            console.warn('[env] JWT_SECRET debería tener al menos 32 caracteres en producción.');
        }
    }

    if (!process.env.JWT_SECRET && !isProduction()) {
        console.warn('[env] JWT_SECRET no definido: login y rutas protegidas fallarán.');
    }

    if (missing.length > 0) {
        throw new Error(`Variables de entorno obligatorias faltantes: ${missing.join(', ')}`);
    }
}

function parseCorsOrigins() {
    const raw = process.env.CORS_ORIGINS;
    if (raw && raw.trim()) {
        return raw.split(',').map((o) => o.trim()).filter(Boolean);
    }

    if (process.env.APP_URL) {
        return [process.env.APP_URL.trim()];
    }

    if (isProduction()) {
        return [];
    }

    // Desarrollo: cualquier origen (Flutter web, emulador, IP LAN del móvil)
    return null;
}

module.exports = { validateEnv, parseCorsOrigins, isProduction };
