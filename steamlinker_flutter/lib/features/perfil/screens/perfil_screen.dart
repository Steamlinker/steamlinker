import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../theme/colors.dart';
import '../../../widgets/steam_app_bar.dart';
import '../../../widgets/steam_card.dart';
import '../../../widgets/steam_toast.dart';
import '../../../widgets/steam_buttons.dart';
import '../../account/screens/account_settings_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/perfil_provider.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  bool _inicializado = false;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _steamController = TextEditingController();
  bool _buscandoJuegos = false;
  bool _vinculandoSteam = false;
  bool _importandoSteam = false;
  bool _desvinculandoSteam = false;
  List<dynamic> _resultados = [];
  String? _errorBusqueda;
  String? _steamError;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inicializado) {
      _inicializado = true;
      _cargarPerfil();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _steamController.dispose();
    super.dispose();
  }

  Future<void> _cargarPerfil() async {
    final auth = context.read<AuthProvider>();
    final perfilProv = context.read<PerfilProvider>();
    final usuario = auth.usuario;
    if (usuario == null) return;
    await perfilProv.cargarPerfil(usuario['id']);
    if (!mounted) return;
  }

  Future<void> _buscarJuegos(String query) async {
    final perfilProv = context.read<PerfilProvider>();
    if (query.trim().isEmpty) {
      if (!mounted) return;
      setState(() {
        _resultados = [];
        _errorBusqueda = null;
      });
      return;
    }

    setState(() {
      _buscandoJuegos = true;
      _errorBusqueda = null;
    });

    final resultados = await perfilProv.buscarJuegos(query.trim());
    if (!mounted) return;
    setState(() {
      _resultados = resultados;
      _buscandoJuegos = false;
      if (resultados.isEmpty) {
        _errorBusqueda = 'No se encontraron juegos para "$query"';
      }
    });
  }

  Future<void> _agregarJuego(Map<String, dynamic> juego) async {
    final perfilProv = context.read<PerfilProvider>();
    final exito = await perfilProv.agregarJuego({
      'appid': juego['appid'],
      'nombre': juego['nombre'],
      'headerimg': juego['headerimg'],
      'capsuleimg': juego['capsuleimg'],
      'horas': 0,
      'favorito': false,
    });

    if (exito) {
      if (!mounted) return;
      showSteamToast(context, 'Juego agregado al perfil', SteamColors.green);
      setState(() {
        _resultados = [];
        _searchController.clear();
      });
    } else {
      if (!mounted) return;
      showSteamToast(
        context,
        perfilProv.error ?? 'No fue posible agregar el juego',
        Colors.red,
      );
    }
  }

  Future<void> _vincularSteamCuenta() async {
    final steamId = _steamController.text.trim();
    if (steamId.isEmpty) {
      setState(() => _steamError = 'Ingresa tu SteamID o URL de Steam');
      return;
    }

    setState(() {
      _vinculandoSteam = true;
      _steamError = null;
    });

    final perfilProv = context.read<PerfilProvider>();
    final exito = await perfilProv.vincularSteam(steamId);

    if (!mounted) return;
    setState(() {
      _vinculandoSteam = false;
    });

    if (exito) {
      showSteamToast(
        context,
        'Cuenta Steam vinculada correctamente',
        SteamColors.green,
      );
      _steamController.clear();
    } else {
      showSteamToast(
        context,
        perfilProv.error ?? 'No fue posible vincular Steam',
        Colors.red,
      );
      setState(() {
        _steamError = perfilProv.error;
      });
    }
  }

  Future<void> _importarBibliotecaSteam() async {
    setState(() {
      _importandoSteam = true;
      _steamError = null;
    });

    final perfilProv = context.read<PerfilProvider>();
    final mensaje = await perfilProv.importarJuegosSteam();

    if (!mounted) return;
    setState(() {
      _importandoSteam = false;
    });

    if (mensaje != null) {
      showSteamToast(context, mensaje, SteamColors.green);
    } else {
      showSteamToast(
        context,
        perfilProv.error ?? 'No fue posible importar la biblioteca',
        Colors.red,
      );
      setState(() {
        _steamError = perfilProv.error;
      });
    }
  }

  Future<void> _desvincularSteamCuenta() async {
    setState(() {
      _desvinculandoSteam = true;
      _steamError = null;
    });

    final perfilProv = context.read<PerfilProvider>();
    final exito = await perfilProv.desvincularSteam();

    if (!mounted) return;
    setState(() {
      _desvinculandoSteam = false;
    });

    if (exito) {
      showSteamToast(
        context,
        'Cuenta Steam desvinculada correctamente',
        SteamColors.green,
      );
    } else {
      showSteamToast(
        context,
        perfilProv.error ?? 'No fue posible desvincular Steam',
        Colors.red,
      );
      setState(() {
        _steamError = perfilProv.error;
      });
    }
  }

  Future<void> _toggleFavorito(Map<String, dynamic> juego) async {
    final perfilProv = context.read<PerfilProvider>();
    final exito = await perfilProv.actualizarJuego(
      appid: juego['appid'],
      nombre: juego['nombre'],
      headerimg: juego['headerimg'] ?? '',
      capsuleimg: juego['capsuleimg'] ?? '',
      horas: juego['horas'] ?? 0,
      favorito: !(juego['favorito'] == true),
    );

    if (!mounted) return;
    if (exito) {
      showSteamToast(
        context,
        juego['favorito'] == true
            ? 'Juego marcado como no favorito'
            : 'Juego marcado como favorito',
        SteamColors.green,
      );
    } else {
      showSteamToast(
        context,
        perfilProv.error ?? 'No fue posible actualizar el juego',
        Colors.red,
      );
    }
  }

  Future<void> _editarHorasJuego(Map<String, dynamic> juego) async {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController(text: '${juego['horas'] ?? 0}');
    final nuevoHoras = await showDialog<int?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar horas de juego'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Horas jugadas',
                hintText: '0',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa un valor';
                }
                final numero = int.tryParse(value);
                if (numero == null || numero < 0) {
                  return 'Ingresa un número válido';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState?.validate() == true) {
                  Navigator.of(context).pop(int.parse(controller.text));
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    if (nuevoHoras == null) return;

    final perfilProv = context.read<PerfilProvider>();
    final exito = await perfilProv.actualizarJuego(
      appid: juego['appid'],
      nombre: juego['nombre'],
      headerimg: juego['headerimg'] ?? '',
      capsuleimg: juego['capsuleimg'] ?? '',
      horas: nuevoHoras,
      favorito: juego['favorito'] == true,
    );

    if (!mounted) return;
    if (exito) {
      showSteamToast(context, 'Horas actualizadas', SteamColors.green);
    } else {
      showSteamToast(
        context,
        perfilProv.error ?? 'No fue posible actualizar horas',
        Colors.red,
      );
    }
  }

  bool _esJuegoAgregado(dynamic appid) {
    final perfilProv = context.read<PerfilProvider>();
    final targetId = appid.toString();
    return perfilProv.juegos.any((j) => j['appid'].toString() == targetId);
  }

  Future<bool> _confirmarEliminarJuego(String nombre) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar juego'),
          content: Text('¿Deseas eliminar "$nombre" de tu perfil?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    return confirmado == true;
  }

  Future<void> _eliminarJuego(int appid, String nombre) async {
    final confirmado = await _confirmarEliminarJuego(nombre);
    if (!confirmado) return;

    final perfilProv = context.read<PerfilProvider>();
    final exito = await perfilProv.eliminarJuego(appid);
    if (!mounted) return;
    if (exito) {
      showSteamToast(context, 'Juego eliminado del perfil', SteamColors.green);
    } else {
      showSteamToast(
        context,
        perfilProv.error ?? 'No fue posible eliminar el juego',
        Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final perfilProv = context.watch<PerfilProvider>();
    final perfil = perfilProv.perfil;

    return Scaffold(
      backgroundColor: SteamColors.bgDeep,
      appBar: const SteamAppBar(title: 'PERFIL'),
      body: perfilProv.cargando && perfil == null
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(SteamColors.blue),
              ),
            )
          : perfil == null
          ? Center(
              child: Text(
                perfilProv.error ?? 'No se pudo cargar el perfil',
                style: const TextStyle(color: SteamColors.light),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SteamCard(
                    icon: Icons.person,
                    title: perfil['username'] ?? 'Usuario',
                    child: Column(
                      children: [
                        Text(
                          perfil['descrip'] ?? 'Sin descripción',
                          style: const TextStyle(
                            color: SteamColors.textSec,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _InfoChip(
                              label: 'País',
                              value: perfil['pais'] ?? 'N/A',
                            ),
                            _InfoChip(
                              label: 'Reputación',
                              value: '${perfil['repu'] ?? 0}',
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: SteamButtonOutline(
                            label: 'Configuración de cuenta',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AccountSettingsScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SteamCard(
                    icon: Icons.verified_user,
                    title: perfil['steam'] != null
                        ? 'Steam conectado'
                        : 'Vincular Steam',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (perfil['steam'] != null) ...[
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundImage:
                                    perfil['steam']['avatar_url'] != null
                                    ? NetworkImage(
                                        perfil['steam']['avatar_url'],
                                      )
                                    : null,
                                backgroundColor: SteamColors.bgPanel,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      perfil['steam']['username_steperfil'] ??
                                          'Steam',
                                      style: const TextStyle(
                                        color: SteamColors.light,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: SelectableText(
                                            perfil['steam']['perfil_url'] ?? '',
                                            style: const TextStyle(
                                              color: SteamColors.blue,
                                              fontSize: 12,
                                            ),
                                            scrollPhysics:
                                                const NeverScrollableScrollPhysics(),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.copy,
                                            size: 18,
                                            color: SteamColors.textSec,
                                          ),
                                          onPressed: () {
                                            final url =
                                                perfil['steam']['perfil_url'] ??
                                                '';
                                            if (url.isNotEmpty) {
                                              Clipboard.setData(
                                                ClipboardData(text: url),
                                              );
                                              showSteamToast(
                                                context,
                                                'Enlace copiado',
                                                SteamColors.green,
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (_steamError != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                _steamError!,
                                style: const TextStyle(
                                  color: SteamColors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          Row(
                            children: [
                              Expanded(
                                child: SteamButtonPrimary(
                                  label: _importandoSteam
                                      ? 'Importando...'
                                      : 'Importar biblioteca',
                                  icon: Icons.download,
                                    onTap: _importandoSteam
                                      ? null
                                      : (ctx) => _importarBibliotecaSteam(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SteamButtonOutline(
                            label: _desvinculandoSteam
                                ? 'Desvinculando...'
                                : 'Desvincular Steam',
                            onTap: _desvinculandoSteam
                                ? null
                                : () => _desvincularSteamCuenta(),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Tu perfil Steam debe ser público para que podamos importar tu biblioteca. Si tu perfil es privado, solo podrás vincular la cuenta pero no importar juegos.',
                            style: TextStyle(
                              color: SteamColors.textSec,
                              fontSize: 12,
                            ),
                          ),
                        ] else ...[
                          TextField(
                            controller: _steamController,
                            style: const TextStyle(color: SteamColors.light),
                            decoration: InputDecoration(
                              labelText: 'SteamID o URL de Steam',
                              hintText:
                                  'steamcommunity.com/id/usuario o steamcommunity.com/profiles/765... ',
                              filled: true,
                              fillColor: SteamColors.bgInput,
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (_steamError != null)
                            Text(
                              _steamError!,
                              style: const TextStyle(
                                color: SteamColors.red,
                                fontSize: 12,
                              ),
                            ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: SteamButtonPrimary(
                                  label: _vinculandoSteam
                                      ? 'Vinculando...'
                                      : 'Vincular Steam',
                                  icon: Icons.link,
                                    onTap: _vinculandoSteam
                                      ? null
                                      : (ctx) => _vincularSteamCuenta(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Tu perfil Steam debe ser público para que podamos importar tu biblioteca. Si tu perfil es privado, solo podrás vincular la cuenta pero no importar juegos.',
                            style: TextStyle(
                              color: SteamColors.textSec,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SteamCard(
                    icon: Icons.search,
                    title: 'Buscar juegos',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _searchController,
                          style: const TextStyle(color: SteamColors.light),
                          decoration: InputDecoration(
                            labelText: 'Nombre del juego',
                            hintText: 'Buscar en Steam',
                            filled: true,
                            fillColor: SteamColors.bgInput,
                            suffixIcon: IconButton(
                              icon: const Icon(
                                Icons.search,
                                color: SteamColors.muted,
                              ),
                              onPressed: () =>
                                  _buscarJuegos(_searchController.text),
                            ),
                          ),
                          textInputAction: TextInputAction.search,
                          onSubmitted: _buscarJuegos,
                        ),
                        const SizedBox(height: 12),
                        if (_buscandoJuegos)
                          const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(
                                SteamColors.blue,
                              ),
                            ),
                          )
                        else if (_errorBusqueda != null)
                          Text(
                            _errorBusqueda!,
                            style: const TextStyle(color: SteamColors.textSec),
                          )
                        else if (_resultados.isEmpty)
                          const Text(
                            'Busca un juego para agregarlo a tu perfil.',
                            style: TextStyle(color: SteamColors.textSec),
                          )
                        else
                          Column(
                            children: _resultados.map((juego) {
                              final yaAgregado = _esJuegoAgregado(
                                juego['appid'],
                              );
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image:
                                        juego['headerimg'] != null &&
                                            juego['headerimg']
                                                .toString()
                                                .isNotEmpty
                                        ? DecorationImage(
                                            image: NetworkImage(
                                              juego['headerimg'],
                                            ),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                    color: SteamColors.bgPanel,
                                  ),
                                ),
                                title: Text(
                                  juego['nombre'] ?? 'Juego',
                                  style: const TextStyle(
                                    color: SteamColors.light,
                                  ),
                                ),
                                subtitle: Text(
                                  yaAgregado
                                      ? 'Ya agregado a tu biblioteca'
                                      : 'AppID: ${juego['appid']}',
                                  style: const TextStyle(
                                    color: SteamColors.textSec,
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: yaAgregado
                                    ? SteamButtonOutline(
                                        label: 'Agregado',
                                        onTap: () {},
                                      )
                                        : SteamButtonPrimary(
                                        label: 'Agregar',
                                        icon: Icons.add,
                                        onTap: (ctx) => _agregarJuego(juego),
                                      ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SteamCard(
                    icon: Icons.videogame_asset_outlined,
                    title: 'Juegos',
                    child: Column(
                      children: perfilProv.juegos.isEmpty
                          ? [
                              const Text(
                                'No se han agregado juegos todavía.',
                                style: TextStyle(color: SteamColors.textSec),
                              ),
                            ]
                          : perfilProv.juegos.map((juego) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      image:
                                          juego['headerimg'] != null &&
                                              juego['headerimg']
                                                  .toString()
                                                  .isNotEmpty
                                          ? DecorationImage(
                                              image: NetworkImage(
                                                juego['headerimg'],
                                              ),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                      color: SteamColors.bgPanel,
                                    ),
                                  ),
                                  title: Text(
                                    juego['nombre'] ?? 'Juego',
                                    style: const TextStyle(
                                      color: SteamColors.light,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Horas: ${juego['horas']} • Favorito: ${juego['favorito'] ? 'Sí' : 'No'}',
                                    style: const TextStyle(
                                      color: SteamColors.textSec,
                                      fontSize: 12,
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          juego['favorito'] == true
                                              ? Icons.favorite_rounded
                                              : Icons.favorite_border_rounded,
                                          color: juego['favorito'] == true
                                              ? SteamColors.red
                                              : SteamColors.muted,
                                        ),
                                        onPressed: () => _toggleFavorito(juego),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: SteamColors.blue,
                                        ),
                                        onPressed: () =>
                                            _editarHorasJuego(juego),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: SteamColors.red,
                                        ),
                                        onPressed: () => _eliminarJuego(
                                          juego['appid'],
                                          juego['nombre'] ?? 'el juego',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;

  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: SteamColors.textSec, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: SteamColors.bgPanel,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            value,
            style: const TextStyle(color: SteamColors.light, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
