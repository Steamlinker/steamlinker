import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/colors.dart';
import '../../../widgets/steam_app_bar.dart';
import '../../auth/providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar datos del usuario cuando la pantalla se inicializa
    Future.microtask(() {
      final auth = context.read<AuthProvider>();
      if (auth.usuario != null) {
        // Los datos ya están disponibles del login
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SteamColors.bgDeep,
      appBar: const SteamAppBar(title: 'INICIO'),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.usuario == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(SteamColors.blue),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Cargando datos...',
                    style: TextStyle(color: SteamColors.light),
                  ),
                ],
              ),
            );
          }

          final usuario = auth.usuario!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ── Tarjeta de Bienvenida ────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2A4A6B), SteamColors.teal],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: SteamColors.blue, width: 1),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Bienvenido',
                                style: TextStyle(
                                  color: SteamColors.textSec,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                usuario['username'] ?? 'Usuario',
                                style: const TextStyle(
                                  color: SteamColors.light,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: SteamColors.blue.withOpacity(0.2),
                              border: Border.all(color: SteamColors.blue, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                (usuario['username'] as String).isNotEmpty
                                    ? (usuario['username'] as String)[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  color: SteamColors.light,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Tu hub para conectar con gamers',
                        style: TextStyle(
                          color: SteamColors.textSec,
                          fontSize: 13.5,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Información del Usuario ──────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: SteamColors.bgCard,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: SteamColors.border),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: usuario['email'] ?? 'N/A',
                      ),
                      const Divider(color: SteamColors.border, height: 20),
                      _InfoRow(
                        icon: Icons.public,
                        label: 'País',
                        value: usuario['pais'] ?? 'No especificado',
                      ),
                      const Divider(color: SteamColors.border, height: 20),
                      _InfoRow(
                        icon: Icons.account_box_outlined,
                        label: 'Tipo de Cuenta',
                        value: usuario['tipo'] ?? 'usuario',
                      ),
                      const Divider(color: SteamColors.border, height: 20),
                      _InfoRow(
                        icon: Icons.trending_up,
                        label: 'Estado',
                        value: 'En línea',
                        valueColor: SteamColors.green,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Secciones Rápidas ────────────────────────────────
                _QuickAccessCard(
                  icon: Icons.people_outline,
                  title: 'Descubre Gamers',
                  description: 'Encuentra compañeros de juego',
                  color: SteamColors.purple,
                ),
                const SizedBox(height: 12),
                _QuickAccessCard(
                  icon: Icons.sports_esports_outlined,
                  title: 'Mis Juegos',
                  description: 'Administra tu biblioteca',
                  color: SteamColors.teal,
                ),
                const SizedBox(height: 12),
                _QuickAccessCard(
                  icon: Icons.chat_outlined,
                  title: 'Mensajes',
                  description: 'Comunícate con otros usuarios',
                  color: SteamColors.blue,
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor = SteamColors.light,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: SteamColors.blue),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: SteamColors.textSec,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _QuickAccessCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SteamColors.bgCard,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: SteamColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: color, width: 1.5),
                  ),
                  child: Center(
                    child: Icon(icon, size: 22, color: color),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: SteamColors.light,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: const TextStyle(
                          color: SteamColors.textSec,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_rounded, color: SteamColors.muted, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
