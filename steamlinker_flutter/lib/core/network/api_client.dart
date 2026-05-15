// Cliente HTTP centralizado usando Dio
// Todas las llamadas al backend pasan por aqui

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  // En Flutter web (Chrome), el backend se accede como localhost.
  // En Android emulator se usa 10.0.2.2 porque localhost apunta al emulador.
  static String get baseUrl => kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000';
  
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  // Configurar el cliente con interceptores
  static void init() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Agregar el token JWT a cada request automaticamente
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          handler.next(error);
        },
      ),
    );
  }

  static Dio get dio => _dio;
}
