import 'package:flutter/material.dart';

import 'tokens.dart';

abstract final class NexusTheme {
  static ThemeData get oled {
    const scheme = ColorScheme.dark(
      primary: NexusColors.white,
      onPrimary: NexusColors.oled,
      surface: NexusColors.oled,
      onSurface: NexusColors.white,
      outline: NexusColors.border,
      outlineVariant: NexusColors.border,
    );
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: NexusColors.oled,
      canvasColor: NexusColors.oled,
      dividerColor: NexusColors.border,
      focusColor: NexusColors.focus,
      splashFactory: NoSplash.splashFactory,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: NexusColors.white,
          fontSize: 32,
          height: 1.1,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          color: NexusColors.white,
          fontSize: 24,
          height: 1.2,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(
          color: NexusColors.muted,
          fontSize: 16,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: NexusColors.muted,
          fontSize: 14,
          height: 1.4,
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        height: 72,
        backgroundColor: NexusColors.raised,
        indicatorColor: NexusColors.white,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: NexusColors.raised,
        indicatorColor: NexusColors.white,
        minWidth: 88,
        minExtendedWidth: 176,
        selectedIconTheme: IconThemeData(color: NexusColors.oled),
        unselectedIconTheme: IconThemeData(color: NexusColors.muted),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          backgroundColor: NexusColors.white,
          foregroundColor: NexusColors.oled,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: NexusColors.white,
          side: const BorderSide(color: NexusColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      cardTheme: const CardThemeData(
        color: NexusColors.raised,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: NexusColors.border),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }
}
