/// Modelo de un producto del inventario (refleja la tabla `productos` de la API).
class Producto {
  const Producto({
    this.id,
    required this.nombre,
    required this.codigo,
    this.descripcion,
    required this.precio,
    required this.cantidad,
    required this.categoria,
  });

  final int? id;
  final String nombre;
  final String codigo;
  final String? descripcion;
  final double precio;
  final int cantidad;
  final String categoria;

  /// Valor económico de este producto en inventario (precio x cantidad).
  double get valorTotal => precio * cantidad;

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'] as int?,
      nombre: json['nombre'] as String,
      codigo: json['codigo'] as String,
      descripcion: json['descripcion'] as String?,
      precio: (json['precio'] as num).toDouble(),
      cantidad: (json['cantidad'] as num).toInt(),
      categoria: json['categoria'] as String,
    );
  }

  /// Cuerpo JSON para POST y PUT (el id lo maneja la API).
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'codigo': codigo,
      'descripcion': descripcion,
      'precio': precio,
      'cantidad': cantidad,
      'categoria': categoria,
    };
  }
}
