// Manejo del token JWT en el almacenamiento local
// Guarda, lee y elimina el token del dispositivo

import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const String _tokenKey = 'token';
  static const String _usuarioKey = 'usuario_id';

  // Guardar token despues del login
  static Future<void> guardarToken(String token, int usuarioId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setInt(_usuarioKey, usuarioId);
  }

  // Leer el token guardado
  static Future<String?> obtenerToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Leer el id del usuario guardado
  static Future<int?> obtenerUsuarioId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_usuarioKey);
  }

  // Eliminar token al cerrar sesion
  static Future<void> eliminarToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_usuarioKey);
  }

  // Verificar si hay sesion activa
  static Future<bool> haySession() async {
    final token = await obtenerToken();
    return token != null;
  }
}
