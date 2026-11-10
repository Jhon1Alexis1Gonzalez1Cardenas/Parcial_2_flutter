import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../services/api_exception.dart';
import '../services/auth_service.dart';
import '../services/sesion_controller.dart';

/// Pantalla de inicio de sesión. Al autenticarse, el router redirige al dashboard.
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _auth = AuthService();

  bool _cargando = false;
  bool _ocultarPass = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _ingresar() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      await _auth.iniciarSesion(_emailCtrl.text, _passCtrl.text);
      // El redirect de go_router lleva al dashboard al cambiar la sesión.
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    } catch (_) {
      if (mounted) setState(() => _error = 'Ocurrió un error inesperado. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    // Aviso de sesión (por ejemplo: "tu sesión expiró").
    final aviso = SesionController.instancia.mensajeSesion;
    final mensaje = _error ?? aviso;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: tema.colorScheme.primary,
                      child: Icon(Icons.inventory_2, size: 36, color: tema.colorScheme.onPrimary),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppConfig.nombreApp,
                      textAlign: TextAlign.center,
                      style: tema.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: tema.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Inicia sesión para continuar',
                      textAlign: TextAlign.center,
                      style: tema.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 28),
                    if (mensaje != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: tema.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: tema.colorScheme.onErrorContainer),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                mensaje,
                                style: TextStyle(color: tema.colorScheme.onErrorContainer),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        final texto = v?.trim() ?? '';
                        if (texto.isEmpty) return 'Ingresa tu correo';
                        if (!texto.contains('@') || !texto.contains('.')) {
                          return 'Ingresa un correo válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: _ocultarPass,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _ingresar(),
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(_ocultarPass ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          onPressed: () => setState(() => _ocultarPass = !_ocultarPass),
                        ),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Ingresa tu contraseña' : null,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _cargando ? null : _ingresar,
                      style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                      icon: _cargando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.login),
                      label: Text(_cargando ? 'Ingresando...' : 'Iniciar sesión'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
