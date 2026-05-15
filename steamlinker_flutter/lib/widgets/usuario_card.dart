// Tarjeta reutilizable para mostrar un usuario
// Se usa en busqueda y lista de matches

import 'package:flutter/material.dart';

class UsuarioCard extends StatelessWidget {
  final Map<String, dynamic> usuario;
  final VoidCallback? onTap;
  final Widget? accion;

  const UsuarioCard({
    super.key,
    required this.usuario,
    this.onTap,
    this.accion,
  });

  @override
  Widget build(BuildContext context) {
    final reputacion = double.tryParse(
      usuario['repu_usu']?.toString() ?? '0',
    ) ?? 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF30363D)),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF1A9FFF),
              child: Text(
                (usuario['username_usu'] ?? usuario['username'] ?? '?')[0].toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Info del usuario
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    usuario['username_usu'] ?? usuario['username'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      // Pais
                      if (usuario['pais_usu'] != null) ...[
                        const Icon(Icons.location_on, size: 12, color: Color(0xFF8B949E)),
                        const SizedBox(width: 2),
                        Text(
                          usuario['pais_usu'],
                          style: const TextStyle(fontSize: 11, color: Color(0xFF8B949E)),
                        ),
                        const SizedBox(width: 8),
                      ],
                      // Reputacion
                      const Icon(Icons.star, size: 12, color: Color(0xFF3FB950)),
                      const SizedBox(width: 2),
                      Text(
                        reputacion.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF3FB950),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Accion opcional
            if (accion != null) accion!,
          ],
        ),
      ),
    );
  }
}