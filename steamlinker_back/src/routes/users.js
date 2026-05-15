// src/routes/users.js
// 
//  Endpoints de perfiles de usuario (datos de Steam).
// 

const express      = require("express");
const steamService = require("../services/steamService");

const router = express.Router();

function requireAuth(req, res, next) {
  if (!req.user) return res.status(401).json({ error: "No autenticado" });
  next();
}

/**
 * GET /users/profile/:steamid
 * Devuelve el perfil público de Steam de cualquier usuario.
 * 
 * Respuesta ejemplo:
 * {
 *   steamid: "76561198XXXXX",
 *   username: "gamer123",
 *   avatar: "https://...",
 *   country: "CO",
 *   isPublic: true
 * }
 */
router.get("/profile/:steamid", requireAuth, async (req, res) => {
  try {
    const profile = await steamService.getUserProfile(req.params.steamid);
    res.json(profile);
  } catch (err) {
    res.status(404).json({ error: err.message });
  }
});

/**
 * GET /users/me
 * Perfil del usuario actualmente logueado.
 */
router.get("/me", requireAuth, async (req, res) => {
  try {
    const profile = await steamService.getUserProfile(req.user.steamid);
    const games   = await steamService.getOwnedGames(req.user.steamid);
    res.json({ ...profile, totalGames: games.length });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
