import 'package:flutter/material.dart';
import '../theme/colors.dart';

enum NotifType {
  match,
  matchAceptado,
  friend,
  friendAceptado,
  mensaje,
  reply,
  achievement,
  offer,
  update,
  comment,
}

class NotificationModel {
  final String id;
  final NotifType type;
  final String title;
  final String body;
  final String time;
  final String avatar;
  bool isRead;
  bool? interested;
  final String? refTipo;
  final int? refId;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.time,
    required this.avatar,
    this.isRead = false,
    this.interested,
    this.refTipo,
    this.refId,
  });

  factory NotificationModel.fromApi(Map<String, dynamic> raw) {
    final creado = raw['creadoen_noti'];
    final interesRaw = raw['interes_noti'];

    return NotificationModel(
      id: raw['id_noti'].toString(),
      type: _tipoDesdeApi(raw['tipo_noti']?.toString() ?? ''),
      title: raw['titulo_noti'] ?? '',
      body: raw['cuerpo_noti'] ?? '',
      time: _tiempoRelativo(creado),
      avatar: raw['avatar_noti']?.toString() ?? '?',
      isRead: raw['leida_noti'] == true,
      interested: interesRaw == 1
          ? true
          : interesRaw == -1
              ? false
              : null,
      refTipo: raw['ref_tipo']?.toString(),
      refId: raw['ref_id'] is int
          ? raw['ref_id'] as int
          : int.tryParse(raw['ref_id']?.toString() ?? ''),
    );
  }

  static NotifType _tipoDesdeApi(String tipo) {
    switch (tipo) {
      case 'match':
        return NotifType.match;
      case 'match_aceptado':
        return NotifType.matchAceptado;
      case 'friend':
        return NotifType.friend;
      case 'friend_aceptado':
        return NotifType.friendAceptado;
      case 'mensaje':
      case 'chat':
        return NotifType.mensaje;
      case 'reply':
        return NotifType.reply;
      case 'comment':
        return NotifType.comment;
      case 'achievement':
        return NotifType.achievement;
      case 'offer':
        return NotifType.offer;
      default:
        return NotifType.update;
    }
  }

  static String _tiempoRelativo(dynamic fecha) {
    if (fecha == null) return '';
    DateTime dt;
    if (fecha is String) {
      dt = DateTime.tryParse(fecha) ?? DateTime.now();
    } else {
      return '';
    }
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} d';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  Color get typeColor => switch (type) {
        NotifType.match || NotifType.matchAceptado => SteamColors.purple,
        NotifType.friend || NotifType.friendAceptado => SteamColors.green,
        NotifType.mensaje => SteamColors.blue,
        NotifType.reply => SteamColors.blue,
        NotifType.comment => SteamColors.teal,
        NotifType.achievement => SteamColors.yellow,
        NotifType.offer => SteamColors.orange,
        NotifType.update => SteamColors.muted,
      };

  IconData get typeIcon => switch (type) {
        NotifType.match || NotifType.matchAceptado => Icons.handshake_outlined,
        NotifType.friend || NotifType.friendAceptado => Icons.person_add_rounded,
        NotifType.mensaje => Icons.chat_bubble_outline_rounded,
        NotifType.reply => Icons.reply_rounded,
        NotifType.comment => Icons.comment_rounded,
        NotifType.achievement => Icons.emoji_events_rounded,
        NotifType.offer => Icons.local_offer_rounded,
        NotifType.update => Icons.notifications_outlined,
      };

  String get typeLabel => switch (type) {
        NotifType.match => 'MATCH',
        NotifType.matchAceptado => 'MATCH OK',
        NotifType.friend => 'AMIGO',
        NotifType.friendAceptado => 'AMIGO OK',
        NotifType.mensaje => 'MENSAJE',
        NotifType.reply => 'RESPUESTA',
        NotifType.comment => 'COMENTARIO',
        NotifType.achievement => 'LOGRO',
        NotifType.offer => 'OFERTA',
        NotifType.update => 'AVISO',
      };
}
