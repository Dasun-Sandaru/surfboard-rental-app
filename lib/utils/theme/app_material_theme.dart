import 'package:flutter/material.dart';

// =============================================================================
// 1. RAW COLORS (Your Custom Palette)
// =============================================================================
class AColors {
  AColors._();

  // -- Main Backgrounds --
  static const Color bgDark = Color(0xFF101f22);
  static const Color cardDark = Color(0xFF182c30);
  static const Color chipDark = Color(0xFF2a3b42);

  // -- Primary Brand Colors --
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color primaryTeal = Color(0xFF00A79D);

  // -- Text Colors --
  static const Color textWhite = Color(0xFFf0f4f4);
  static const Color textGrey = Color(0xFF94a3b8);

  // -- Borders & Dividers --
  static const Color borderDark = Color(0xFF334155);

  // -- Status Colors --
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFF59E0B);
  static const Color repair = Color(0xFFFFC107);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF4A90E2); // Same as Primary Blue for Info

  // -- Functional Specifics --
  static const Color paperWhite = Color(0xFFF5F5F5);
}

// =============================================================================
// 2. THEME EXTENSION (For Status Colors)
// =============================================================================
@immutable
class StatusColors extends ThemeExtension<StatusColors> {
  final Color? success;
  final Color? warning;
  final Color? repair;
  final Color? paperWhite;
  final Color? info;
  final Color? error;

  const StatusColors({
    required this.success,
    required this.warning,
    required this.repair,
    required this.paperWhite,
    required this.info,
    required this.error,
  });

  // Define the Dark Theme Extension values
  static const dark = StatusColors(
    success: AColors.success,
    warning: AColors.warning,
    repair: AColors.repair,
    paperWhite: AColors.paperWhite,
    info: AColors.info,
    error: AColors.error,
  );

  static const light = StatusColors(
    success: Color(0xFF2E7D32),
    warning: Color(0xFFEF6C00),
    repair: Color(0xFFF9A825),
    paperWhite: Colors.white,
    info: Color(0xFF1976D2),
    error: Color(0xFFC62828),
  );

  @override
  StatusColors copyWith({
    Color? success,
    Color? warning,
    Color? repair,
    Color? paperWhite,
    Color? info,
    Color? error,
  }) {
    return StatusColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      repair: repair ?? this.repair,
      paperWhite: paperWhite ?? this.paperWhite,
      info: info ?? this.info,
      error: error ?? this.error,
    );
  }

  @override
  StatusColors lerp(ThemeExtension<StatusColors>? other, double t) {
    if (other is! StatusColors) return this;
    return StatusColors(
      success: Color.lerp(success, other.success, t),
      warning: Color.lerp(warning, other.warning, t),
      repair: Color.lerp(repair, other.repair, t),
      paperWhite: Color.lerp(paperWhite, other.paperWhite, t),
      info: Color.lerp(info, other.info, t),
      error: Color.lerp(error, other.error, t),
    );
  }
}

// =============================================================================
// 3. TEXT THEME CONFIGURATION
// =============================================================================
TextTheme _appTextTheme = const TextTheme(
  // Headlines
  headlineLarge: TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w400,
    color: AColors.textWhite,
  ),
  headlineMedium: TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w400,
    color: AColors.textWhite,
  ),

  // Titles
  titleLarge: TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AColors.textWhite,
  ),
  titleMedium: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AColors.textWhite,
  ),

  // Body
  bodyLarge: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AColors.textWhite,
  ),
  bodyMedium: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AColors.textWhite,
  ),
  bodySmall: TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AColors.textGrey,
  ), // Mapped to Grey
  // Labels
  labelLarge: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AColors.textWhite,
  ),
);

// =============================================================================
// 4. MAIN THEME DATA
// =============================================================================
final ThemeData appDarkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,

  // -- Color Scheme Mapping --
  colorScheme:
      ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: AColors.primaryBlue,
      ).copyWith(
        primary: AColors.primaryBlue,
        onPrimary: Colors.white,
        secondary: AColors.primaryTeal,
        onSecondary: Colors.white,
        tertiary: AColors.repair, // Mapping Repair/Amber to Tertiary
        error: AColors.error,

        // Surfaces
        surface: AColors.bgDark,
        surfaceContainer: AColors.cardDark, // Cards use this
        secondaryContainer: AColors.chipDark, // Chips use this
        // Outlines
        outline: AColors.borderDark,
        onSurfaceVariant: AColors.textGrey,
      ),

  // -- Register Extensions --
  extensions: <ThemeExtension<dynamic>>[StatusColors.dark],

  // -- Typography --
  textTheme: _appTextTheme,
  scaffoldBackgroundColor: AColors.bgDark,

  // -- Component Themes --
  appBarTheme: const AppBarTheme(
    backgroundColor: AColors.bgDark,
    foregroundColor: AColors.textWhite,
    elevation: 0,
    scrolledUnderElevation: 0,
  ),

  cardTheme: const CardThemeData(color: AColors.cardDark, elevation: 0),

  chipTheme: const ChipThemeData(
    backgroundColor: AColors.chipDark,
    labelStyle: TextStyle(color: AColors.textWhite),
    side: BorderSide.none,
  ),

  // -- SnackBar Theme (for consistency across the app) --
  snackBarTheme: SnackBarThemeData(
    backgroundColor: AColors.cardDark,
    contentTextStyle: _appTextTheme.bodyMedium,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: AColors.borderDark),
    ),
    behavior: SnackBarBehavior.floating,
  ),

  // -- Button Styles --
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AColors.primaryBlue,
      foregroundColor: AColors.textWhite,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AColors.textWhite,
      side: const BorderSide(color: AColors.borderDark),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),

  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: AColors.cardDark,
    hintStyle: TextStyle(color: AColors.textGrey),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: AColors.borderDark),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: AColors.primaryBlue),
    ),
  ),
);

// =============================================================================
// 5. LIGHT THEME DATA
// =============================================================================
final ThemeData appLightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.light,
    seedColor: AColors.primaryBlue,
  ),
  extensions: <ThemeExtension<dynamic>>[StatusColors.light],
);
