// src/services/steamService.js
// ─────────────────────────────────────────────────────────────
//  Todas las llamadas a la Steam Web API van aquí.
//  El resto de la app NO llama directo a Steam — solo este archivo.
// ─────────────────────────────────────────────────────────────

const axios = require("axios");

const STEAM_API  = "https://api.steampowered.com";
const STEAM_CDN  = "https://cdn.cloudflare.steamstatic.com/steam/apps";
const API_KEY    = process.env.STEAM_API_KEY;

// ── Helpers ────────────────────────────────────────────────────

/** URL de la imagen header de un juego (460x215) */
function gameHeaderImg(appid) {
  return `${STEAM_CDN}/${appid}/header.jpg`;
}

/** URL del capsule pequeño de un juego (231x87) */
function gameCapsuleImg(appid) {
  return `${STEAM_CDN}/${appid}/capsule_231x87.jpg`;
}

// ── 1. PERFIL DE USUARIO ────────────────────────────────────────

/**
 * Obtiene el perfil público de un usuario de Steam.
 * @param {string} steamid  - steamid64 del usuario
 * @returns {Object} datos del perfil
 */
async function getUserProfile(steamid) {
  const { data } = await axios.get(
    `${STEAM_API}/ISteamUser/GetPlayerSummaries/v2/`,
    { params: { key: API_KEY, steamids: steamid } }
  );

  const player = data.response.players[0];
  if (!player) throw new Error("Usuario no encontrado");

  return {
    steamid:       player.steamid,
    username:      player.personaname,
    avatar:        player.avatarfull,
    profileUrl:    player.profileurl,
    country:       player.loccountrycode || null,
    // 3 = perfil público | 1 = privado
    isPublic:      player.communityvisibilitystate === 3,
  };
}

// ── 2. BIBLIOTECA DE JUEGOS ─────────────────────────────────────

/**
 * Obtiene todos los juegos que posee un usuario.
 * IMPORTANTE: el perfil del usuario debe ser público.
 * @param {string} steamid
 * @returns {Array} lista de juegos con nombre, horas e imágenes
 */
async function getOwnedGames(steamid) {
  const { data } = await axios.get(
    `${STEAM_API}/IPlayerService/GetOwnedGames/v1/`,
    {
      params: {
        key:                    API_KEY,
        steamid:                steamid,
        include_appinfo:        true,   // trae nombre e icono
        include_played_free_games: true,
      },
    }
  );

  const games = data.response.games || [];

  // Formatear y enriquecer con URLs de imágenes
  return games
    .map((g) => ({
      appid:       g.appid,
      name:        g.name,
      hoursPlayed: Math.round(g.playtime_forever / 60), // minutos → horas
      headerImg:   gameHeaderImg(g.appid),
      capsuleImg:  gameCapsuleImg(g.appid),
    }))
    .sort((a, b) => b.hoursPlayed - a.hoursPlayed); // ordenar por horas
}

// ── 3. JUEGOS EN COMÚN ENTRE DOS USUARIOS ──────────────────────

/**
 * Compara las bibliotecas de dos usuarios y devuelve los juegos compartidos.
 * Útil para el sistema de matchmaking de familias.
 * @param {string} steamidA
 * @param {string} steamidB
 * @returns {Object} { commonGames, totalA, totalB }
 */
async function getCommonGames(steamidA, steamidB) {
  const [gamesA, gamesB] = await Promise.all([
    getOwnedGames(steamidA),
    getOwnedGames(steamidB),
  ]);

  const setB = new Set(gamesB.map((g) => g.appid));

  const commonGames = gamesA.filter((g) => setB.has(g.appid));

  return {
    commonGames,
    totalA:      gamesA.length,
    totalB:      gamesB.length,
    commonCount: commonGames.length,
  };
}

// ── 4. LOGROS DE UN JUEGO ────────────────────────────────────────

/**
 * Obtiene los logros del usuario en un juego específico.
 * @param {string} steamid
 * @param {number} appid
 */
async function getPlayerAchievements(steamid, appid) {
  const { data } = await axios.get(
    `${STEAM_API}/ISteamUserStats/GetPlayerAchievements/v1/`,
    { params: { key: API_KEY, steamid, appid } }
  );

  const stats = data.playerstats;
  if (!stats.success) throw new Error("No se pueden leer los logros (perfil privado o juego sin logros)");

  const achievements = stats.achievements || [];
  const unlocked = achievements.filter((a) => a.achieved === 1);

  return {
    gameName:   stats.gameName,
    total:      achievements.length,
    unlocked:   unlocked.length,
    percentage: achievements.length
      ? Math.round((unlocked.length / achievements.length) * 100)
      : 0,
  };
}

module.exports = {
  getUserProfile,
  getOwnedGames,
  getCommonGames,
  getPlayerAchievements,
  gameHeaderImg,
};
