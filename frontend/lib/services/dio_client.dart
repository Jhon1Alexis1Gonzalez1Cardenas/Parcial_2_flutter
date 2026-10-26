import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';

/// Cliente Dio único para toda la app, configurado con la URL del archivo .env.
class DioClient {
  DioClient._();

  // Se crea la primera vez que se usa (después de cargar el .env en main).
  static final Dio instancia = _crear();

  static Dio _crear() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
        headers: const {'Accept': 'application/json'},
      ),
    );

    // Muestra en consola las peticiones y respuestas (solo en modo debug).
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
    }
    return dio;
  }
}
