import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/colors.dart';
import '../providers/matches_provider.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  bool _inicializado = false;
  int _tabActual = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inicializado) {
      _inicializado = true;
      final prov = context.read<MatchesProvider>();
      prov.cargarRecibidos();
      prov.cargarEnviados();
    }
  }

  @override
  Widget build(BuildContext context) {
    final matchesProv = context.watch<MatchesProvider>();

    return Scaffold(
      backgroundColor: SteamColors.bgDeep,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: SteamColors.bgPanel,
        title: const Text('Matches'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  _TabButton(
                    label: 'Recibidos',
                    selected: _tabActual == 0,
                    onTap: () => setState(() => _tabActual = 0),
                  ),
                  const SizedBox(width: 12),
                  _TabButton(
                    label: 'Enviados',
                    selected: _tabActual == 1,
                    onTap: () => setState(() => _tabActual = 1),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: SteamColors.blue),
                    onPressed: () {
                      matchesProv.cargarRecibidos();
                      matchesProv.cargarEnviados();
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: matchesProv.cargando
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(SteamColors.blue),
                      ),
                    )
                  : _tabActual == 0
                      ? _buildRecibidos(matchesProv)
                      : _buildEnviados(matchesProv),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecibidos(MatchesProvider prov) {
    if (prov.recibidos.isEmpty) {
      return const Center(
        child: Text(
          'No tienes solicitudes recibidas.',
          style: TextStyle(color: SteamColors.textSec),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: prov.recibidos.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = prov.recibidos[index];
        return _MatchCard(
          title: item['solicitante_username'] ?? 'Usuario',
          subtitle:
              'País: ${item['solicitante_pais'] ?? 'N/A'} • Repu: ${item['solicitante_reputacion'] ?? 0}',
          onAccept: () async {
            await prov.responder(item['id_match'], 'Aceptada');
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Solicitud aceptada')),
            );
          },
          onReject: () async {
            await prov.responder(item['id_match'], 'Rechazada');
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Solicitud rechazada')),
            );
          },
        );
      },
    );
  }

  Widget _buildEnviados(MatchesProvider prov) {
    if (prov.enviados.isEmpty) {
      return const Center(
        child: Text(
          'No tienes solicitudes enviadas.',
          style: TextStyle(color: SteamColors.textSec),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: prov.enviados.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = prov.enviados[index];
        return _MatchCard(
          title: item['receptor_username'] ?? 'Usuario',
          subtitle:
              'País: ${item['receptor_pais'] ?? 'N/A'} • Repu: ${item['receptor_reputacion'] ?? 0}',
          readOnly: true,
        );
      },
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? SteamColors.blue : SteamColors.bgPanel,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? SteamColors.blue : SteamColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : SteamColors.light,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final bool readOnly;

  const _MatchCard({
    required this.title,
    required this.subtitle,
    this.onAccept,
    this.onReject,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SteamColors.bgPanel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SteamColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: SteamColors.light,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(color: SteamColors.textSec, fontSize: 13),
          ),
          if (!readOnly) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SteamColors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: onAccept,
                    child: const Text('Aceptar'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: SteamColors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: onReject,
                    child: const Text('Rechazar', style: TextStyle(color: SteamColors.red)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
