import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ZenTouchColors {
  static const primary = Color(0xFF80618F);
  static const primaryDark = Color(0xFF493457);
  static const primaryLight = Color(0xFFB69BBF);
  static const secondary = Color(0xFFD8B9C5);
  static const accent = Color(0xFFC99EAC);
  static const background = Color(0xFFF8F1F3);
  static const surface = Color(0xFFFFF9F7);
  static const surfaceSecondary = Color(0xFFF0E5EB);
  static const warningContainer = Color(0xFFF7EFE5);
  static const blushContainer = Color(0xFFF3E4E9);
  static const lavenderContainer = Color(0xFFECE5F0);
  static const textPrimary = Color(0xFF493457);
  static const textSecondary = Color(0xFF806C88);
  static const border = Color(0xFFE8D9E2);
  static const success = Color(0xFF789B83);
  static const warning = Color(0xFFD4AC76);
  static const error = Color(0xFFC87985);
  static const errorContainer = Color(0xFFF8E9ED);
}

class ZenTouchTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: ZenTouchColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: ZenTouchColors.primary,
      onPrimary: Colors.white,
      primaryContainer: ZenTouchColors.surfaceSecondary,
      onPrimaryContainer: ZenTouchColors.primaryDark,
      secondary: ZenTouchColors.secondary,
      onSecondary: ZenTouchColors.primaryDark,
      tertiary: ZenTouchColors.accent,
      onTertiary: ZenTouchColors.primaryDark,
      secondaryContainer: ZenTouchColors.surfaceSecondary,
      onSecondaryContainer: ZenTouchColors.primaryDark,
      tertiaryContainer: ZenTouchColors.surfaceSecondary,
      onTertiaryContainer: ZenTouchColors.primaryDark,
      surface: ZenTouchColors.surface,
      surfaceTint: ZenTouchColors.primary,
      onSurface: ZenTouchColors.textPrimary,
      error: ZenTouchColors.error,
      onError: Colors.white,
      errorContainer: ZenTouchColors.errorContainer,
      onErrorContainer: ZenTouchColors.primaryDark,
      outline: ZenTouchColors.border,
      outlineVariant: ZenTouchColors.border,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: ZenTouchColors.background,
      textTheme: GoogleFonts.promptTextTheme().apply(
        bodyColor: ZenTouchColors.textPrimary,
        displayColor: ZenTouchColors.primaryDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: ZenTouchColors.background,
        foregroundColor: ZenTouchColors.primaryDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ZenTouchColors.surface,
        hintStyle: const TextStyle(color: ZenTouchColors.textSecondary),
        labelStyle: const TextStyle(color: ZenTouchColors.textSecondary),
        floatingLabelStyle: const TextStyle(color: ZenTouchColors.primary),
        prefixIconColor: ZenTouchColors.primary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: ZenTouchColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: ZenTouchColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: ZenTouchColors.primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: ZenTouchColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: ZenTouchColors.error, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: ZenTouchColors.primary,
          disabledBackgroundColor: ZenTouchColors.primaryLight,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: ZenTouchColors.primary,
          disabledBackgroundColor: ZenTouchColors.primaryLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ZenTouchColors.primary,
          side: const BorderSide(color: ZenTouchColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: ZenTouchColors.primary),
      ),
      cardTheme: CardThemeData(
        color: ZenTouchColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: ZenTouchColors.border),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: ZenTouchColors.surface,
        selectedItemColor: ZenTouchColors.primary,
        unselectedItemColor: ZenTouchColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 4,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: ZenTouchColors.surface,
        indicatorColor: ZenTouchColors.surfaceSecondary,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color:
                states.contains(WidgetState.selected)
                    ? ZenTouchColors.primaryDark
                    : ZenTouchColors.textSecondary,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            color:
                states.contains(WidgetState.selected)
                    ? ZenTouchColors.primaryDark
                    : ZenTouchColors.textSecondary,
          );
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: ZenTouchColors.surfaceSecondary,
        selectedColor: ZenTouchColors.primary,
        secondarySelectedColor: ZenTouchColors.primary,
        disabledColor: ZenTouchColors.surfaceSecondary.withValues(alpha: 0.6),
        side: const BorderSide(color: ZenTouchColors.border),
        labelStyle: const TextStyle(color: ZenTouchColors.textPrimary),
        secondaryLabelStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: ZenTouchColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: const TextStyle(
          color: ZenTouchColors.primaryDark,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: const TextStyle(color: ZenTouchColors.textSecondary),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ZenTouchColors.primaryDark,
        contentTextStyle: GoogleFonts.prompt(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dividerTheme: const DividerThemeData(color: ZenTouchColors.border),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: ZenTouchColors.primary,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? ZenTouchColors.surface
              : ZenTouchColors.surface;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? ZenTouchColors.primary
              : ZenTouchColors.border;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? ZenTouchColors.primary
              : Colors.transparent;
        }),
        side: const BorderSide(color: ZenTouchColors.textSecondary),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? ZenTouchColors.primary
              : ZenTouchColors.textSecondary;
        }),
      ),
    );
  }
}
