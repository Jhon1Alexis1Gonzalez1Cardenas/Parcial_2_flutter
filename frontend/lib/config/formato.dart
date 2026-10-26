/// Formatea un entero con puntos de miles: 1234567 -> 1.234.567
String formatoMiles(int valor) {
  final texto = valor.abs().toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => '.',
      );
  return valor < 0 ? '-$texto' : texto;
}

/// Formatea dinero estilo colombiano: 1234567.5 -> $ 1.234.567,50
String formatoPesos(double valor) {
  final centavosTotales = (valor.abs() * 100).round();
  final entero = centavosTotales ~/ 100;
  final centavos = centavosTotales % 100;
  final signo = valor < 0 ? '-' : '';
  final decimales = centavos == 0 ? '' : ',${centavos.toString().padLeft(2, '0')}';
  return '$signo\$ ${formatoMiles(entero)}$decimales';
}
