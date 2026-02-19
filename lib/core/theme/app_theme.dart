import 'package:flutter/material.dart';
import 'app_colors.dart';

class CyberColors {
  CyberColors._();

  static const background = Color(0xFF0A1929);
  static const surface = Color(0xFF0D2137);
  static const surfaceLight = Color(0xFF133052);
  static const cyan = Color(0xFF00E5FF);
  static const textPrimary = Color(0xFFE0F7FA);
  static const textSecondary = Color(0xFF80DEEA);
  static const textDim = Color(0xFF4DD0E1);
}

class TerminalColors {
  TerminalColors._();

  static const background = Color(0xFF0B1215);
  static const surface = Color(0xFF111D22);
  static const surfaceLight = Color(0xFF1A2C33);
  static const green = Color(0xFF00E676);
  static const textPrimary = Color(0xFFB9F6CA);
  static const textSecondary = Color(0xFF69F0AE);
  static const textDim = Color(0xFF2E7D52);
}

class AppTheme {
  AppTheme._();

  // Base dark theme used by MaterialApp (never changes).
  static final ThemeData dark = _buildDark();

  // Skin themes derived from the same base so they share
  // identical inherit/structure and can be swapped via Theme widget
  // without interpolation errors.
  static final ThemeData cyber = _buildCyber();
  static final ThemeData terminal = _buildTerminal();

  static ThemeData _buildDark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.surface,
        primary: AppColors.accent,
        secondary: AppColors.accent,
        onPrimary: Colors.black,
        onSurface: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.surfaceBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.surfaceBorder),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.surfaceBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.surfaceBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.accent),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.surfaceBorder),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          side: BorderSide(color: AppColors.surfaceBorder),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        textColor: AppColors.textPrimary,
        iconColor: AppColors.textSecondary,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceLight,
        contentTextStyle: const TextStyle(color: AppColors.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      textTheme: base.textTheme.copyWith(
        headlineLarge: base.textTheme.headlineLarge?.copyWith(
          color: AppColors.textPrimary,
          fontSize: 48,
          fontWeight: FontWeight.w300,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
        headlineMedium: base.textTheme.headlineMedium?.copyWith(
          color: AppColors.textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w700,
        ),
        headlineSmall: base.textTheme.headlineSmall?.copyWith(
          color: AppColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          color: AppColors.textSecondary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: base.textTheme.bodyLarge?.copyWith(
          color: AppColors.textPrimary,
          fontSize: 16,
        ),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
        bodySmall: base.textTheme.bodySmall?.copyWith(
          color: AppColors.textDim,
          fontSize: 12,
        ),
      ),
    );
  }

  static ThemeData _buildCyber() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: const ColorScheme.dark(
        surface: CyberColors.surface,
        primary: CyberColors.cyan,
        secondary: CyberColors.cyan,
        onPrimary: Colors.black,
        onSurface: CyberColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: CyberColors.cyan,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: CyberColors.cyan),
      ),
      cardTheme: CardThemeData(
        color: CyberColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: CyberColors.cyan.withValues(alpha: 0.3),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CyberColors.cyan,
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: CyberColors.cyan,
          side: BorderSide(
            color: CyberColors.cyan.withValues(alpha: 0.4),
          ),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: CyberColors.cyan,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CyberColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: CyberColors.cyan.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: CyberColors.cyan.withValues(alpha: 0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: CyberColors.cyan),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        labelStyle: const TextStyle(color: CyberColors.textSecondary),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: CyberColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: CyberColors.cyan.withValues(alpha: 0.3),
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: CyberColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          side: BorderSide(
            color: CyberColors.cyan.withValues(alpha: 0.3),
          ),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        textColor: CyberColors.textPrimary,
        iconColor: CyberColors.textSecondary,
      ),
      textTheme: base.textTheme.copyWith(
        headlineLarge: base.textTheme.headlineLarge?.copyWith(
          color: CyberColors.cyan,
          fontSize: 48,
          fontWeight: FontWeight.w300,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
        headlineMedium: base.textTheme.headlineMedium?.copyWith(
          color: CyberColors.cyan,
          fontSize: 32,
          fontWeight: FontWeight.w400,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          color: CyberColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          color: CyberColors.textSecondary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: base.textTheme.bodyLarge?.copyWith(
          color: CyberColors.textPrimary,
          fontSize: 16,
        ),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(
          color: CyberColors.textSecondary,
          fontSize: 14,
        ),
      ),
    );
  }

  static ThemeData _buildTerminal() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: const ColorScheme.dark(
        surface: TerminalColors.surface,
        primary: TerminalColors.green,
        secondary: TerminalColors.green,
        onPrimary: Colors.black,
        onSurface: TerminalColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: TerminalColors.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: TerminalColors.green,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'monospace',
        ),
        iconTheme: IconThemeData(color: TerminalColors.green),
      ),
      cardTheme: CardThemeData(
        color: TerminalColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(
            color: TerminalColors.green.withValues(alpha: 0.4),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: TerminalColors.green.withValues(alpha: 0.15),
          foregroundColor: TerminalColors.green,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: const BorderSide(color: TerminalColors.green),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'monospace',
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: TerminalColors.green,
          side: BorderSide(
            color: TerminalColors.green.withValues(alpha: 0.5),
          ),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          textStyle: const TextStyle(
            fontFamily: 'monospace',
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: TerminalColors.green,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: TerminalColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(
            color: TerminalColors.green.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(
            color: TerminalColors.green.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: TerminalColors.green),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        labelStyle: const TextStyle(
          color: TerminalColors.textSecondary,
          fontFamily: 'monospace',
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: TerminalColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(
            color: TerminalColors.green.withValues(alpha: 0.4),
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: TerminalColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          side: BorderSide(
            color: TerminalColors.green.withValues(alpha: 0.4),
          ),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        textColor: TerminalColors.textPrimary,
        iconColor: TerminalColors.textSecondary,
      ),
      textTheme: base.textTheme.copyWith(
        headlineLarge: base.textTheme.headlineLarge?.copyWith(
          color: TerminalColors.green,
          fontSize: 48,
          fontWeight: FontWeight.w400,
          fontFamily: 'monospace',
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
        headlineMedium: base.textTheme.headlineMedium?.copyWith(
          color: TerminalColors.green,
          fontSize: 32,
          fontWeight: FontWeight.w400,
          fontFamily: 'monospace',
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          color: TerminalColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'monospace',
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          color: TerminalColors.textSecondary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          fontFamily: 'monospace',
        ),
        bodyLarge: base.textTheme.bodyLarge?.copyWith(
          color: TerminalColors.textPrimary,
          fontSize: 16,
          fontFamily: 'monospace',
        ),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(
          color: TerminalColors.textSecondary,
          fontSize: 14,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}
