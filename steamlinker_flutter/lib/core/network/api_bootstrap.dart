import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import 'api_client.dart';

/// Registra callbacks globales del cliente HTTP (p. ej. 401 → logout).
class ApiBootstrap extends StatefulWidget {
  final Widget child;

  const ApiBootstrap({super.key, required this.child});

  @override
  State<ApiBootstrap> createState() => _ApiBootstrapState();
}

class _ApiBootstrapState extends State<ApiBootstrap> {
  @override
  void initState() {
    super.initState();
    ApiClient.onUnauthorized = _onUnauthorized;
  }

  Future<void> _onUnauthorized() async {
    if (!mounted) return;
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
