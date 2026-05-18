// Maneja el estado del sistema de matches

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class MatchesProvider extends ChangeNotifier {
  bool _cargando = false;
  String? _error;
  List<dynamic> _recibidos = [];
  List<dynamic> _enviados = [];

  bool get cargando => _cargando;
  String? get error => _error;
  List<dynamic> get recibidos => _recibidos;
  List<dynamic> get enviados => _enviados;

  Future<void> cargarTodo() async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        ApiClient.dio.get('/matches/recibidos'),
        ApiClient.dio.get('/matches/enviados'),
      ]);
      _recibidos = results[0].data['matches'] ?? [];
      _enviados = results[1].data['matches'] ?? [];
      _cargando = false;
      notifyListeners();
    } on DioException catch (e) {
      _error = ApiClient.errorMessage(e, fallback: 'Error al cargar matches');
      _cargando = false;
      notifyListeners();
    }
  }

  // Cargar matches recibidos
  Future<void> cargarRecibidos() async {
    _cargando = true;
    notifyListeners();

    try {
      final respuesta = await ApiClient.dio.get('/matches/recibidos');
      _recibidos = respuesta.data['matches'] ?? [];
      _cargando = false;
      notifyListeners();
    } on DioException catch (e) {
      _error = ApiClient.errorMessage(e, fallback: 'Error al cargar matches');
      _cargando = false;
      notifyListeners();
    }
  }

  // Cargar matches enviados
  Future<void> cargarEnviados() async {
    _cargando = true;
    notifyListeners();

    try {
      final respuesta = await ApiClient.dio.get('/matches/enviados');
      _enviados = respuesta.data['matches'] ?? [];
      _cargando = false;
      notifyListeners();
    } on DioException catch (e) {
      _error = ApiClient.errorMessage(e, fallback: 'Error al cargar matches');
      _cargando = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> consultarEstado(int otroId) async {
    try {
      final respuesta = await ApiClient.dio.get('/matches/estado/$otroId');
      return Map<String, dynamic>.from(respuesta.data as Map);
    } on DioException catch (e) {
      _error = ApiClient.errorMessage(e, fallback: 'Error al consultar estado');
      notifyListeners();
      return null;
    }
  }

  // Enviar solicitud de match
  Future<bool> enviar(int idReceptor, {int? idPubli}) async {
    try {
      await ApiClient.dio.post('/matches/enviar', data: {
        'id_receptor': idReceptor,
        'id_publi': idPubli,
      });
      await cargarTodo();
      return true;
    } on DioException catch (e) {
      _error = ApiClient.errorMessage(e, fallback: 'Error al enviar match');
      notifyListeners();
      return false;
    }
  }

  // Responder una solicitud de match
  Future<bool> responder(int idMatch, String estado) async {
    try {
      await ApiClient.dio.put('/matches/$idMatch/responder', data: {
        'estado': estado,
      });
      await cargarRecibidos();
      return true;
    } on DioException catch (e) {
      _error = ApiClient.errorMessage(e, fallback: 'Error al responder match');
      notifyListeners();
      return false;
    }
  }
}