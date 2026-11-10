import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import 'sesion_controller.dart';

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

    // Interceptor de autenticación: agrega "Authorization: Bearer <token>" a las
    // peticiones y, si la API responde 401, cierra la sesión (el router lleva al login).
    dio.interceptors.add(_interceptorAuth());

    // Muestra en consola las peticiones y respuestas (solo en modo debug).
    // requestHeader en false para no imprimir el token en la consola.
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(requestHeader: false, requestBody: true, responseBody: false),
      );
    }
    return dio;
  }

  static const _rutaLogin = '/auth/login';

  static InterceptorsWrapper _interceptorAuth() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = SesionController.instancia.token;
        if (token != null && options.path != _rutaLogin) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final sesion = SesionController.instancia;
        final esLogin = error.requestOptions.path == _rutaLogin;
        if (error.response?.statusCode == 401 && !esLogin && sesion.token != null) {
          await sesion.cerrarSesion(
            mensaje: 'Tu sesión expiró o ya no es válida. Inicia sesión nuevamente.',
          );
        }
        handler.next(error);
      },
    );
  }
}
