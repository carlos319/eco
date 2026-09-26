import 'package:flutter/material.dart';

/// Paleta de colores de la app EC0 (estilo infantil colorido).
///
/// Los datos pedagógicos guardan los colores como cadenas (`'sky'`, `'orange'`...)
/// para no depender de Material en los modelos.
class AppPalette {
  const AppPalette._();

  static const sky = Color(0xFF38BDF8);
  static const skyDark = Color(0xFF0284C7);
  static const orange = Color(0xFFFB923C);
  static const orangeDark = Color(0xFFC2410C);
  static const green = Color(0xFF34D399);
  static const greenDark = Color(0xFF047857);
  static const pink = Color(0xFFF472B6);
  static const pinkDark = Color(0xFFBE185D);
  static const yellow = Color(0xFFFBBF24);
  static const yellowDark = Color(0xFFB45309);
  static const purple = Color(0xFFA78BFA);
  static const purpleDark = Color(0xFF6D28D9);
  static const red = Color(0xFFF87171);
  static const redDark = Color(0xFFB91C1C);
  static const teal = Color(0xFF2DD4BF);
  static const tealDark = Color(0xFF0F766E);
  static const indigo = Color(0xFF818CF8);
  static const indigoDark = Color(0xFF4338CA);
  static const ink = Color(0xFF312E5A);
  static const cream = Color(0xFFFFF8EC);

  /// Devuelve el color base a partir de su nombre.
  static Color of(String name) => switch (name) {
        'sky' => sky,
        'orange' => orange,
        'green' => green,
        'pink' => pink,
        'yellow' => yellow,
        'purple' => purple,
        'red' => red,
        'teal' => teal,
        'indigo' => indigo,
        _ => sky,
      };

  /// Versión oscura del color (para sombras 3D de botones).
  static Color darkOf(String name) => switch (name) {
        'sky' => skyDark,
        'orange' => orangeDark,
        'green' => greenDark,
        'pink' => pinkDark,
        'yellow' => yellowDark,
        'purple' => purpleDark,
        'red' => redDark,
        'teal' => tealDark,
        'indigo' => indigoDark,
        _ => skyDark,
      };

  /// Color de texto legible sobre el color base.
  static Color textOn(String name) => switch (name) {
        'yellow' => ink,
        _ => Colors.white,
      };
}

/// Tema global de la app.
class AppTheme {
  const AppTheme._();

  static const fontFamily = 'Baloo2';

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppPalette.sky,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppPalette.cream,
    );
    return base.copyWith(
      textTheme: base.textTheme.apply(
        fontFamily: fontFamily,
        bodyColor: AppPalette.ink,
        displayColor: AppPalette.ink,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppPalette.ink,
        elevation: 0,
        centerTitle: true,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppPalette.ink,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 17,
          color: AppPalette.ink,
        ),
      ),
    );
  }
}
