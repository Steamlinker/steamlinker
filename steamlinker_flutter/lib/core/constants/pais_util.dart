/// Códigos de país usados en perfil y publicaciones.
class PaisUtil {
  PaisUtil._();

  static const todos = 'Todos';

  static const nombres = [
    'Colombia',
    'México',
    'Argentina',
    'España',
    'EE.UU.',
  ];

  static String nombreACodigo(String nombre) {
    switch (nombre) {
      case 'Colombia':
        return 'CO';
      case 'México':
        return 'MX';
      case 'Argentina':
        return 'AR';
      case 'España':
        return 'ES';
      case 'EE.UU.':
        return 'US';
      default:
        return nombre.length <= 5 ? nombre : nombre.substring(0, 5);
    }
  }

  static String codigoANombre(String? code) {
    if (code == null || code.isEmpty) return todos;
    switch (code.toUpperCase()) {
      case 'CO':
        return 'Colombia';
      case 'MX':
        return 'México';
      case 'AR':
        return 'Argentina';
      case 'ES':
        return 'España';
      case 'US':
        return 'EE.UU.';
      default:
        return code;
    }
  }
}
