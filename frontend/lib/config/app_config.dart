import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuración general de la app.
class AppConfig {
  AppConfig._();

  /// Nombre visible de la app (cámbialo aquí si quieres otro).
  static const String nombreApp = 'Inventario Rojo';

  /// URL base de la API, definida en el archivo .env (clave API_BASE_URL).
  static String get apiBaseUrl {
    final url = dotenv.env['API_BASE_URL']?.trim();
    if (url == null || url.isEmpty) {
      throw StateError('Falta la clave API_BASE_URL en el archivo .env');
    }
    return url;
  }
}
