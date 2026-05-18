import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class AmistadProvider extends ChangeNotifier {
  bool _cargando = false;
  String? _error;
  List<dynamic> _solicitudes = [];
  List<dynamic> _amigos = [];

  bool get cargando => _cargando;
  String? get error => _error;
  List<dynamic> get solicitudes => _solicitudes;
  List<dynamic> get amigos => _amigos;

  Future<void> cargarSolicitudes() async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final respuesta = await ApiClient.dio.get('/amistad/solicitudes');
      _solicitudes = respuesta.data['solicitudes'] ?? [];
      _cargando = false;
      notifyListeners();
    } on DioException catch (e) {
      _error = ApiClient.errorMessage(e, fallback: 'Error al cargar solicitudes');
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> cargarAmigos() async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final respuesta = await ApiClient.dio.get('/amistad/amigos');
      _amigos = respuesta.data['amigos'] ?? [];
      _cargando = false;
      notifyListeners();
    } on DioException catch (e) {
      _error = ApiClient.errorMessage(e, fallback: 'Error al cargar amigos');
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> cargarTodo() async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        ApiClient.dio.get('/amistad/solicitudes'),
        ApiClient.dio.get('/amistad/amigos'),
      ]);
      _solicitudes = results[0].data['solicitudes'] ?? [];
      _amigos = results[1].data['amigos'] ?? [];
      _cargando = false;
      notifyListeners();
    } on DioException catch (e) {
      _error = ApiClient.errorMessage(e, fallback: 'Error al cargar amistades');
      _cargando = false;
      notifyListeners();
    }
  }

  Future<bool> enviar(int idReceptor) async {
    _error = null;
    try {
      await ApiClient.dio.post('/amistad/enviar', data: {'id_receptor': idReceptor});
      await cargarTodo();
      return true;
    } on DioException catch (e) {
      _error = ApiClient.errorMessage(e, fallback: 'Error al enviar solicitud');
      notifyListeners();
      return false;
    }
  }

  Future<bool> responder(int idAmistad, String estado) async {
    _error = null;
    try {
      await ApiClient.dio.put('/amistad/$idAmistad/responder', data: {'estado': estado});
      await cargarTodo();
      return true;
    } on DioException catch (e) {
      _error = ApiClient.errorMessage(e, fallback: 'Error al responder solicitud');
      notifyListeners();
      return false;
    }
  }
}
