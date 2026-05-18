import 'package:flutter/material.dart';
import '../../features/amistad/providers/amistad_provider.dart';
import '../../features/matches/providers/matches_provider.dart';
import '../../theme/colors.dart';

/// Resumen de la relación entre el usuario actual y otro usuario.
class RelacionResumen {
  final String? matchEstado;
  final bool matchSoySolicitante;
  final int? idMatch;
  final String? amistadEstado;
  final bool amistadSoySolicitante;
  final int? idAmistad;

  const RelacionResumen({
    this.matchEstado,
    this.matchSoySolicitante = false,
    this.idMatch,
    this.amistadEstado,
    this.amistadSoySolicitante = false,
    this.idAmistad,
  });

  factory RelacionResumen.desdeApi(Map<String, dynamic> data) {
    final match = data['match'] as Map<String, dynamic>?;
    final amistad = data['amistad'] as Map<String, dynamic>?;
    return RelacionResumen(
      matchEstado: match?['estado']?.toString(),
      matchSoySolicitante: match?['soy_solicitante'] == true,
      idMatch: match?['id_match'] as int?,
      amistadEstado: amistad?['estado']?.toString(),
      amistadSoySolicitante: amistad?['soy_solicitante'] == true,
      idAmistad: amistad?['id_amistad'] as int?,
    );
  }

  factory RelacionResumen.desdeListas({
    required int miId,
    required int otroId,
    required List<dynamic> matchesRecibidos,
    required List<dynamic> matchesEnviados,
    required List<dynamic> amigos,
    required List<dynamic> solicitudesAmistad,
  }) {
    String? matchEstado;
    bool matchSoySolicitante = false;
    int? idMatch;

    for (final m in matchesEnviados) {
      final map = Map<String, dynamic>.from(m as Map);
      if (map['id_receptor'] == otroId) {
        matchEstado = map['estado_match']?.toString();
        matchSoySolicitante = true;
        idMatch = map['id_match'] as int?;
        break;
      }
    }

    if (matchEstado == null) {
      for (final m in matchesRecibidos) {
        final map = Map<String, dynamic>.from(m as Map);
        if (map['id_solicitante'] == otroId) {
          matchEstado = map['estado_match']?.toString();
          matchSoySolicitante = false;
          idMatch = map['id_match'] as int?;
          break;
        }
      }
    }

    String? amistadEstado;
    bool amistadSoySolicitante = false;
    int? idAmistad;

    for (final a in amigos) {
      final map = Map<String, dynamic>.from(a as Map);
      if (map['amigo_id'] == otroId) {
        amistadEstado = 'Aceptada';
        amistadSoySolicitante = map['id_solicitante'] == miId;
        idAmistad = map['id_amistad'] as int?;
        break;
      }
    }

    if (amistadEstado == null) {
      for (final a in solicitudesAmistad) {
        final map = Map<String, dynamic>.from(a as Map);
        if (map['id_solicitante'] == otroId) {
          amistadEstado = map['estado_amistad']?.toString() ?? 'Pendiente';
          amistadSoySolicitante = false;
          idAmistad = map['id_amistad'] as int?;
          break;
        }
      }
    }

    return RelacionResumen(
      matchEstado: matchEstado,
      matchSoySolicitante: matchSoySolicitante,
      idMatch: idMatch,
      amistadEstado: amistadEstado,
      amistadSoySolicitante: amistadSoySolicitante,
      idAmistad: idAmistad,
    );
  }

  bool get matchAceptado => matchEstado == 'Aceptada';
  bool get matchPendiente => matchEstado == 'Pendiente';
  bool get sonAmigos => amistadEstado == 'Aceptada';
  bool get amistadPendiente => amistadEstado == 'Pendiente';

  bool get puedeEnviarMatch =>
      matchEstado != 'Pendiente' && matchEstado != 'Aceptada';

  bool get puedeEnviarAmistad =>
      amistadEstado != 'Pendiente' && amistadEstado != 'Aceptada';

  /// Etiqueta principal para chips (prioridad: match aceptado > amigos > pendientes).
  String? get etiquetaPrincipal {
    if (matchEstado == 'Aceptada') return 'Match activo';
    if (amistadEstado == 'Aceptada') return 'Amigos';
    if (matchEstado == 'Pendiente') {
      return matchSoySolicitante ? 'Match enviado' : 'Match recibido';
    }
    if (amistadEstado == 'Pendiente') {
      return amistadSoySolicitante ? 'Amistad enviada' : 'Te agregó';
    }
    return null;
  }

  Color get colorEtiqueta {
    if (matchEstado == 'Aceptada' || amistadEstado == 'Aceptada') {
      return SteamColors.green;
    }
    if (matchEstado == 'Pendiente' || amistadEstado == 'Pendiente') {
      return matchSoySolicitante || amistadSoySolicitante
          ? SteamColors.yellow
          : SteamColors.orange;
    }
    return SteamColors.muted;
  }

  static RelacionResumen? paraUsuario({
    required int? miId,
    required int? otroId,
    required MatchesProvider matches,
    required AmistadProvider amistad,
  }) {
    if (miId == null || otroId == null || miId == otroId) return null;
    return RelacionResumen.desdeListas(
      miId: miId,
      otroId: otroId,
      matchesRecibidos: matches.recibidos,
      matchesEnviados: matches.enviados,
      amigos: amistad.amigos,
      solicitudesAmistad: amistad.solicitudes,
    );
  }
}
