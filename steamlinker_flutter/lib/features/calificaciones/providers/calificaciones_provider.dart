import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class CalificacionesProvider extends ChangeNotifier {
  String? _error;

  String? get error => _error;

  Future<bool> crear({
    required int idMatch,
    required int idCalificado,
    required double estrellas,
    bool? confiable,
    String? comentario,
  }) async {
    _error = null;
    try {
      await ApiClient.dio.post('/calificaciones/crear', data: {
        'id_match': idMatch,
        'id_calificado': idCalificado,
        'estrellas': estrellas,
        'confiable': confiable,
        'comentario': comentario,
      });
      return true;
    } on DioException catch (e) {
      _error = e.response?.data['error'] ?? 'Error al calificar';
      notifyListeners();
      return false;
    }
  }
}
