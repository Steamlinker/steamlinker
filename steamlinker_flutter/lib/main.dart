// Punto de entrada de la aplicacion Steamlinker
// Configura providers, rutas y tema visual

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'core/network/api_client.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/home/screens/main_shell.dart';
import 'features/perfil/providers/perfil_provider.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ApiClient.init();
  runApp(const SteamlinkerApp());
}

class SteamlinkerApp extends StatelessWidget {
  const SteamlinkerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..verificarSesion()),
        ChangeNotifierProvider(create: (_) => PerfilProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp.router(
            title: 'Steamlinker',
            debugShowCheckedModeBanner: false,
            theme: SteamTheme.theme,
            routerConfig: GoRouter(
              initialLocation: '/login',
              refreshListenable: auth,
              redirect: (context, state) {
                final enLogin = state.matchedLocation == '/login';
                if (auth.autenticado && enLogin) return '/home';
                if (!auth.autenticado && !enLogin) return '/login';
                return null;
              },
              routes: [
                GoRoute(
                  path: '/login',
                  builder: (context, state) => const LoginScreen(),
                ),
                GoRoute(
                  path: '/home',
                  builder: (context, state) => const MainShell(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}