// Cliente HTTP centralizado usando Dio

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import 'api_error_mapper.dart';

class ApiClient {
  static Future<void> Function()? onUnauthorized;

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static void init() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            final path = error.requestOptions.path;
            final esAuthPublico = path.contains('/auth/login') ||
                path.contains('/auth/registro');
            if (!esAuthPublico && onUnauthorized != null) {
              await onUnauthorized!();
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  static Dio get dio => _dio;

  /// Atajo para mensajes de error en providers.
  static String errorMessage(DioException e, {required String fallback}) =>
      ApiErrorMapper.resolve(e, fallback: fallback);
}
