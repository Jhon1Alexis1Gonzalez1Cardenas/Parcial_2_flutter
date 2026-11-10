import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/usuario.dart';

/// Maneja el estado de la sesión y su almacenamiento local:
///  - flutter_secure_storage  -> access_token (dato sensible, cifrado)
///  - shared_preferences      -> nombre y correo (datos no sensibles)
/// go_router lo escucha (refreshListenable) para proteger las rutas.
class SesionController extends ChangeNotifier {
  SesionController._();

  static final SesionController instancia = SesionController._();

  static const _claveToken = 'access_token';
  static const _claveNombre = 'usuario_nombre';
  static const _claveEmail = 'usuario_email';
  static const _claveId = 'usuario_id';

  // Cifrado por defecto (Keystore en Android, Keychain en iOS).
  final FlutterSecureStorage _seguro = const FlutterSecureStorage();

  String? _token;
  Usuario? _usuario;

  /// Mensaje para mostrar en el login (por ejemplo "tu sesión expiró").
  String? mensajeSesion;

  /// El token vive también en memoria para no leer el almacenamiento en cada petición.
  String? get token => _token;
  Usuario? get usuario => _usuario;
  bool get autenticado => _token != null && _usuario != null;

  /// Se llama una vez al abrir la app: recupera la sesión guardada (si sigue vigente).
  Future<void> cargar() async {
    final token = await _seguro.read(key: _claveToken);
    final prefs = await SharedPreferences.getInstance();
    final nombre = prefs.getString(_claveNombre);
    final email = prefs.getString(_claveEmail);
    final id = prefs.getInt(_claveId);

    if (token == null || nombre == null || email == null || id == null) {
      await _borrarTodo();
      return;
    }
    if (tokenExpirado(token)) {
      await _borrarTodo();
      mensajeSesion = 'Tu sesión expiró. Inicia sesión nuevamente.';
      return;
    }
    _token = token;
    _usuario = Usuario(id: id, nombre: nombre, email: email);
  }

  Future<void> guardarSesion(String token, Usuario usuario) async {
    await _seguro.write(key: _claveToken, value: token);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_claveNombre, usuario.nombre);
    await prefs.setString(_claveEmail, usuario.email);
    await prefs.setInt(_claveId, usuario.id);
    _token = token;
    _usuario = usuario;
    mensajeSesion = null;
    notifyListeners();
  }

  /// Cierra la sesión: elimina token y datos locales. El router redirige al login.
  Future<void> cerrarSesion({String? mensaje}) async {
    await _borrarTodo();
    mensajeSesion = mensaje;
    notifyListeners();
  }

  Future<void> _borrarTodo() async {
    _token = null;
    _usuario = null;
    await _seguro.delete(key: _claveToken);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_claveNombre);
    await prefs.remove(_claveEmail);
    await prefs.remove(_claveId);
  }

  // ---------------------- utilidades para leer el JWT -----------------------

  /// Fecha de expiración (claim "exp") del token, o null si no se puede leer.
  static DateTime? expiracionDe(String token) {
    try {
      final partes = token.split('.');
      if (partes.length != 3) return null;
      final json = utf8.decode(base64Url.decode(base64Url.normalize(partes[1])));
      final exp = (jsonDecode(json) as Map<String, dynamic>)['exp'];
      if (exp is! num) return null;
      return DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000);
    } catch (_) {
      return null;
    }
  }

  static bool tokenExpirado(String token) {
    final exp = expiracionDe(token);
    return exp == null || DateTime.now().isAfter(exp);
  }

  /// Versión enmascarada para mostrar en pantalla (nunca el token completo).
  static String enmascarar(String token) =>
      '${token.substring(0, token.length < 8 ? token.length : 8)}•••••• (${token.length} caracteres)';
}
