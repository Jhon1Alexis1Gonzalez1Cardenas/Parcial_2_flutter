import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_exception.dart';
import '../services/auth_service.dart';
import '../services/sesion_controller.dart';

/// Muestra la información de la sesión actual y permite cerrarla.
class SesionView extends StatefulWidget {
  const SesionView({super.key});

  @override
  State<SesionView> createState() => _SesionViewState();
}

class _SesionViewState extends State<SesionView> {
  final _sesion = SesionController.instancia;
  final _auth = AuthService();

  bool _verificando = false;
  String? _resultadoVerificacion;
  bool? _verificacionOk;

  Future<void> _verificar() async {
    setState(() {
      _verificando = true;
      _resultadoVerificacion = null;
    });
    try {
      final ok = await _auth.verificarSesion();
      _verificacionOk = ok;
      _resultadoVerificacion = ok
          ? 'El servidor confirmó que el token es válido.'
          : 'El servidor rechazó el token.';
    } on ApiException catch (e) {
      _verificacionOk = false;
      _resultadoVerificacion = e.mensaje;
    } finally {
      if (mounted) setState(() => _verificando = false);
    }
  }

  Future<void> _cerrarSesion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('Se eliminarán el token y los datos locales de la sesión.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Cerrar sesión')),
        ],
      ),
    );
    if (confirmar == true) {
      // Borra token (secure storage) y datos (shared_preferences); el router va al login.
      await _auth.cerrarSesion();
    }
  }

  String _fecha(DateTime f) {
    String d(int n) => n.toString().padLeft(2, '0');
    return '${d(f.day)}/${d(f.month)}/${f.year} ${d(f.hour)}:${d(f.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final usuario = _sesion.usuario;
    final token = _sesion.token;
    final activa = _sesion.autenticado;
    final expira = token == null ? null : SesionController.expiracionDe(token);

    return Scaffold(
      appBar: AppBar(title: const Text('Mi sesión')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: tema.colorScheme.primary,
                    child: Text(
                      (usuario?.nombre.isNotEmpty ?? false) ? usuario!.nombre[0].toUpperCase() : '?',
                      style: TextStyle(fontSize: 30, color: tema.colorScheme.onPrimary),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    usuario?.nombre ?? 'Sin usuario',
                    style: tema.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(usuario?.email ?? '-'),
                  const SizedBox(height: 12),
                  Chip(
                    avatar: Icon(
                      activa ? Icons.check_circle : Icons.cancel,
                      color: activa ? Colors.green : tema.colorScheme.error,
                    ),
                    label: Text(activa ? 'Sesión activa' : 'Sin sesión'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.vpn_key_outlined),
                  title: const Text('Token almacenado'),
                  subtitle: Text(token == null
                      ? 'No existe (flutter_secure_storage vacío)'
                      : 'Sí existe · ${SesionController.enmascarar(token)}'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.schedule),
                  title: const Text('Vence'),
                  subtitle: Text(expira == null ? '-' : _fecha(expira)),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.lock_outline),
                  title: Text('Dónde se guarda'),
                  subtitle: Text(
                    'Token: flutter_secure_storage (cifrado)\n'
                    'Nombre y correo: shared_preferences',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FutureBuilder<SharedPreferences>(
            future: SharedPreferences.getInstance(),
            builder: (context, snap) {
              final prefs = snap.data;
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.storage_outlined),
                  title: const Text('Datos locales (shared_preferences)'),
                  subtitle: Text(prefs == null
                      ? 'Cargando...'
                      : 'usuario_nombre: ${prefs.getString('usuario_nombre') ?? '-'}\n'
                          'usuario_email: ${prefs.getString('usuario_email') ?? '-'}'),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _verificando ? null : _verificar,
            icon: _verificando
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.verified_user_outlined),
            label: const Text('Verificar sesión con el servidor'),
          ),
          if (_resultadoVerificacion != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _resultadoVerificacion!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _verificacionOk == true ? Colors.green.shade700 : tema.colorScheme.error,
                ),
              ),
            ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _cerrarSesion,
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}
