import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../theme/colors.dart';

/// Diálogo de confirmación y cierre de sesión con redirección al login.
Future<void> confirmarYCerrarSesion(BuildContext context) async {
  final confirmar = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: SteamColors.bgPanel,
      title: const Text(
        'Cerrar sesión',
        style: TextStyle(color: SteamColors.light),
      ),
      content: const Text(
        '¿Seguro que quieres salir de tu cuenta en este dispositivo?',
        style: TextStyle(color: SteamColors.textSec),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: TextButton.styleFrom(foregroundColor: SteamColors.red),
          child: const Text('Cerrar sesión'),
        ),
      ],
    ),
  );

  if (confirmar != true || !context.mounted) return;

  await context.read<AuthProvider>().logout();
  if (!context.mounted) return;
  context.go('/login');
}
