import 'package:flutter/material.dart';

/// Tarjeta de indicador del Dashboard.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icono,
    required this.titulo,
    required this.valor,
  });

  final IconData icono;
  final String titulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final textos = Theme.of(context).textTheme;

    return Card(
      color: Colors.white,
      elevation: 2,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: esquema.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icono, color: esquema.primary),
            ),
            const SizedBox(height: 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                valor,
                style: textos.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: esquema.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(titulo, style: textos.bodyMedium),
          ],
        ),
      ),
    );
  }
}
