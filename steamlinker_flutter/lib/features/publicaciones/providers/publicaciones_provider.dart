// Maneja el estado de publicaciones y busqueda con filtros

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class PublicacionesProvider extends ChangeNotifier {
  bool _cargando = false;
  String? _error;
  List<dynamic> _publicaciones = [];
  int _total = 0;

  bool get cargando => _cargando;
  String? get error => _error;
  List<dynamic> get publicaciones => _publicaciones;
  int get total => _total;

  // Buscar publicaciones con filtros opcionales
  Future<void> buscar({
    String? tipo,
    String? pais,
    int? appid,
    String orden = 'recientes',
  }) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final params = <String, dynamic>{};
      if (tipo != null) params['tipo'] = tipo;
      if (pais != null) params['pais'] = pais;
      if (appid != null) params['appid'] = appid;
      params['orden'] = orden;

      final respuesta = await ApiClient.dio.get(
        '/publicaciones/buscar',
        queryParameters: params,
      );

      _publicaciones = respuesta.data['publicaciones'] ?? [];
      _total = respuesta.data['total'] ?? 0;
      _cargando = false;
      notifyListeners();
    } on DioException catch (e) {
      _error = e.response?.data['error'] ?? 'Error al buscar publicaciones';
      _cargando = false;
      notifyListeners();
    }
  }

  // Crear una nueva publicacion
  Future<bool> crear({
    required String tipo,
    required String titulo,
    String? descripcion,
    String? pais,
    List<Map<String, dynamic>> juegos = const [],
  }) async {
    try {
      await ApiClient.dio.post('/publicaciones/crear', data: {
        'tipo': tipo,
        'titulo': titulo,
        'descripcion': descripcion,
        'pais': pais,
        'juegos': juegos,
      });
      await buscar();
      return true;
    } on DioException catch (e) {
      _error = e.response?.data['error'] ?? 'Error al crear publicacion';
      notifyListeners();
      return false;
    }
  }

  // Cerrar una publicacion
  Future<bool> cerrar(int id) async {
    try {
      await ApiClient.dio.put('/publicaciones/$id/cerrar');
      _publicaciones.removeWhere((p) => p['id_publi'] == id);
      _total--;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _error = e.response?.data['error'] ?? 'Error al cerrar publicacion';
      notifyListeners();
      return false;
    }
  }
}