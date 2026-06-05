import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  const accent = Color(0xFF14B8A6);
  const background = Color(0xFF0C1013);
  const surface = Color(0xFF12181C);
  const elevatedSurface = Color(0xFF182126);
  const border = Color(0xFF243139);
  const primaryText = Color(0xFFF8FAFC);
  const secondaryText = Color(0xFFA9B4BE);

  final colorScheme = ColorScheme.fromSeed(
    seedColor: accent,
    brightness: Brightness.dark,
  ).copyWith(primary: accent, surface: surface, onSurface: primaryText);

  return ThemeData(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: background,
    useMaterial3: true,
    appBarTheme: AppBarTheme(
      centerTitle: false,
      backgroundColor: background,
      foregroundColor: primaryText,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: elevatedSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: border),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surface,
      indicatorColor: const Color(0xFF123B38),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final color = states.contains(WidgetState.selected)
            ? accent
            : secondaryText;
        return TextStyle(color: color, fontSize: 11);
      }),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      filled: true,
      fillColor: elevatedSurface,
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(color: primaryText, fontWeight: FontWeight.w700),
      headlineSmall: TextStyle(color: primaryText, fontWeight: FontWeight.w700),
      titleLarge: TextStyle(color: primaryText, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(color: primaryText, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: secondaryText),
      bodyMedium: TextStyle(color: secondaryText),
    ),
  );
}
