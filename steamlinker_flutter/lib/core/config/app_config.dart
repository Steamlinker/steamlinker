import 'package:flutter/foundation.dart';

/// URL del API en desarrollo: backend local en el puerto 3000.
/// Emulador Android: http://10.0.2.2:3000 (por defecto en debug).
/// Móvil físico: flutter run --dart-define=API_BASE_URL=http://TU_IP_LAN:3000
/// Release: flutter build apk --dart-define=API_BASE_URL=https://api.tudominio.com
class AppConfig {
  AppConfig._();

  static const String _apiFromEnv = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static const int _localPort = 3000;

  static bool get isProduction => kReleaseMode;

  static String get apiBaseUrl {
    if (_apiFromEnv.isNotEmpty) {
      return _apiFromEnv.replaceAll(RegExp(r'/$'), '');
    }

    if (kIsWeb) {
      return 'http://localhost:$_localPort';
    }

    if (kDebugMode) {
      // Emulador Android → máquina host
      return 'http://10.0.2.2:$_localPort';
    }

    return 'http://localhost:$_localPort';
  }
}
