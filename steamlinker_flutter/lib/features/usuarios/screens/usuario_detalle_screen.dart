import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/pais_util.dart';
import '../../../theme/colors.dart';
import '../../../widgets/calificar_dialog.dart';
import '../../../widgets/steam_app_bar.dart';
import '../../../widgets/steam_buttons.dart';
import '../../../widgets/steam_card.dart';
import '../../../widgets/steam_toast.dart';
import '../../amistad/providers/amistad_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../calificaciones/providers/calificaciones_provider.dart';
import '../../chat/providers/chat_provider.dart';
import '../../chat/screens/chat_conversation_screen.dart';
import '../../matches/providers/matches_provider.dart';
import '../../notifications/providers/notificaciones_provider.dart';
import '../../perfil/providers/perfil_provider.dart';
import 'comparar_biblioteca_screen.dart';

class UsuarioDetalleScreen extends StatefulWidget {
  final int userId;
  final int? idPubli;
  final String? tituloPublicacion;

  const UsuarioDetalleScreen({
    super.key,
    required this.userId,
    this.idPubli,
    this.tituloPublicacion,
  });

  @override
  State<UsuarioDetalleScreen> createState() => _UsuarioDetalleScreenState();
}

class _UsuarioDetalleScreenState extends State<UsuarioDetalleScreen> {
  bool _cargando = true;
  String? _error;
  Map<String, dynamic>? _perfil;
  List<dynamic> _juegos = [];
  bool _enviandoMatch = false;
  bool _enviandoAmistad = false;
  bool _comparando = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MatchesProvider>().cargarTodo();
    });
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    final data = await context.read<PerfilProvider>().cargarPerfilAjeno(widget.userId);
    if (!mounted) return;
    if (data == null) {
      setState(() {
        _cargando = false;
        _error = context.read<PerfilProvider>().error ?? 'No se pudo cargar';
      });
      return;
    }
    setState(() {
      _perfil = data['perfil'] as Map<String, dynamic>;
      _juegos = data['juegos'] as List<dynamic>;
      _cargando = false;
    });
  }

  Future<void> _enviarMatch() async {
    setState(() => _enviandoMatch = true);
    final exito = await context.read<MatchesProvider>().enviar(
      widget.userId,
      idPubli: widget.idPubli,
    );
    if (!mounted) return;
    setState(() => _enviandoMatch = false);
    if (exito) {
      showSteamToast(context, 'Solicitud de match enviada', SteamColors.green);
      context.read<NotificacionesProvider>().cargarContador();
    } else {
      showSteamToast(
        context,
        context.read<MatchesProvider>().error ?? 'No se pudo enviar',
        Colors.red,
      );
    }
  }

  Future<void> _enviarAmistad() async {
    setState(() => _enviandoAmistad = true);
    final exito = await context.read<AmistadProvider>().enviar(widget.userId);
    if (!mounted) return;
    setState(() => _enviandoAmistad = false);
    if (exito) {
      showSteamToast(context, 'Solicitud de amistad enviada', SteamColors.green);
      context.read<NotificacionesProvider>().cargarContador();
    } else {
      showSteamToast(
        context,
        context.read<AmistadProvider>().error ?? 'No se pudo enviar',
        Colors.red,
      );
    }
  }

  Future<void> _compararBiblioteca() async {
    setState(() => _comparando = true);
    final resultado =
        await context.read<PerfilProvider>().compararBiblioteca(widget.userId);
    if (!mounted) return;
    setState(() => _comparando = false);

    if (resultado != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CompararBibliotecaScreen(resultado: resultado),
        ),
      );
    } else {
      showSteamToast(
        context,
        context.read<PerfilProvider>().error ?? 'No se pudo comparar',
        Colors.red,
      );
    }
  }

  Future<void> _abrirChat() async {
    final chatProv = context.read<ChatProvider>();
    await chatProv.cargarConversaciones();

    int? chatId;
    for (final c in chatProv.conversaciones) {
      final chat = Map<String, dynamic>.from(c as Map);
      if (ChatProvider.otroUserId(chat) == widget.userId) {
        chatId = chat['id_chat'] as int?;
        break;
      }
    }

    chatId ??= await chatProv.iniciarChat(widget.userId);

    if (!mounted) return;
    if (chatId == null) {
      showSteamToast(
        context,
        chatProv.error ?? 'No se pudo abrir el chat',
        Colors.red,
      );
      return;
    }

    final nombre = _perfil?['username']?.toString() ?? 'Usuario';
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatConversationScreen(
          chatId: chatId!,
          otroNombre: nombre,
          otroUserId: widget.userId,
        ),
      ),
    );
  }

  Future<void> _calificarMatch(Map<String, dynamic> match) async {
    final miId = context.read<AuthProvider>().usuario?['id'];
    final solicitante = match['id_solicitante'];
    final receptor = match['id_receptor'];
    final idCalificado = miId == solicitante ? receptor : solicitante;
    final nombre = _perfil?['username'] ?? 'usuario';

    final resultado = await mostrarCalificarDialog(context, nombreUsuario: nombre);
    if (resultado == null || !mounted) return;

    final exito = await context.read<CalificacionesProvider>().crear(
      idMatch: match['id_match'] as int,
      idCalificado: idCalificado as int,
      estrellas: resultado.estrellas,
      confiable: resultado.confiable,
      comentario: resultado.comentario,
    );

    if (!mounted) return;
    if (exito) {
      showSteamToast(context, 'Calificación enviada', SteamColors.green);
      await _cargar();
    } else {
      showSteamToast(
        context,
        context.read<CalificacionesProvider>().error ?? 'Error al calificar',
        Colors.red,
      );
    }
  }

  Map<String, dynamic>? _matchAceptadoConUsuario(MatchesProvider matches, int? miId) {
    if (miId == null) return null;
    for (final m in [...matches.recibidos, ...matches.enviados]) {
      if (m['estado_match'] != 'Aceptada') continue;
      final otro = m['id_solicitante'] == miId ? m['id_receptor'] : m['id_solicitante'];
      if (otro == widget.userId) return Map<String, dynamic>.from(m as Map);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final matchesProv = context.watch<MatchesProvider>();
    final miId = auth.usuario?['id'];
    final esYo = miId == widget.userId;
    final matchAceptado = _matchAceptadoConUsuario(matchesProv, miId);

    return Scaffold(
      backgroundColor: SteamColors.bgDeep,
      appBar: const SteamAppBar(title: 'PERFIL'),
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(SteamColors.blue),
              ),
            )
          : _error != null
              ? Center(
                  child: Text(_error!, style: const TextStyle(color: SteamColors.light)),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (widget.tituloPublicacion != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: SteamColors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: SteamColors.orange.withOpacity(0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.campaign_outlined, color: SteamColors.orange, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                widget.tituloPublicacion!,
                                style: const TextStyle(color: SteamColors.light, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    SteamCard(
                      icon: Icons.person,
                      title: _perfil!['username'] ?? 'Usuario',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            _perfil!['descrip']?.toString().isNotEmpty == true
                                ? _perfil!['descrip']
                                : 'Sin descripción',
                            style: const TextStyle(color: SteamColors.textSec, fontSize: 13),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _ChipInfo(
                                label: PaisUtil.codigoANombre(_perfil!['pais']?.toString()),
                              ),
                              const SizedBox(width: 8),
                              _ChipInfo(
                                label: '★ ${(_perfil!['repu'] ?? 0).toString()}',
                                color: SteamColors.green,
                              ),
                            ],
                          ),
                          if (!esYo) ...[
                            const SizedBox(height: 16),
                            SteamButtonPrimary(
                              label: _enviandoMatch ? 'Enviando...' : 'Enviar match',
                              icon: Icons.handshake_outlined,
                              onTap: _enviandoMatch ? null : (_) => _enviarMatch(),
                            ),
                            const SizedBox(height: 10),
                            SteamButtonOutline(
                              label: _enviandoAmistad ? 'Enviando...' : 'Agregar amigo',
                              onTap: _enviandoAmistad ? null : _enviarAmistad,
                            ),
                            const SizedBox(height: 10),
                            SteamButtonOutline(
                              label: _comparando
                                  ? 'Comparando...'
                                  : 'Comparar bibliotecas',
                              onTap: _comparando ? null : _compararBiblioteca,
                            ),
                            if (matchAceptado != null) ...[
                              const SizedBox(height: 10),
                              SteamButtonPrimary(
                                label: 'Abrir chat',
                                icon: Icons.chat_bubble_outline,
                                onTap: (_) => _abrirChat(),
                              ),
                              const SizedBox(height: 10),
                              SteamButtonOutline(
                                label: 'Calificar usuario',
                                onTap: () => _calificarMatch(matchAceptado),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SteamCard(
                      icon: Icons.videogame_asset_outlined,
                      title: 'Biblioteca (${_juegos.length})',
                      child: _juegos.isEmpty
                          ? const Text(
                              'Sin juegos visibles en el perfil.',
                              style: TextStyle(color: SteamColors.textSec, fontSize: 12),
                            )
                          : Column(
                              children: _juegos.take(8).map((j) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(6),
                                          color: SteamColors.bgPanel,
                                          image: (j['headerimg']?.toString().isNotEmpty == true)
                                              ? DecorationImage(
                                                  image: NetworkImage(j['headerimg']),
                                                  fit: BoxFit.cover,
                                                )
                                              : null,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          j['nombre'] ?? 'Juego',
                                          style: const TextStyle(
                                            color: SteamColors.light,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${j['horas'] ?? 0}h',
                                        style: const TextStyle(
                                          color: SteamColors.textSec,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                    ),
                  ],
                ),
    );
  }
}

class _ChipInfo extends StatelessWidget {
  final String label;
  final Color color;

  const _ChipInfo({required this.label, this.color = SteamColors.blue});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
