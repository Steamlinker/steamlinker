import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../features/auth/providers/auth_provider.dart';

class SteamAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const SteamAppBar({super.key, required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: SteamColors.bgPanel,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: SteamColors.border),
      ),
      leading: Padding(
        padding: const EdgeInsets.all(12),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: SteamColors.blue, width: 1.5),
          ),
          child: const Icon(Icons.sports_esports, size: 16, color: SteamColors.blue),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: SteamColors.light,
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
        ),
      ),
      actions: [
        Consumer<AuthProvider>(
          builder: (context, auth, _) {
            final usuario = auth.usuario;
            final username = usuario?['username'] ?? 'Usuario';
            final inicial = username.isNotEmpty ? username[0].toUpperCase() : 'U';

            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        username,
                        style: const TextStyle(
                          color: SteamColors.light,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Row(children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: SteamColors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'En línea',
                          style: TextStyle(color: SteamColors.green, fontSize: 10),
                        ),
                      ]),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2A4A6B), SteamColors.teal],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(color: SteamColors.blue, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        inicial,
                        style: const TextStyle(
                          color: SteamColors.light,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

