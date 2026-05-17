import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/publicaciones_provider.dart';

class PublicacionesScreen extends StatefulWidget {
  const PublicacionesScreen({super.key});

  @override
  State<PublicacionesScreen> createState() => _PublicacionesScreenState();
}

class _PublicacionesScreenState extends State<PublicacionesScreen> {
  bool _inicializado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inicializado) {
      _inicializado = true;
      context.read<PublicacionesProvider>().buscar();
    }
  }

  Future<void> _recargar() async {
    await context.read<PublicacionesProvider>().buscar();
  }

  @override
  Widget build(BuildContext context) {
    final publicacionesProv = context.watch<PublicacionesProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: SteamColors.bgDeep,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: SteamColors.bgPanel,
        title: const Text('Publicaciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _recargar,
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: SteamColors.blue,
          backgroundColor: SteamColors.bgDeep,
          onRefresh: _recargar,
          child: publicacionesProv.cargando
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(SteamColors.blue),
                  ),
                )
              : publicacionesProv.error != null
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      children: [
                        Text(
                          publicacionesProv.error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    )
                  : publicacionesProv.publicaciones.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          children: const [
                            SizedBox(height: 40),
                            Center(
                              child: Text(
                                'No hay publicaciones disponibles.',
                                style: TextStyle(color: SteamColors.textSec),
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: publicacionesProv.publicaciones.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final publicacion = publicacionesProv.publicaciones[index];
                            final juegos = (publicacion['juegos'] as List<dynamic>?) ?? [];
                            final esMia = auth.usuario != null &&
                                auth.usuario!['id'] == publicacion['id_usu'];

                            return Container(
                              decoration: BoxDecoration(
                                color: SteamColors.bgPanel,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: SteamColors.border),
                              ),
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: SteamColors.blue.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          publicacion['tipo_publi'] ?? 'General',
                                          style: const TextStyle(
                                            color: SteamColors.blue,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      if (esMia)
                                        IconButton(
                                          icon: const Icon(Icons.close, color: SteamColors.red),
                                          tooltip: 'Cerrar publicación',
                                          onPressed: () async {
                                            await publicacionesProv.cerrar(publicacion['id_publi']);
                                            if (publicacionesProv.error != null) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text(publicacionesProv.error!)),
                                              );
                                            }
                                          },
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    publicacion['titulo_publi'] ?? '',
                                    style: const TextStyle(
                                      color: SteamColors.light,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    publicacion['descrip_publi'] ?? 'Sin descripción',
                                    style: const TextStyle(
                                      color: SteamColors.textSec,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _InfoPill(
                                        icon: Icons.person_outline,
                                        label: publicacion['username_usu'] ?? 'Autor',
                                      ),
                                      _InfoPill(
                                        icon: Icons.public,
                                        label: publicacion['paisfiltro_publi'] ?? 'Todos los países',
                                      ),
                                      _InfoPill(
                                        icon: Icons.videogame_asset_outlined,
                                        label: '${publicacion['total_juegos'] ?? juegos.length} juegos',
                                      ),
                                    ],
                                  ),
                                  if (juegos.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: juegos.take(4).map<Widget>((juego) {
                                        return Chip(
                                          label: Text(juego['nom_jg'] ?? ''),
                                          backgroundColor: SteamColors.bgCard,
                                          labelStyle: const TextStyle(color: SteamColors.light),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: SteamColors.bgCard,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: SteamColors.muted),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: SteamColors.textSec, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
