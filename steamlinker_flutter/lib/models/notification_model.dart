import 'package:flutter/material.dart';
import '../theme/colors.dart';

enum NotifType { match, reply, achievement, offer, friend, update, comment }

class NotificationModel {
  final String id;
  final NotifType type;
  final String title;
  final String body;
  final String time;
  final String avatar;
  bool isRead;
  bool? interested;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.time,
    required this.avatar,
    this.isRead = false,
    this.interested,
  });

  Color get typeColor => switch (type) {
        NotifType.match       => SteamColors.purple,
        NotifType.reply       => SteamColors.blue,
        NotifType.comment     => SteamColors.teal,
        NotifType.achievement => SteamColors.yellow,
        NotifType.friend      => SteamColors.green,
        NotifType.offer       => SteamColors.orange,
        NotifType.update      => SteamColors.muted,
      };

  IconData get typeIcon => switch (type) {
        NotifType.match       => Icons.favorite_rounded,
        NotifType.reply       => Icons.reply_rounded,
        NotifType.comment     => Icons.comment_rounded,
        NotifType.achievement => Icons.emoji_events_rounded,
        NotifType.friend      => Icons.person_add_rounded,
        NotifType.offer       => Icons.local_offer_rounded,
        NotifType.update      => Icons.system_update_rounded,
      };

  String get typeLabel => switch (type) {
        NotifType.match       => 'MATCH',
        NotifType.reply       => 'RESPUESTA',
        NotifType.comment     => 'COMENTARIO',
        NotifType.achievement => 'LOGRO',
        NotifType.friend      => 'AMIGO',
        NotifType.offer       => 'OFERTA',
        NotifType.update      => 'ACTUALIZACIÓN',
      };
}

// ── Datos de ejemplo ──────────────────────────────────────────────────────
final List<NotificationModel> sampleNotifications = [
  NotificationModel(
    id: '1', type: NotifType.match,
    title: '¡Nuevo Match!',
    body: 'XanderFury_22 y tú tienen los mismos 3 juegos favoritos. ¡Podría ser un buen compañero de partida!',
    time: 'Hace 5 min', avatar: 'XF', isRead: false,
  ),
  NotificationModel(
    id: '2', type: NotifType.reply,
    title: 'Respondieron tu publicación',
    body: 'NightWalker_85 comentó en tu post "¿Alguien más para Elden Ring esta noche?": "¡Cuenten conmigo! Soy SL 120."',
    time: 'Hace 18 min', avatar: 'NW', isRead: false,
  ),
  NotificationModel(
    id: '3', type: NotifType.comment,
    title: 'Nueva respuesta en tu hilo',
    body: 'CryptoGrrl respondió a tu comentario en el foro de CS2: "Totalmente de acuerdo con tu análisis del meta."',
    time: 'Hace 42 min', avatar: 'CG', isRead: false,
  ),
  NotificationModel(
    id: '4', type: NotifType.achievement,
    title: 'Logro desbloqueado',
    body: 'Celebramos tu 30.º día en SteamLinker. ¡Ya eres un miembro destacado!',
    time: 'Hace 2 h', avatar: '🎮', isRead: true,
  ),
  NotificationModel(
    id: '5', type: NotifType.friend,
    title: 'Nueva solicitud de amistad',
    body: 'Phoenix_Storm quiere ser tu amigo. Aceptar o rechazar.',
    time: 'Hace 3 h', avatar: 'PS', isRead: true,
  ),
];
