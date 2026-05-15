// Maneja el estado del chat y mensajes

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class ChatProvider extends ChangeNotifier {
  bool _cargando = false;
  String? _error;
  List<dynamic> _conversaciones = [];
  List<dynamic> _mensajes = [];
  int? _chatActivo;

  bool get cargando => _cargando;
  String? get error => _error;
  List<dynamic> get conversaciones => _conversaciones;
  List<dynamic> get mensajes => _mensajes;
  int? get chatActivo => _chatActivo;

  // Cargar todas las conversaciones del usuario
  Future<void> cargarConversaciones() async {
    _cargando = true;
    notifyListeners();

    try {
      final respuesta = await ApiClient.dio.get('/chat/conversaciones');
      _conversaciones = respuesta.data['conversaciones'] ?? [];
      _cargando = false;
      notifyListeners();
    } on DioException catch (e) {
      _error = e.response?.data['error'] ?? 'Error al cargar conversaciones';
      _cargando = false;
      notifyListeners();
    }
  }

  // Cargar mensajes de una conversacion
  Future<void> cargarMensajes(int idChat) async {
    _chatActivo = idChat;
    _cargando = true;
    notifyListeners();

    try {
      final respuesta = await ApiClient.dio.get('/chat/$idChat/mensajes');
      _mensajes = respuesta.data['mensajes'] ?? [];
      _cargando = false;
      notifyListeners();
    } on DioException catch (e) {
      _error = e.response?.data['error'] ?? 'Error al cargar mensajes';
      _cargando = false;
      notifyListeners();
    }
  }

  // Enviar un mensaje
  Future<bool> enviarMensaje(int idChat, String mensaje) async {
    try {
      final respuesta = await ApiClient.dio.post('/chat/$idChat/mensaje', data: {
        'mensaje': mensaje,
      });
      _mensajes.add(respuesta.data);
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _error = e.response?.data['error'] ?? 'Error al enviar mensaje';
      notifyListeners();
      return false;
    }
  }

  // Iniciar chat con otro usuario
  Future<int?> iniciarChat(int idReceptor) async {
    try {
      final respuesta = await ApiClient.dio.post('/chat/iniciar', data: {
        'id_receptor': idReceptor,
      });
      await cargarConversaciones();
      return respuesta.data['chat']['id_chat'];
    } on DioException catch (e) {
      _error = e.response?.data['error'] ?? 'Error al iniciar chat';
      notifyListeners();
      return null;
    }
  }
}