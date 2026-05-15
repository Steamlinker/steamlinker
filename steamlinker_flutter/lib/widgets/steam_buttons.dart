import 'package:flutter/material.dart';
import '../theme/colors.dart';

// ── Botón primario (azul relleno) ─────────────────────────────────────────
class SteamButtonPrimary extends StatelessWidget {
  final String label;
  final IconData icon;
  final void Function(BuildContext context) onTap;

  const SteamButtonPrimary({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => onTap(context),
      icon: Icon(icon, size: 14),
      label: Text(label.toUpperCase()),
      style: ElevatedButton.styleFrom(
        backgroundColor: SteamColors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
        textStyle: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

// ── Botón outline (azul con borde) ────────────────────────────────────────
class SteamButtonOutline extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const SteamButtonOutline({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: SteamColors.blue,
        side: const BorderSide(color: SteamColors.blue),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
        textStyle: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.0,
        ),
      ),
      child: Text(label.toUpperCase()),
    );
  }
}

// ── Botón de peligro (rojo con borde) ─────────────────────────────────────
class SteamButtonDanger extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const SteamButtonDanger({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 14),
      label: Text(label.toUpperCase()),
      style: OutlinedButton.styleFrom(
        foregroundColor: SteamColors.red,
        side: BorderSide(color: SteamColors.red.withOpacity(0.6)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
        textStyle: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.9,
        ),
      ),
    );
  }
}
