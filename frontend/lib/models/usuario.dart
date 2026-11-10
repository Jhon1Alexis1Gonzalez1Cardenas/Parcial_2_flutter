/// Usuario autenticado (datos no sensibles).
class Usuario {
  const Usuario({required this.id, required this.nombre, required this.email});

  final int id;
  final String nombre;
  final String email;

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
        id: (json['id'] as num).toInt(),
        nombre: json['nombre'] as String,
        email: json['email'] as String,
      );
}
