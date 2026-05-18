import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../models/notification_model.dart';

class NotificacionesProvider extends ChangeNotifier {
  bool _cargando = false;
  String? _error;
  List<NotificationModel> _notificaciones = [];
  int _noLeidas = 0;

  bool get cargando => _cargando;
  String? get error => _error;
  List<NotificationModel> get notificaciones => _notificaciones;
  int get noLeidas => _noLeidas;

  Future<void> cargarContador() async {
    try {
      final respuesta = await ApiClient.dio.get('/notificaciones/contador');
      _noLeidas = respuesta.data['no_leidas'] ?? 0;
      notifyListeners();
    } on DioException {
      // silencioso para badge
    }
  }

  Future<void> cargar({String? filtro}) async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final params = <String, dynamic>{};
      if (filtro == 'no_leidas') params['filtro'] = 'no_leidas';
      if (filtro == 'interesantes') params['filtro'] = 'interesantes';

      final respuesta = await ApiClient.dio.get(
        '/notificaciones',
        queryParameters: params.isEmpty ? null : params,
      );

      final lista = respuesta.data['notificaciones'] as List<dynamic>? ?? [];
      _notificaciones = lista
          .map((n) => NotificationModel.fromApi(Map<String, dynamic>.from(n as Map)))
          .toList();
      _noLeidas = respuesta.data['no_leidas'] ?? 0;
      _cargando = false;
      notifyListeners();
    } on DioException catch (e) {
      _error = ApiClient.errorMessage(e, fallback: 'Error al cargar notificaciones');
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> marcarLeida(String id, bool leida) async {
    try {
      await ApiClient.dio.put('/notificaciones/$id/leida', data: {'leida': leida});
      final i = _notificaciones.indexWhere((n) => n.id == id);
      if (i >= 0) {
        _notificaciones[i].isRead = leida;
        _noLeidas = _notificaciones.where((n) => !n.isRead).length;
        notifyListeners();
      }
      await cargarContador();
    } on DioException catch (e) {
      _error = ApiClient.errorMessage(e, fallback: 'Error');
      notifyListeners();
    }
  }

  Future<void> marcarTodasLeidas() async {
    try {
      await ApiClient.dio.put('/notificaciones/leer-todas');
      for (final n in _notificaciones) {
        n.isRead = true;
      }
      _noLeidas = 0;
      notifyListeners();
    } on DioException catch (e) {
      _error = ApiClient.errorMessage(e, fallback: 'Error');
      notifyListeners();
    }
  }

  Future<void> marcarInteres(String id, bool? interes) async {
    try {
      await ApiClient.dio.put('/notificaciones/$id/interes', data: {
        'interes': interes,
      });
      final i = _notificaciones.indexWhere((n) => n.id == id);
      if (i >= 0) {
        _notificaciones[i].interested = interes;
        notifyListeners();
      }
    } on DioException catch (e) {
      _error = ApiClient.errorMessage(e, fallback: 'Error');
      notifyListeners();
    }
  }
}
