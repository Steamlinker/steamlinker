import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class ReportesProvider extends ChangeNotifier {
  String? _error;

  String? get error => _error;

  Future<bool> crear({
    required int idReportado,
    required String motivo,
  }) async {
    _error = null;
    try {
      await ApiClient.dio.post('/reportes/crear', data: {
        'id_reportado': idReportado,
        'motivo': motivo,
      });
      return true;
    } on DioException catch (e) {
      _error = ApiClient.errorMessage(e, fallback: 'Error al enviar reporte');
      notifyListeners();
      return false;
    }
  }
}
