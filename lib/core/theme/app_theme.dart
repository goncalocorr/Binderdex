import 'package:flutter/material.dart';

/// Temas Material 3 (claro/escuro) gerados a partir de uma cor-semente
/// (vermelho Pokébola).
class AppTheme {
  static const _seed = Color(0xFFE3350D);

  static ThemeData light() => ThemeData(
        useMaterial3: true,
        colorSchemeSeed: _seed,
        brightness: Brightness.light,
      );

  static ThemeData dark() => ThemeData(
        useMaterial3: true,
        colorSchemeSeed: _seed,
        brightness: Brightness.dark,
      );
}
