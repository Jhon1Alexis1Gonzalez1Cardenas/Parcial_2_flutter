import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../config/formato.dart';
import '../models/producto.dart';
import '../services/api_exception.dart';
import '../services/producto_service.dart';
import '../widgets/estado_vista.dart';

/// Detalle completo de un producto, con acciones para editar y eliminar.
class ProductoDetalleView extends StatefulWidget {
  const ProductoDetalleView({super.key, required this.productoId});

  final int productoId;

  @override
  State<ProductoDetalleView> createState() => _ProductoDetalleViewState();
}

class _ProductoDetalleViewState extends State<ProductoDetalleView> {
  final _service = ProductoService();
  late Future<Producto> _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = _service.obtener(widget.productoId);
  }

  void _recargar() {
    setState(() {
      _futuro = _service.obtener(widget.productoId);
    });
  }

  Future<void> _editar() async {
    final huboCambios =
        await context.push<bool>('/productos/${widget.productoId}/editar');
    if (huboCambios == true && mounted) _recargar();
  }

  Future<void> _eliminar(Producto producto) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text(
          '¿Seguro que deseas eliminar "${producto.nombre}"? '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmado != true) return;

    try {
      await _service.eliminar(widget.productoId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto eliminado correctamente')),
      );
      context.pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensajeDeError(e)),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del producto')),
      body: FutureBuilder<Producto>(
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

          final producto = snapshot.data!;
          final esquema = Theme.of(context).colorScheme;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: Colors.white,
                elevation: 2,
                surfaceTintColor: Colors.transparent,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        producto.nombre,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: esquema.onPrimaryContainer,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Chip(
                        avatar: Icon(Icons.sell_outlined, color: esquema.primary),
                        label: Text(producto.categoria),
                        backgroundColor: esquema.primaryContainer,
                        side: BorderSide.none,
                      ),
                      const Divider(height: 24),
                      _Dato(etiqueta: 'Código', valor: producto.codigo),
                      _Dato(etiqueta: 'Precio unitario', valor: formatoPesos(producto.precio)),
                      _Dato(etiqueta: 'Cantidad disponible', valor: formatoMiles(producto.cantidad)),
                      _Dato(etiqueta: 'Valor en inventario', valor: formatoPesos(producto.valorTotal)),
                      _Dato(
                        etiqueta: 'Descripción',
                        valor: producto.descripcion ?? 'Sin descripción',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _editar,
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Editar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _eliminar(producto),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Eliminar'),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato({required this.etiqueta, required this.valor});

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(etiqueta, style: textos.bodySmall?.copyWith(color: Colors.black54)),
          const SizedBox(height: 2),
          Text(valor, style: textos.bodyLarge),
        ],
      ),
    );
  }
}
