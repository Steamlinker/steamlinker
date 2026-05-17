// Maneja el estado de publicaciones y busqueda con filtros

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/publicacion_constants.dart';
import '../../../core/network/api_client.dart';

class PublicacionesProvider extends ChangeNotifier {
  bool _cargando = false;
  String? _error;
  List<dynamic> _publicaciones = [];
  int _total = 0;

  String? _filtroTipo;
  String? _filtroPais;
  int? _filtroAppid;
  String? _filtroJuegoNombre;
  String _filtroOrden = PublicacionConstants.ordenRecientes;

  bool get cargando => _cargando;
  String? get error => _error;
  List<dynamic> get publicaciones => _publicaciones;
  int get total => _total;

  String? get filtroTipo => _filtroTipo;
  String? get filtroPais => _filtroPais;
  int? get filtroAppid => _filtroAppid;
  String? get filtroJuegoNombre => _filtroJuegoNombre;
  String get filtroOrden => _filtroOrden;

  bool get tieneFiltrosActivos =>
      (_filtroTipo != null && _filtroTipo!.isNotEmpty) ||
      (_filtroPais != null && _filtroPais!.isNotEmpty) ||
      _filtroAppid != null ||
      _filtroOrden != PublicacionConstants.ordenRecientes;

  Future<void> setFiltros({
    String? tipo,
    String? pais,
    int? appid,
    String? juegoNombre,
    String? orden,
  }) async {
    _filtroTipo = tipo != null && tipo.isEmpty ? null : tipo;
    _filtroPais = pais != null && pais.isEmpty ? null : pais;
    _filtroAppid = appid;
    _filtroJuegoNombre = juegoNombre;
    if (orden != null) _filtroOrden = orden;
    await buscar();
  }

  Future<void> limpiarFiltros() async {
    _filtroTipo = null;
    _filtroPais = null;
    _filtroAppid = null;
    _filtroJuegoNombre = null;
    _filtroOrden = PublicacionConstants.ordenRecientes;
    await buscar();
  }

  Future<void> buscar() async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final params = <String, dynamic>{'orden': _filtroOrden};
      if (_filtroTipo != null && _filtroTipo!.isNotEmpty) {
        params['tipo'] = _filtroTipo;
      }
      if (_filtroPais != null && _filtroPais!.isNotEmpty) {
        params['pais'] = _filtroPais;
      }
      if (_filtroAppid != null) params['appid'] = _filtroAppid;

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

  Future<bool> crear({
    required String tipo,
    required String titulo,
    String? descripcion,
    String? pais,
    List<Map<String, dynamic>> juegos = const [],
  }) async {
    _error = null;
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
