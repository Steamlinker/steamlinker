/// Comprueba el rol del usuario devuelto por el API (`tipo` / `tipo_usu`).
bool esUsuarioAdmin(Map<String, dynamic>? usuario) {
  if (usuario == null) return false;
  final tipo = (usuario['tipo'] ?? usuario['tipo_usu'] ?? '')
      .toString()
      .trim()
      .toLowerCase();
  return tipo == 'admin';
}

String etiquetaTipoCuenta(Map<String, dynamic>? usuario) {
  if (esUsuarioAdmin(usuario)) return 'Administrador';
  final tipo = (usuario?['tipo'] ?? usuario?['tipo_usu'] ?? 'usuario')
      .toString()
      .trim();
  if (tipo.isEmpty) return 'Usuario';
  return tipo[0].toUpperCase() + tipo.substring(1).toLowerCase();
}
