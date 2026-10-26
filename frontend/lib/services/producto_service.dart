import 'package:dio/dio.dart';

import '../models/producto.dart';
import 'api_exception.dart';
import 'dio_client.dart';

/// Toda la comunicación HTTP con la API de productos vive aquí.
/// Las vistas nunca usan Dio directamente.
class ProductoService {
  ProductoService({Dio? dio}) : _dio = dio ?? DioClient.instancia;

  final Dio _dio;

  /// GET /productos
  Future<List<Producto>> listar() async {
    try {
      final respuesta = await _dio.get('/productos');
      final datos = respuesta.data as List<dynamic>;
      return datos
          .map((item) => Producto.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _traducir(e);
    }
  }

  /// GET /productos/{id}
  Future<Producto> obtener(int id) async {
    try {
      final respuesta = await _dio.get('/productos/$id');
      return Producto.fromJson(respuesta.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _traducir(e);
    }
  }

  /// POST /productos
  Future<Producto> crear(Producto producto) async {
    try {
      final respuesta = await _dio.post('/productos', data: producto.toJson());
      return Producto.fromJson(respuesta.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _traducir(e);
    }
  }

  /// PUT /productos/{id}
  Future<Producto> actualizar(Producto producto) async {
    try {
      final respuesta = await _dio.put(
        '/productos/${producto.id}',
        data: producto.toJson(),
      );
      return Producto.fromJson(respuesta.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _traducir(e);
    }
  }

  /// DELETE /productos/{id}
  Future<void> eliminar(int id) async {
    try {
      await _dio.delete('/productos/$id');
    } on DioException catch (e) {
      throw _traducir(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Manejo de errores de Dio
  // ---------------------------------------------------------------------------

  ApiException _traducir(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const ApiException(
          'El servidor tardó demasiado en responder. Verifica que la API esté activa.',
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          'No se pudo conectar con el servidor. Revisa la URL del archivo .env y que la API esté en ejecución.',
        );
      case DioExceptionType.cancel:
        return const ApiException('La petición fue cancelada.');
      case DioExceptionType.badCertificate:
        return const ApiException(
          'El certificado de seguridad del servidor no es válido.',
        );
      case DioExceptionType.badResponse:
        return _desdeRespuesta(e.response);
      case DioExceptionType.unknown:
        return const ApiException('Error de comunicación con el servidor.');
    }
  }

  ApiException _desdeRespuesta(Response<dynamic>? respuesta) {
    final codigo = respuesta?.statusCode;
    final detalle = _extraerDetalle(respuesta?.data);

    if (codigo == 404) {
      return ApiException(
        detalle ?? 'El producto no existe.',
        codigoHttp: codigo,
      );
    }
    if (codigo == 422) {
      return ApiException(
        detalle ?? 'Datos inválidos. Revisa el formulario.',
        codigoHttp: codigo,
      );
    }
    if (codigo != null && codigo >= 500) {
      return ApiException(
        'Error interno del servidor ($codigo).',
        codigoHttp: codigo,
      );
    }
    return ApiException(
      detalle ?? 'Error inesperado del servidor ($codigo).',
      codigoHttp: codigo,
    );
  }

  /// FastAPI responde {"detail": "texto"} o {"detail": [{"loc": [...], "msg": "..."}]}.
  String? _extraerDetalle(dynamic data) {
    if (data is Map && data['detail'] != null) {
      final detail = data['detail'];
      if (detail is String) return detail;
      if (detail is List) {
        final mensajes = detail.whereType<Map>().map((item) {
          final loc = item['loc'];
          final campo = (loc is List && loc.isNotEmpty)
              ? loc.last.toString()
              : 'dato';
          return '$campo: ${item['msg']}';
        }).toList();
        if (mensajes.isNotEmpty) return mensajes.join('\n');
      }
    }
    return null;
  }
}
