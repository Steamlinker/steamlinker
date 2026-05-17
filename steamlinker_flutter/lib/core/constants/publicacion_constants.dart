class PublicacionConstants {
  PublicacionConstants._();

  static const ordenRecientes = 'recientes';
  static const ordenReputacion = 'reputacion';

  static const Map<String, String> tipoEtiquetas = {
    'busco_familia': 'Busco familia',
    'busco_miembros': 'Busco miembros',
    'otro': 'Otro',
  };

  static const List<String> tiposCrearEtiquetas = [
    'Busco familia',
    'Busco miembros',
    'Otro',
  ];

  static const List<String> tiposCrearValores = [
    'busco_familia',
    'busco_miembros',
    'otro',
  ];

  static const List<String> tiposFiltroEtiquetas = [
    'Todos los tipos',
    'Busco familia',
    'Busco miembros',
    'Otro',
  ];

  static const List<String> tiposFiltroValores = [
    '',
    'busco_familia',
    'busco_miembros',
    'otro',
  ];

  static String etiquetaTipo(String? tipo) {
    if (tipo == null || tipo.isEmpty) return 'General';
    return tipoEtiquetas[tipo] ?? tipo;
  }

  static String valorTipoCrear(String etiqueta) {
    final i = tiposCrearEtiquetas.indexOf(etiqueta);
    return i >= 0 ? tiposCrearValores[i] : 'otro';
  }

  static String valorTipoFiltro(String etiqueta) {
    final i = tiposFiltroEtiquetas.indexOf(etiqueta);
    return i >= 0 ? tiposFiltroValores[i] : '';
  }
}
