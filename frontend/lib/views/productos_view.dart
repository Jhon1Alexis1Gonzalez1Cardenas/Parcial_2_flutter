import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/producto.dart';
import '../services/api_exception.dart';
import '../services/producto_service.dart';
import '../widgets/estado_vista.dart';
import '../widgets/producto_tile.dart';

/// Lista de productos obtenida desde la API.
class ProductosView extends StatefulWidget {
  const ProductosView({super.key});

  @override
  State<ProductosView> createState() => _ProductosViewState();
}

class _ProductosViewState extends State<ProductosView> {
  final _service = ProductoService();
  late Future<List<Producto>> _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = _service.listar();
  }

  void _recargar() {
    setState(() {
      _futuro = _service.listar();
    });
  }

  Future<void> _refrescar() async {
    final nuevo = _service.listar();
    setState(() {
      _futuro = nuevo;
    });
    try {
      await nuevo;
    } catch (_) {
      // El error se muestra en el FutureBuilder.
    }
  }

  Future<void> _abrirDetalle(Producto producto) async {
    await context.push('/productos/${producto.id}');
    // Al volver (por si se editó o eliminó), se recarga la lista.
    if (mounted) _recargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _recargar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Nuevo producto',
        onPressed: () => context.go('/productos/nuevo'),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Producto>>(
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

          final productos = snapshot.data!;
          if (productos.isEmpty) {
            return EstadoVacio(
              mensaje: 'Aún no hay productos registrados',
              etiquetaAccion: 'Registrar producto',
              onAccion: () => context.go('/productos/nuevo'),
            );
          }

          return RefreshIndicator(
            onRefresh: _refrescar,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
              itemCount: productos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, indice) {
                final producto = productos[indice];
                return ProductoTile(
                  producto: producto,
                  onTap: () => _abrirDetalle(producto),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
