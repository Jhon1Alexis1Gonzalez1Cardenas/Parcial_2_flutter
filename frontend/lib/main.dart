import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'config/app_config.dart';
import 'routes/app_router.dart';
import 'services/auth_service.dart';
import 'services/sesion_controller.dart';
import 'themes/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Carga la configuración (URL de la API) desde el archivo .env
  await dotenv.load(fileName: '.env');
  // Recupera la sesión guardada (token en secure storage + datos en shared_preferences).
  await SesionController.instancia.cargar();
  runApp(const InventarioApp());
  // Verifica con el backend que el token guardado siga siendo válido (sin bloquear el arranque).
  AuthService().verificarSesion().catchError((_) => false);
}

class InventarioApp extends StatelessWidget {
  const InventarioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConfig.nombreApp,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
