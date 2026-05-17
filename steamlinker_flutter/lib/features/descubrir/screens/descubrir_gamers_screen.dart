import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/pais_util.dart';
import '../../../core/constants/publicacion_constants.dart';
import '../../../theme/colors.dart';
import '../../../widgets/drop_field.dart';
import '../../../widgets/steam_app_bar.dart';
import '../../../widgets/usuario_card.dart';
import '../../auth/providers/auth_provider.dart';
import '../../matches/screens/matches_screen.dart';
import '../../perfil/providers/perfil_provider.dart';
import '../../usuarios/screens/usuario_detalle_screen.dart';

class DescubrirGamersScreen extends StatefulWidget {
  const DescubrirGamersScreen({super.key});

  @override
  State<DescubrirGamersScreen> createState() => _DescubrirGamersScreenState();
}

class _DescubrirGamersScreenState extends State<DescubrirGamersScreen> {
  bool _inicializado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inicializado) {
      _inicializado = true;
      context.read<PerfilProvider>().descubrirUsuarios();
    }
  }

  Future<void> _recargar() async {
    await context.read<PerfilProvider>().descubrirUsuarios();
  }

  Future<void> _abrirFiltros() async {
    final perfil = context.read<PerfilProvider>();
    var tipoEtiqueta = PublicacionConstants.tiposFiltroEtiquetas.first;
    var paisEtiqueta = PaisUtil.todos;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: SteamColors.bgPanel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Filtros de búsqueda',
                    style: TextStyle(
                      color: SteamColors.light,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  DropField(
                    label: 'Tipo de publicación',
                    value: tipoEtiqueta,
                    items: PublicacionConstants.tiposFiltroEtiquetas,
                    onChanged: (v) => setSheetState(() => tipoEtiqueta = v),
                  ),
                  DropField(
                    label: 'País',
                    value: paisEtiqueta,
                    items: [PaisUtil.todos, ...PaisUtil.nombres],
                    onChanged: (v) => setSheetState(() => paisEtiqueta = v),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: SteamColors.blue),
                    onPressed: () {
                      final tipo = PublicacionConstants.valorTipoFiltro(tipoEtiqueta);
                      final pais = paisEtiqueta == PaisUtil.todos
                          ? null
                          : PaisUtil.nombreACodigo(paisEtiqueta);
                      Navigator.pop(context);
                      perfil.descubrirUsuarios(
                        tipo: tipo.isEmpty ? null : tipo,
                        pais: pais,
                      );
                    },
                    child: const Text('Aplicar'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _abrirUsuario(Map<String, dynamic> usuario) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UsuarioDetalleScreen(
          userId: usuario['id_usu'] as int,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final perfilProv = context.watch<PerfilProvider>();
    final auth = context.watch<AuthProvider>();
    final miId = auth.usuario?['id'];

    return Scaffold(
      backgroundColor: SteamColors.bgDeep,
      appBar: SteamAppBar(
        title: 'DESCUBRIR',
        actions: [
          IconButton(
            icon: const Icon(Icons.inbox_outlined, color: SteamColors.muted),
            tooltip: 'Mis solicitudes',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MatchesScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: SteamColors.muted),
            tooltip: 'Filtros',
            onPressed: _abrirFiltros,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: SteamColors.blue),
            onPressed: _recargar,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: SteamColors.blue,
        onRefresh: _recargar,
        child: perfilProv.descubrirCargando
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(SteamColors.blue),
                ),
              )
            : perfilProv.usuariosDescubrir.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 48),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'No hay gamers con publicaciones activas.\nPrueba otros filtros o vuelve más tarde.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: SteamColors.textSec),
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: perfilProv.usuariosDescubrir
                        .where((u) => miId == null || (u as Map)['id_usu'] != miId)
                        .length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final lista = perfilProv.usuariosDescubrir
                          .where((u) => miId == null || (u as Map)['id_usu'] != miId)
                          .toList();
                      final u = Map<String, dynamic>.from(lista[index] as Map);
                      final total = u['total_publicaciones'] ?? 0;
                      return UsuarioCard(
                        usuario: u,
                        subtitulo: u['descrip_usu']?.toString().isNotEmpty == true
                            ? u['descrip_usu']
                            : '$total publicación${total == 1 ? '' : 'es'} activa${total == 1 ? '' : 's'}',
                        onTap: () => _abrirUsuario(u),
                      );
                    },
                  ),
      ),
    );
  }
}
