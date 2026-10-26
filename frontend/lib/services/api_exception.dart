/// Error de comunicación con la API, con un mensaje listo para mostrar al usuario.
class ApiException implements Exception {
  const ApiException(this.mensaje, {this.codigoHttp});

  final String mensaje;
  final int? codigoHttp;

  @override
  String toString() => mensaje;
}

/// Devuelve un mensaje amigable para cualquier error capturado en la interfaz.
String mensajeDeError(Object error) {
  if (error is ApiException) return error.mensaje;
  return 'Ocurrió un error inesperado. Intenta de nuevo.';
}
