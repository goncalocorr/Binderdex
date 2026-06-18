import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dex_tokens.dart';

/// Tema Material 3 que aplica o **Dex Design System**:
/// - Tipografia: Fredoka (títulos/números), Nunito (corpo/UI), Space Mono (códigos).
/// - Cor: Flare Red (primária) + Energy Gold (acento), superfícies near-white/ink.
/// - Forma: controlos em pílula, cards com raio "lg" e sombra suave.
class AppTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  /// Família de números/títulos (Fredoka) — útil para texto "hero" inline.
  static String? get displayFont => GoogleFonts.fredoka().fontFamily;

  /// Estilo monoespaçado para números de carta, códigos e contagens.
  static TextStyle mono({
    double? fontSize,
    FontWeight fontWeight = FontWeight.w700,
    Color? color,
  }) =>
      GoogleFonts.spaceMono(
          fontSize: fontSize, fontWeight: fontWeight, color: color);

  static ThemeData _build(Brightness b) {
    final isDark = b == Brightness.dark;
    final scheme = isDark ? _darkScheme : _lightScheme;
    final scaffold = isDark ? DexColors.n950 : DexColors.n50;

    final base = ThemeData(brightness: b, useMaterial3: true);
    final nunito = GoogleFonts.nunitoTextTheme(base.textTheme);

    TextStyle fredoka(TextStyle? s, FontWeight w) =>
        GoogleFonts.fredoka(textStyle: s, fontWeight: w);

    final textTheme = nunito.copyWith(
      displayLarge: fredoka(nunito.displayLarge, FontWeight.w700),
      displayMedium: fredoka(nunito.displayMedium, FontWeight.w700),
      displaySmall: fredoka(nunito.displaySmall, FontWeight.w700),
      headlineMedium: fredoka(nunito.headlineMedium, FontWeight.w700),
      headlineSmall: fredoka(nunito.headlineSmall, FontWeight.w600),
      titleLarge: fredoka(nunito.titleLarge, FontWeight.w600),
      titleMedium: fredoka(nunito.titleMedium, FontWeight.w600),
    ).apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );

    final pill = RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DexRadii.pill));

    return ThemeData(
      brightness: b,
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffold,
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,

      appBarTheme: AppBarTheme(
        backgroundColor: scaffold,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.fredoka(
          fontWeight: FontWeight.w700,
          fontSize: 22,
          color: scheme.onSurface,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: isDark ? 0.45 : 0.10),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DexRadii.lg)),
        margin: EdgeInsets.zero,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor:
            isDark ? DexColors.red500.withValues(alpha: 0.16) : DexColors.red50,
        indicatorShape: pill,
        elevation: 3,
        height: 66,
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 11),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            color: s.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.onSurfaceVariant,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: pill,
          minimumSize: const Size(0, 52),
          textStyle:
              GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 15),
          padding: const EdgeInsets.symmetric(horizontal: 22),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: pill,
          minimumSize: const Size(0, 48),
          side: BorderSide(color: scheme.outline),
          textStyle:
              GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: pill,
          textStyle:
              GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),

      chipTheme: ChipThemeData(
        shape: pill,
        side: BorderSide(color: scheme.outline),
        backgroundColor: scheme.surface,
        selectedColor: isDark
            ? DexColors.red500.withValues(alpha: 0.18)
            : DexColors.red50,
        labelStyle:
            GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 13),
        secondaryLabelStyle: GoogleFonts.nunito(fontWeight: FontWeight.w700),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? DexColors.n800 : DexColors.n100,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DexRadii.pill),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DexRadii.pill),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DexRadii.pill),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),

      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(pill),
          textStyle: WidgetStatePropertyAll(
              GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 13)),
          backgroundColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected)
                  ? scheme.primary
                  : Colors.transparent),
          foregroundColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected)
                  ? scheme.onPrimary
                  : scheme.onSurfaceVariant),
        ),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: isDark ? DexColors.n800 : DexColors.n100,
        linearMinHeight: 8,
        circularTrackColor: isDark ? DexColors.n800 : DexColors.n100,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? Colors.white : null),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? DexColors.green500 : null),
      ),

      dividerTheme: DividerThemeData(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : DexColors.n100,
        thickness: 1,
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(DexRadii.xl)),
        ),
      ),

      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  static const ColorScheme _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: DexColors.red500,
    onPrimary: Colors.white,
    primaryContainer: DexColors.red50,
    onPrimaryContainer: DexColors.red700,
    secondary: DexColors.gold500,
    onSecondary: DexColors.n900,
    secondaryContainer: DexColors.gold300,
    onSecondaryContainer: DexColors.n900,
    tertiary: DexColors.green500,
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFD9F2DF),
    onTertiaryContainer: Color(0xFF124A1E),
    error: DexColors.danger,
    onError: Colors.white,
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    surface: DexColors.n0,
    onSurface: DexColors.n900,
    onSurfaceVariant: DexColors.n500,
    surfaceContainerLowest: DexColors.n0,
    surfaceContainerLow: DexColors.n50,
    surfaceContainer: DexColors.n50,
    surfaceContainerHigh: DexColors.n100,
    surfaceContainerHighest: DexColors.n100,
    outline: DexColors.n200,
    outlineVariant: DexColors.n100,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: DexColors.n900,
    onInverseSurface: DexColors.n50,
    inversePrimary: DexColors.red400,
  );

  static const ColorScheme _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: DexColors.red400,
    onPrimary: Color(0xFF1A0606),
    primaryContainer: Color(0x29F03B36),
    onPrimaryContainer: DexColors.red100,
    secondary: DexColors.gold400,
    onSecondary: DexColors.n900,
    secondaryContainer: Color(0x2EFCC419),
    onSecondaryContainer: DexColors.gold300,
    tertiary: DexColors.green400,
    onTertiary: DexColors.n900,
    tertiaryContainer: Color(0x2E2FB344),
    onTertiaryContainer: Color(0xFFB6F0C2),
    error: DexColors.dangerDark,
    onError: DexColors.n900,
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: DexColors.n900,
    onSurface: DexColors.n0,
    onSurfaceVariant: DexColors.n400,
    surfaceContainerLowest: DexColors.n950,
    surfaceContainerLow: DexColors.n900,
    surfaceContainer: DexColors.n800,
    surfaceContainerHigh: DexColors.n800,
    surfaceContainerHighest: DexColors.n700,
    outline: DexColors.n800,
    outlineVariant: DexColors.n700,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: DexColors.n50,
    onInverseSurface: DexColors.n900,
    inversePrimary: DexColors.red500,
  );
}