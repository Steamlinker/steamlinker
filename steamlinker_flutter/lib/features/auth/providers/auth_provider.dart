// Maneja el estado de autenticacion de toda la app
// Login, registro y cierre de sesion

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';

class AuthProvider extends ChangeNotifier {
  bool _cargando = false;
  String? _error;
  bool _autenticado = false;
  Map<String, dynamic>? _usuario;

  bool get cargando => _cargando;
  String? get error => _error;
  bool get autenticado => _autenticado;
  Map<String, dynamic>? get usuario => _usuario;

  // Verificar si hay sesion activa al iniciar la app
  Future<void> verificarSesion() async {
    final hayToken = await TokenStorage.haySession();
    if (hayToken) {
      try {
        final respuesta = await ApiClient.dio.get('/auth/perfil');
        _usuario = respuesta.data;
        _autenticado = true;
      } catch (e) {
        await TokenStorage.eliminarToken();
        _autenticado = false;
      }
    }
    notifyListeners();
  }

  // Registrar un nuevo usuario
  Future<bool> registrar({
    required String username,
    required String email,
    required String password,
    String? pais,
  }) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final respuesta = await ApiClient.dio.post('/auth/registro', data: {
        'username': username,
        'email': email,
        'password': password,
        'pais': pais,
      });

      final token = respuesta.data['token'];
      final usuario = respuesta.data['usuario'];

      await TokenStorage.guardarToken(token, usuario['id']);
      _usuario = usuario;
      _autenticado = true;
      _cargando = false;
      notifyListeners();
      return true;

    } on DioException catch (e) {
      _error = e.response?.data['error'] ?? e.message ?? 'Error al registrarse';
      _cargando = false;
      notifyListeners();
      return false;
    }
  }

  // Iniciar sesion
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final respuesta = await ApiClient.dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final token = respuesta.data['token'];
      final usuario = respuesta.data['usuario'];

      await TokenStorage.guardarToken(token, usuario['id']);
      _usuario = usuario;
      _autenticado = true;
      _cargando = false;
      notifyListeners();
      return true;

    } on DioException catch (e) {
      _error = e.response?.data['error'] ?? e.message ?? 'Error al iniciar sesion';
      _cargando = false;
      notifyListeners();
      return false;
    }
  }

  // Cerrar sesion
  Future<void> logout() async {
    await TokenStorage.eliminarToken();
    _usuario = null;
    _autenticado = false;
    notifyListeners();
  }
}