import 'package:flutter/material.dart';

/// Tema de la app en tonos rojos.
class AppTheme {
  AppTheme._();

  static const Color rojoOscuro = Color(0xFFB71C1C);
  static const Color rojo = Color(0xFFD32F2F);
  static const Color rojoClaro = Color(0xFFFFEBEE);
  static const Color fondo = Color(0xFFFFF8F7);

  static ThemeData get light {
    final esquema = ColorScheme.fromSeed(
      seedColor: rojo,
      brightness: Brightness.light,
    ).copyWith(
      primary: rojo,
      onPrimary: Colors.white,
      primaryContainer: rojoClaro,
      onPrimaryContainer: rojoOscuro,
    );

    final bordeCampo = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      scaffoldBackgroundColor: fondo,
      appBarTheme: const AppBarTheme(
        backgroundColor: rojoOscuro,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: rojoClaro,
        iconTheme: WidgetStateProperty.resolveWith((estados) {
          final seleccionado = estados.contains(WidgetState.selected);
          return IconThemeData(color: seleccionado ? rojoOscuro : Colors.black54);
        }),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: rojo,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: bordeCampo,
        enabledBorder: bordeCampo,
        focusedBorder: bordeCampo.copyWith(
          borderSide: const BorderSide(color: rojo, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: rojo,
          foregroundColor: Colors.white,
          minimumSize: const Size(88, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: rojoOscuro,
          side: const BorderSide(color: rojo),
          minimumSize: const Size(88, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
