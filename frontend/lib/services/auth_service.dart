import 'package:dio/dio.dart';

import '../models/usuario.dart';
import 'api_exception.dart';
import 'dio_client.dart';
import 'sesion_controller.dart';

/// Peticiones de autenticación contra la API (login y verificación de sesión).
class AuthService {
  AuthService({Dio? dio, SesionController? sesion})
      : _dio = dio ?? DioClient.instancia,
        _sesion = sesion ?? SesionController.instancia;

  final Dio _dio;
  final SesionController _sesion;

  /// POST /auth/login -> guarda el token (secure storage) y los datos del usuario.
  Future<void> iniciarSesion(String email, String password) async {
    try {
      final respuesta = await _dio.post(
        '/auth/login',
        data: {'email': email.trim(), 'password': password},
      );
      final datos = respuesta.data as Map<String, dynamic>;
      await _sesion.guardarSesion(
        datos['access_token'] as String,
        Usuario.fromJson(datos['usuario'] as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw _traducir(e);
    }
  }

  /// GET /auth/me -> confirma con el backend que el token sigue siendo válido.
  /// Devuelve true si la sesión es válida. Si el token es rechazado (401), el
  /// interceptor de Dio ya cierra la sesión. Si no hay conexión, lanza ApiException.
  Future<bool> verificarSesion() async {
    if (!_sesion.autenticado) return false;
    try {
      await _dio.get('/auth/me');
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) return false;
      throw _traducir(e);
    }
  }

  Future<void> cerrarSesion() => _sesion.cerrarSesion();

  ApiException _traducir(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          'El servidor tardó demasiado en responder. Verifica que la API esté activa.',
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          'No se pudo conectar con el servidor. Revisa la URL del .env y que la API esté en ejecución.',
        );
      case DioExceptionType.badResponse:
        final codigo = e.response?.statusCode;
        if (codigo == 401) {
          return ApiException('Correo o contraseña incorrectos.', codigoHttp: codigo);
        }
        if (codigo == 422) {
          return ApiException('Ingresa un correo y una contraseña válidos.', codigoHttp: codigo);
        }
        if (codigo != null && codigo >= 500) {
          return ApiException('Error interno del servidor ($codigo).', codigoHttp: codigo);
        }
        return ApiException('Error inesperado del servidor ($codigo).', codigoHttp: codigo);
      default:
        return const ApiException('Error de comunicación con el servidor.');
    }
  }
}
