import 'package:flutter/material.dart';

enum AppThemeMode { edward, jacob }

class AppColors {
  static final ValueNotifier<AppThemeMode> currentTheme = ValueNotifier(
    AppThemeMode.edward,
  );

  static Color get background => currentTheme.value == AppThemeMode.edward
      ? const Color.fromARGB(
          255,
          18,
          29,
          37,
        ) // Noche en Forks (Azul verdoso muy oscuro)
      : const Color.fromARGB(
          255,
          39,
          32,
          27,
        ); // Deep pine black/earth (Bosque oscuro de La Push)

  static Color get primary => currentTheme.value == AppThemeMode.edward
      ? const Color.fromARGB(
          255,
          85,
          130,
          172,
        ) // Filtro azul de la película (Enfoque)
      : const Color(
          0xFFD95A2B,
        ); // Warm sun-and-fire orange (Calor de la manada / Enfoque)

  static Color get secondary => currentTheme.value == AppThemeMode.edward
      ? const Color(0xFF7CA1A6) // Filtro azul/gris de la película (Descanso)
      : const Color(0xFF768F7E); // Cool forest sage green (Descanso de bosque)

  static Color get textDark => currentTheme.value == AppThemeMode.edward
      ? const Color(0xFFE8F0F2) // Luz de luna (Texto principal claro)
      : const Color(0xFFF2EBE1); // Warm sandy cream (Tono tierra cálido)

  static const Color textLight = Color(0xFFFFFFFF);

  static Color get cardBg => currentTheme.value == AppThemeMode.edward
      ? const Color(0xAA131C24) // Fondo de tarjetas oscuro semitransparente
      : const Color(
          0xAA1D241D,
        ); // Fondo de tarjetas oscuro terroso semitransparente
}
