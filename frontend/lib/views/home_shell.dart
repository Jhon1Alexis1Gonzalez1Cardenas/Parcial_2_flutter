import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Contenedor con el menú de navegación inferior. Las vistas se muestran en [child].
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.ubicacion, required this.child});

  /// Ruta actual (por ejemplo "/productos"), usada para marcar la pestaña activa.
  final String ubicacion;
  final Widget child;

  int get _indiceActual {
    if (ubicacion.startsWith('/productos/nuevo')) return 2;
    if (ubicacion.startsWith('/productos')) return 1;
    return 0;
  }

  void _navegar(BuildContext context, int indice) {
    switch (indice) {
      case 0:
        context.go('/');
      case 1:
        context.go('/productos');
      case 2:
        context.go('/productos/nuevo');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indiceActual,
        onDestinationSelected: (indice) => _navegar(context, indice),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Productos',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_box_outlined),
            selectedIcon: Icon(Icons.add_box),
            label: 'Nuevo',
          ),
        ],
      ),
    );
  }
}
