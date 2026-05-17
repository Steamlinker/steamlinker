import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/colors.dart';
import '../providers/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _inicializado = false;
  int? _chatSeleccionado;
  final TextEditingController _mensajeController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inicializado) {
      _inicializado = true;
      context.read<ChatProvider>().cargarConversaciones();
    }
  }

  @override
  void dispose() {
    _mensajeController.dispose();
    super.dispose();
  }

  Future<void> _enviarMensaje() async {
    final chatProv = context.read<ChatProvider>();
    final texto = _mensajeController.text.trim();
    if (texto.isEmpty || _chatSeleccionado == null) return;

    final exito = await chatProv.enviarMensaje(_chatSeleccionado!, texto);
    if (exito) {
      _mensajeController.clear();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(chatProv.error ?? 'No se pudo enviar el mensaje')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProv = context.watch<ChatProvider>();

    return Scaffold(
      backgroundColor: SteamColors.bgDeep,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: SteamColors.bgPanel,
        title: const Text('Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => chatProv.cargarConversaciones(),
          ),
        ],
      ),
      body: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: SteamColors.bgPanel,
                  border: Border(right: BorderSide(color: SteamColors.border)),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: const [
                          Icon(Icons.forum, color: SteamColors.blue),
                          SizedBox(width: 10),
                          Text(
                            'Conversaciones',
                            style: TextStyle(
                              color: SteamColors.light,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (chatProv.cargando)
                      const Expanded(
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(SteamColors.blue),
                          ),
                        ),
                      )
                    else if (chatProv.error != null)
                      Expanded(
                        child: Center(
                          child: Text(
                            chatProv.error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      )
                    else if (chatProv.conversaciones.isEmpty)
                      const Expanded(
                        child: Center(
                          child: Text(
                            'No tienes conversaciones aún.',
                            style: TextStyle(color: SteamColors.textSec),
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: chatProv.conversaciones.length,
                          separatorBuilder: (_, __) => const Divider(color: SteamColors.border),
                          itemBuilder: (context, index) {
                            final chat = chatProv.conversaciones[index];
                            final selected = chat['id_chat'] == _chatSeleccionado;
                            return ListTile(
                              selected: selected,
                              selectedColor: SteamColors.blue,
                              title: Text(
                                chat['username_participante1'] == chat['username_participante2']
                                    ? chat['username_participante1']
                                    : chat['username_participante1'] == null
                                        ? chat['username_participante2']
                                        : chat['username_participante1'],
                                style: const TextStyle(color: SteamColors.light),
                              ),
                              subtitle: Text(
                                chat['ultimo_mensaje'] ?? 'Sin mensajes aún',
                                style: const TextStyle(color: SteamColors.textSec, fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () {
                                setState(() => _chatSeleccionado = chat['id_chat']);
                                context.read<ChatProvider>().cargarMensajes(chat['id_chat']);
                              },
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 6,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: _chatSeleccionado == null
                    ? const Center(
                        child: Text(
                          'Selecciona una conversación para ver los mensajes.',
                          style: TextStyle(color: SteamColors.textSec),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: chatProv.cargando
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation(SteamColors.blue),
                                    ),
                                  )
                                : chatProv.mensajes.isEmpty
                                    ? const Center(
                                        child: Text(
                                          'No hay mensajes en esta conversación.',
                                          style: TextStyle(color: SteamColors.textSec),
                                        ),
                                      )
                                    : ListView.separated(
                                        itemCount: chatProv.mensajes.length,
                                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                                        itemBuilder: (context, index) {
                                          final mensaje = chatProv.mensajes[index];
                                          final esPropio = mensaje['emisor_username'] == null;
                                          return Align(
                                            alignment: esPropio ? Alignment.centerRight : Alignment.centerLeft,
                                            child: Container(
                                              margin: const EdgeInsets.symmetric(horizontal: 4),
                                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                              decoration: BoxDecoration(
                                                color: esPropio ? SteamColors.blue : SteamColors.bgPanel,
                                                borderRadius: BorderRadius.circular(14),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    mensaje['mensaje_chat'] ?? '',
                                                    style: TextStyle(
                                                      color: esPropio ? Colors.white : SteamColors.light,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    mensaje['emisor_username'] ?? 'Yo',
                                                    style: TextStyle(
                                                      color: SteamColors.textSec.withOpacity(0.8),
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _mensajeController,
                                  style: const TextStyle(color: SteamColors.light),
                                  decoration: InputDecoration(
                                    hintText: 'Escribe un mensaje...',
                                    hintStyle: const TextStyle(color: SteamColors.textSec),
                                    filled: true,
                                    fillColor: SteamColors.bgPanel,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: SteamColors.blue,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: _enviarMensaje,
                                child: const Icon(Icons.send),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
