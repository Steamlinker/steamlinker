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
      _error = e.response?.data['error'] ?? 'Error al cargar matches';
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
      _error = e.response?.data['error'] ?? 'Error al cargar matches';
      _cargando = false;
      notifyListeners();
    }
  }

  // Enviar solicitud de match
  Future<bool> enviar(int idReceptor, {int? idPubli}) async {
    try {
      await ApiClient.dio.post('/matches/enviar', data: {
        'id_receptor': idReceptor,
        'id_publi': idPubli,
      });
      await cargarEnviados();
      return true;
    } on DioException catch (e) {
      _error = e.response?.data['error'] ?? 'Error al enviar match';
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
      _error = e.response?.data['error'] ?? 'Error al responder match';
      notifyListeners();
      return false;
    }
  }
}