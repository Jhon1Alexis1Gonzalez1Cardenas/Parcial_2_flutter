import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../config/app_config.dart';
import '../config/formato.dart';
import '../models/resumen_inventario.dart';
import '../services/api_exception.dart';
import '../services/producto_service.dart';
import '../widgets/estado_vista.dart';
import '../widgets/stat_card.dart';

/// Pantalla de inicio: identidad de la app e indicadores reales del inventario.
class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final _service = ProductoService();
  late Future<ResumenInventario> _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = _cargar();
  }

  Future<ResumenInventario> _cargar() async {
    final productos = await _service.listar();
    return ResumenInventario.desde(productos);
  }

  void _recargar() {
    setState(() {
      _futuro = _cargar();
    });
  }

  Future<void> _refrescar() async {
    final nuevo = _cargar();
    setState(() {
      _futuro = nuevo;
    });
    try {
      await nuevo;
    } catch (_) {
      // El error se muestra en el FutureBuilder.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppConfig.nombreApp)),
      body: FutureBuilder<ResumenInventario>(
        future: _futuro,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const EstadoCargando();
          }
          if (snapshot.hasError) {
            return EstadoError(
              mensaje: mensajeDeError(snapshot.error!),
              onReintentar: _recargar,
            );
          }

          final resumen = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _refrescar,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const _Encabezado(),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: StatCard(
                        icono: Icons.inventory_2_outlined,
                        titulo: 'Productos registrados',
                        valor: formatoMiles(resumen.totalProductos),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        icono: Icons.layers_outlined,
                        titulo: 'Unidades en inventario',
                        valor: formatoMiles(resumen.totalUnidades),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                StatCard(
                  icono: Icons.attach_money,
                  titulo: 'Valor total del inventario',
                  valor: formatoPesos(resumen.valorTotal),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => context.go('/productos'),
                    icon: const Icon(Icons.list_alt),
                    label: const Text('Gestionar productos'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado();

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFB71C1C), Color(0xFFE53935)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Icon(Icons.inventory_2, size: 30, color: Color(0xFFB71C1C)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConfig.nombreApp,
                  style: textos.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Control de productos y existencias',
                  style: textos.bodyMedium?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
