import 'producto.dart';

/// Indicadores del Dashboard, calculados con los datos reales de la API.
class ResumenInventario {
  const ResumenInventario({
    required this.totalProductos,
    required this.totalUnidades,
    required this.valorTotal,
  });

  final int totalProductos;
  final int totalUnidades;
  final double valorTotal;

  factory ResumenInventario.desde(List<Producto> productos) {
    var unidades = 0;
    var valor = 0.0;
    for (final producto in productos) {
      unidades += producto.cantidad;
      valor += producto.valorTotal; // precio x cantidad
    }
    return ResumenInventario(
      totalProductos: productos.length,
      totalUnidades: unidades,
      valorTotal: valor,
    );
  }
}
