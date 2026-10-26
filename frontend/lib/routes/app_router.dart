import 'package:go_router/go_router.dart';

import '../views/dashboard_view.dart';
import '../views/home_shell.dart';
import '../views/producto_detalle_view.dart';
import '../views/producto_form_view.dart';
import '../views/productos_view.dart';

int _idDe(GoRouterState state) =>
    int.tryParse(state.pathParameters['id'] ?? '') ?? -1;

/// Rutas de la app. El ShellRoute mantiene visible el menú inferior.
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) =>
          HomeShell(ubicacion: state.uri.path, child: child),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const DashboardView(),
        ),
        GoRoute(
          path: '/productos',
          builder: (context, state) => const ProductosView(),
        ),
        // "nuevo" va antes que ":id" para que no se confunda con un id.
        GoRoute(
          path: '/productos/nuevo',
          builder: (context, state) => const ProductoFormView(),
        ),
        GoRoute(
          path: '/productos/:id',
          builder: (context, state) =>
              ProductoDetalleView(productoId: _idDe(state)),
        ),
        GoRoute(
          path: '/productos/:id/editar',
          builder: (context, state) =>
              ProductoFormView(productoId: _idDe(state)),
        ),
      ],
    ),
  ],
);
