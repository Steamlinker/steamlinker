import 'package:flutter/material.dart';

/// Navegación sobre el shell principal (evita pantallas en blanco en web).
Future<T?> pushAppScreen<T>(BuildContext context, Widget screen) {
  return Navigator.of(context, rootNavigator: true).push<T>(
    MaterialPageRoute(builder: (_) => screen),
  );
}
