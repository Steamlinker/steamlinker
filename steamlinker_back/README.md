# 🎮 Steamlinker — Backend (Node.js + Express)

## Instalación rápida

```bash
# 1. Instalar dependencias
npm install

# 2. Crear tu archivo de variables de entorno
cp .env.example .env

# 3. Editar .env con tu API key de Steam
#    → Consíguela gratis en: https://steamcommunity.com/dev/apikey

# 4. Correr en desarrollo
npm run dev
```

> Nota: el archivo `.env` no debe subirse a GitHub. Usa `.env.example` para compartir los nombres de las variables, pero guarda los valores reales en privado.

---

## Estructura del proyecto

```
src/
├── index.js               # Entrada principal
├── routes/
│   ├── auth.js            # Login con Steam OpenID
│   ├── games.js           # Biblioteca y comparación de juegos
│   └── users.js           # Perfiles de usuario
└── services/
    └── steamService.js    # TODAS las llamadas a Steam API
```

---

## Endpoints

| Método | Ruta                        | Descripción                              | Auth |
|--------|-----------------------------|------------------------------------------|------|
| GET    | `/health`                   | Verificar que el servidor corre          | No   |
| GET    | `/auth/steam`               | Iniciar login con Steam                  | No   |
| GET    | `/auth/steam/callback`      | Steam redirige aquí tras login           | No   |
| GET    | `/auth/me`                  | Usuario de la sesión actual              | Sí   |
| GET    | `/auth/logout`              | Cerrar sesión                            | Sí   |
| GET    | `/users/me`                 | Mi perfil + total de juegos              | Sí   |
| GET    | `/users/profile/:steamid`   | Perfil público de cualquier usuario      | Sí   |
| GET    | `/games/library`            | Mi biblioteca completa                   | Sí   |
| GET    | `/games/library/:steamid`   | Biblioteca de otro usuario               | Sí   |
| GET    | `/games/compare/:steamid`   | Juegos en común (para matchmaking)       | Sí   |
| GET    | `/games/achievements/:appid`| Mis logros en un juego                   | Sí   |

---

## Flujo de autenticación

```
1. Frontend redirige al usuario → GET /auth/steam
2. Steam muestra su pantalla de login (Valve lo maneja todo)
3. Steam redirige de vuelta → GET /auth/steam/callback
4. El servidor guarda el usuario en sesión
5. Frontend puede llamar /auth/me para obtener los datos del usuario
```

---

## Ejemplo de respuesta — /games/library

```json
{
  "total": 247,
  "games": [
    {
      "appid": 814380,
      "name": "Sekiro: Shadows Die Twice",
      "hoursPlayed": 85,
      "headerImg": "https://cdn.cloudflare.steamstatic.com/steam/apps/814380/header.jpg",
      "capsuleImg": "https://cdn.cloudflare.steamstatic.com/steam/apps/814380/capsule_231x87.jpg"
    }
  ]
}
```

---

## Ejemplo de respuesta — /games/compare/:steamid

```json
{
  "commonCount": 12,
  "totalA": 247,
  "totalB": 183,
  "commonGames": [
    { "appid": 814380, "name": "Sekiro", "hoursPlayed": 85, ... }
  ]
}
```

---

## Notas importantes

- **La API key va SOLO en el `.env`** — nunca la incluyas en el frontend ni en GitHub
- **El perfil de Steam del usuario debe ser público** para leer su biblioteca
- En producción: cambia `cookie.secure` a `true` y usa HTTPS
- Agrega `.env` a tu `.gitignore`
