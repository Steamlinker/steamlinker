// Maneja el estado del perfil de usuario
// Carga perfil, edita datos y gestiona juegos

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class PerfilProvider extends ChangeNotifier {
  bool _cargando = false;
  String? _error;
  Map<String, dynamic>? _perfil;
  List<dynamic> _juegos = [];

  bool get cargando => _cargando;
  String? get error => _error;
  Map<String, dynamic>? get perfil => _perfil;
  List<dynamic> get juegos => _juegos;

  // Cargar perfil de cualquier usuario por id
  Future<void> cargarPerfil(int id) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final respuesta = await ApiClient.dio.get('/perfil/$id');
      _perfil = respuesta.data;
      _juegos = respuesta.data['juegos'] ?? [];
      _cargando = false;
      notifyListeners();
    } on DioException catch (e) {
      _error = e.response?.data['error'] ?? 'Error al cargar perfil';
      _cargando = false;
      notifyListeners();
    }
  }

  // Editar descripcion y pais del perfil propio
  Future<bool> editarPerfil({String? descripcion, String? pais}) async {
    try {
      final respuesta = await ApiClient.dio.put('/perfil/editar', data: {
        'descripcion': descripcion,
        'pais': pais,
      });
      _perfil = {...?_perfil, ...respuesta.data};
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _error = e.response?.data['error'] ?? 'Error al editar perfil';
      notifyListeners();
      return false;
    }
  }

  // Buscar juegos en Steam Store API
  Future<List<dynamic>> buscarJuegos(String query) async {
    try {
      final respuesta = await ApiClient.dio.get(
        '/perfil/juegos/buscar',
        queryParameters: {'q': query},
      );
      return respuesta.data['juegos'] ?? [];
    } on DioException {
      return [];
    }
  }

  // Agregar juego al perfil
  Future<bool> agregarJuego(Map<String, dynamic> juego) async {
    try {
      await ApiClient.dio.post('/perfil/juegos/agregar', data: juego);
      await cargarPerfil(_perfil!['id_usu']);
      return true;
    } on DioException catch (e) {
      _error = e.response?.data['error'] ?? 'Error al agregar juego';
      notifyListeners();
      return false;
    }
  }

  // Eliminar juego del perfil
  Future<bool> eliminarJuego(int appid) async {
    try {
      await ApiClient.dio.delete('/perfil/juegos/$appid');
      _juegos.removeWhere((j) => j['appid'] == appid);
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _error = e.response?.data['error'] ?? 'Error al eliminar juego';
      notifyListeners();
      return false;
    }
  }
}