import 'package:flutter/material.dart';

import '../config/formato.dart';
import '../models/producto.dart';

/// Fila de la lista de productos: nombre, precio y cantidad disponible.
class ProductoTile extends StatelessWidget {
  const ProductoTile({super.key, required this.producto, required this.onTap});

  final Producto producto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;

    return Card(
      color: Colors.white,
      elevation: 1,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: esquema.primaryContainer,
          foregroundColor: esquema.primary,
          child: const Icon(Icons.inventory_2_outlined),
        ),
        title: Text(
          producto.nombre,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(formatoPesos(producto.precio)),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formatoMiles(producto.cantidad),
              style: textos.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: producto.cantidad == 0 ? esquema.error : esquema.onSurface,
              ),
            ),
            Text(
              producto.cantidad == 0
                  ? 'agotado'
                  : (producto.cantidad == 1 ? 'unidad' : 'unidades'),
              style: textos.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
