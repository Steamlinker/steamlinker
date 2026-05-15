// Pantalla principal despues del login
// Muestra navegacion lateral y contenido principal

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/providers/auth_provider.dart';
import '../publicaciones/screens/publicaciones_screen.dart';
import '../busqueda/screens/busqueda_screen.dart';
import '../matches/screens/matches_screen.dart';
import '../chat/screens/chat_screen.dart';
import '../perfil/screens/perfil_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _paginaActual = 0;

  final List<_NavItem> _items = [
    _NavItem(icon: Icons.home_outlined, label: 'Inicio'),
    _NavItem(icon: Icons.search, label: 'Buscar'),
    _NavItem(icon: Icons.handshake_outlined, label: 'Matches'),
    _NavItem(icon: Icons.chat_bubble_outline, label: 'Chat'),
    _NavItem(icon: Icons.person_outline, label: 'Perfil'),
  ];

  final List<Widget> _pantallas = [
    const PublicacionesScreen(),
    const BusquedaScreen(),
    const MatchesScreen(),
    const ChatScreen(),
    const PerfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final esEscritorio = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      body: Row(
        children: [
          // Sidebar para escritorio
          if (esEscritorio)
            Container(
              width: 220,
              color: const Color(0xFF161B22),
              child: Column(
                children: [
                  // Logo
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF1A9FFF),
                          ),
                          child: const Icon(Icons.games, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Steamlinker',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF1A9FFF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Color(0xFF30363D), height: 1),
                  const SizedBox(height: 8),

                  // Items del menu
                  ...List.generate(_items.length, (i) => _SidebarItem(
                    item: _items[i],
                    activo: _paginaActual == i,
                    onTap: () => setState(() => _paginaActual = i),
                  )),

                  const Spacer(),
                  const Divider(color: Color(0xFF30363D), height: 1),

                  // Usuario y logout
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: const Color(0xFF1A9FFF),
                          child: Text(
                            (auth.usuario?['username'] ?? '?')[0].toUpperCase(),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            auth.usuario?['username'] ?? '',
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout, size: 18, color: Color(0xFF8B949E)),
                          onPressed: () => auth.logout(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Contenido principal
          Expanded(
            child: _pantallas[_paginaActual],
          ),
        ],
      ),

      // Bottom nav para movil
      bottomNavigationBar: esEscritorio
          ? null
          : NavigationBar(
              selectedIndex: _paginaActual,
              onDestinationSelected: (i) => setState(() => _paginaActual = i),
              backgroundColor: const Color(0xFF161B22),
              destinations: _items
                  .map((item) => NavigationDestination(
                        icon: Icon(item.icon),
                        label: item.label,
                      ))
                  .toList(),
            ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _SidebarItem extends StatelessWidget {
  final _NavItem item;
  final bool activo;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.item,
    required this.activo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: activo ? const Color(0xFF1A9FFF).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: activo
              ? Border(left: BorderSide(color: const Color(0xFF1A9FFF), width: 2))
              : null,
        ),
        child: Row(
          children: [
            Icon(
              item.icon,
              size: 18,
              color: activo ? const Color(0xFF1A9FFF) : const Color(0xFF8B949E),
            ),
            const SizedBox(width: 10),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 13,
                color: activo ? const Color(0xFF1A9FFF) : const Color(0xFF8B949E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}