// config/app_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Core Brand Colors
  static const Color primaryColor = Color(0xFF6366F1); // Indigo
  static const Color secondaryColor = Color(0xFF10B981); // Emerald
  static const Color accentColor = Color(0xFFF59E0B); // Amber

  // Semantic Colors
  static const Color errorColor = Color(0xFFEF4444); // Red
  static const Color warningColor = Color(0xFFF97316); // Orange
  static const Color successColor = Color(0xFF22C55E); // Green
  static const Color infoColor = Color(0xFF3B82F6); // Blue

  // Premium/Special Colors
  static const Color premiumGold = Color(0xFFD4AF37);
  static const Color premiumGradientStart = Color(0xFFFFD700);
  static const Color premiumGradientEnd = Color(0xFFB8860B);

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF5F5F5);
  static const Color lightOutline = Color(0xFFE5E5E5);
  static const Color lightOnSurface = Color(0xFF1A1A1A);
  static const Color lightOnSurfaceVariant = Color(0xFF6B7280);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF0F0F0F);
  static const Color darkSurface = Color(0xFF1A1A1A);
  static const Color darkSurfaceVariant = Color(0xFF2A2A2A);
  static const Color darkOutline = Color(0xFF404040);
  static const Color darkOnSurface = Color(0xFFFFFFFF);
  static const Color darkOnSurfaceVariant = Color(0xFFB3B3B3);

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.light,

    colorScheme: const ColorScheme.light(
      brightness: Brightness.light,
      primary: primaryColor,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFE0E7FF),
      onPrimaryContainer: Color(0xFF1E1B3A),
      secondary: secondaryColor,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFD1FAE5),
      onSecondaryContainer: Color(0xFF064E3B),
      tertiary: accentColor,
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFFEF3C7),
      onTertiaryContainer: Color(0xFF92400E),
      error: errorColor,
      onError: Colors.white,
      errorContainer: Color(0xFFFEE2E2),
      onErrorContainer: Color(0xFF991B1B),
      surface: lightSurface,
      onSurface: lightOnSurface,
      surfaceContainerHighest: lightSurfaceVariant,
      onSurfaceVariant: lightOnSurfaceVariant,
      outline: lightOutline,
      outlineVariant: Color(0xFFF3F4F6),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFF313131),
      onInverseSurface: Color(0xFFF5F5F5),
      inversePrimary: Color(0xFFBBC3FF),
    ),

    // App Bar Theme
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: true,
      backgroundColor: lightSurface,
      surfaceTintColor: Colors.transparent,
      foregroundColor: lightOnSurface,
      titleTextStyle: TextStyle(
        color: lightOnSurface,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontFamily: 'Poppins',
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      surfaceTintColor: Colors.transparent,
      color: lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.all(8),
    ),

    // Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.white,
        backgroundColor: primaryColor,
        disabledBackgroundColor: lightOnSurfaceVariant.withOpacity(0.12),
        disabledForegroundColor: lightOnSurfaceVariant.withOpacity(0.38),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
    ),

    // FAB Theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: 4,
      focusElevation: 6,
      hoverElevation: 6,
      highlightElevation: 8,
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      shape: CircleBorder(),
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: lightSurface,
      selectedItemColor: primaryColor,
      unselectedItemColor: lightOnSurfaceVariant,
      selectedLabelStyle: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        fontFamily: 'Poppins',
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        fontFamily: 'Poppins',
      ),
      elevation: 8,
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightSurfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: lightOutline, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(
        color: lightOnSurfaceVariant,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    ),

    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: lightOnSurface,
        fontFamily: 'Poppins',
        height: 1.2,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: lightOnSurface,
        fontFamily: 'Poppins',
        height: 1.2,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: lightOnSurface,
        fontFamily: 'Poppins',
        height: 1.2,
      ),
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: lightOnSurface,
        fontFamily: 'Poppins',
        height: 1.3,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: lightOnSurface,
        fontFamily: 'Poppins',
        height: 1.3,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: lightOnSurface,
        fontFamily: 'Poppins',
        height: 1.3,
      ),
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: lightOnSurface,
        fontFamily: 'Poppins',
        height: 1.4,
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: lightOnSurface,
        fontFamily: 'Poppins',
        height: 1.4,
      ),
      titleSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: lightOnSurface,
        fontFamily: 'Poppins',
        height: 1.4,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: lightOnSurface,
        fontFamily: 'Poppins',
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: lightOnSurface,
        fontFamily: 'Poppins',
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: lightOnSurfaceVariant,
        fontFamily: 'Poppins',
        height: 1.5,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: lightOnSurface,
        fontFamily: 'Poppins',
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: lightOnSurface,
        fontFamily: 'Poppins',
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: lightOnSurfaceVariant,
        fontFamily: 'Poppins',
      ),
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: lightOutline,
      thickness: 1,
      space: 1,
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: lightSurfaceVariant,
      selectedColor: primaryColor.withOpacity(0.12),
      disabledColor: lightOnSurfaceVariant.withOpacity(0.12),
      labelStyle: const TextStyle(
        color: lightOnSurface,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        fontFamily: 'Poppins',
      ),
      secondaryLabelStyle: const TextStyle(
        color: primaryColor,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        fontFamily: 'Poppins',
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.dark,

    colorScheme: const ColorScheme.dark(
      brightness: Brightness.dark,
      primary: primaryColor,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFF3730A3),
      onPrimaryContainer: Color(0xFFE0E7FF),
      secondary: secondaryColor,
      onSecondary: Colors.black,
      secondaryContainer: Color(0xFF047857),
      onSecondaryContainer: Color(0xFFD1FAE5),
      tertiary: accentColor,
      onTertiary: Colors.black,
      tertiaryContainer: Color(0xFFD97706),
      onTertiaryContainer: Color(0xFFFEF3C7),
      error: errorColor,
      onError: Colors.white,
      errorContainer: Color(0xFF7F1D1D),
      onErrorContainer: Color(0xFFFEE2E2),
      surface: darkSurface,
      onSurface: darkOnSurface,
      surfaceContainerHighest: darkSurfaceVariant,
      onSurfaceVariant: darkOnSurfaceVariant,
      outline: darkOutline,
      outlineVariant: Color(0xFF333333),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFFE5E5E5),
      onInverseSurface: Color(0xFF313131),
      inversePrimary: Color(0xFF4338CA),
    ),

    // App Bar Theme
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: true,
      backgroundColor: darkSurface,
      surfaceTintColor: Colors.transparent,
      foregroundColor: darkOnSurface,
      titleTextStyle: TextStyle(
        color: darkOnSurface,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontFamily: 'Poppins',
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.3),
      surfaceTintColor: Colors.transparent,
      color: darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.all(8),
    ),

    // Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.white,
        backgroundColor: primaryColor,
        disabledBackgroundColor: darkOnSurfaceVariant.withOpacity(0.12),
        disabledForegroundColor: darkOnSurfaceVariant.withOpacity(0.38),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
    ),

    // FAB Theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: 4,
      focusElevation: 6,
      hoverElevation: 6,
      highlightElevation: 8,
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      shape: CircleBorder(),
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: darkSurface,
      selectedItemColor: primaryColor,
      unselectedItemColor: darkOnSurfaceVariant,
      selectedLabelStyle: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        fontFamily: 'Poppins',
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        fontFamily: 'Poppins',
      ),
      elevation: 8,
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkOutline, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(
        color: darkOnSurfaceVariant,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    ),

    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: darkOnSurface,
        fontFamily: 'Poppins',
        height: 1.2,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: darkOnSurface,
        fontFamily: 'Poppins',
        height: 1.2,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: darkOnSurface,
        fontFamily: 'Poppins',
        height: 1.2,
      ),
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: darkOnSurface,
        fontFamily: 'Poppins',
        height: 1.3,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: darkOnSurface,
        fontFamily: 'Poppins',
        height: 1.3,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: darkOnSurface,
        fontFamily: 'Poppins',
        height: 1.3,
      ),
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: darkOnSurface,
        fontFamily: 'Poppins',
        height: 1.4,
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: darkOnSurface,
        fontFamily: 'Poppins',
        height: 1.4,
      ),
      titleSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: darkOnSurface,
        fontFamily: 'Poppins',
        height: 1.4,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: darkOnSurface,
        fontFamily: 'Poppins',
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: darkOnSurface,
        fontFamily: 'Poppins',
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: darkOnSurfaceVariant,
        fontFamily: 'Poppins',
        height: 1.5,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: darkOnSurface,
        fontFamily: 'Poppins',
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: darkOnSurface,
        fontFamily: 'Poppins',
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: darkOnSurfaceVariant,
        fontFamily: 'Poppins',
      ),
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: darkOutline,
      thickness: 1,
      space: 1,
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: darkSurfaceVariant,
      selectedColor: primaryColor.withOpacity(0.2),
      disabledColor: darkOnSurfaceVariant.withOpacity(0.12),
      labelStyle: const TextStyle(
        color: darkOnSurface,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        fontFamily: 'Poppins',
      ),
      secondaryLabelStyle: const TextStyle(
        color: primaryColor,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        fontFamily: 'Poppins',
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),

    // Switch Theme
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryColor;
        }
        return darkOnSurfaceVariant;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryColor.withOpacity(0.5);
        }
        return darkOutline;
      }),
    ),

    // Slider Theme
    sliderTheme: SliderThemeData(
      activeTrackColor: primaryColor,
      inactiveTrackColor: darkOutline,
      thumbColor: primaryColor,
      overlayColor: primaryColor.withOpacity(0.2),
      valueIndicatorColor: primaryColor,
      valueIndicatorTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        fontFamily: 'Poppins',
      ),
    ),

    // Progress Indicator Theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryColor,
      linearTrackColor: darkOutline,
      circularTrackColor: darkOutline,
    ),

    // Tab Bar Theme
    tabBarTheme: const TabBarThemeData(
      labelColor: primaryColor,
      unselectedLabelColor: darkOnSurfaceVariant,
      indicatorColor: primaryColor,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        fontFamily: 'Poppins',
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        fontFamily: 'Poppins',
      ),
      dividerColor: darkOutline,
    ),

    // Dialog Theme
    dialogTheme: DialogThemeData(
      backgroundColor: darkSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      titleTextStyle: const TextStyle(
        color: darkOnSurface,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontFamily: 'Poppins',
      ),
      contentTextStyle: const TextStyle(
        color: darkOnSurface,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        fontFamily: 'Poppins',
      ),
    ),

    // Snack Bar Theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: darkSurfaceVariant,
      contentTextStyle: const TextStyle(
        color: darkOnSurface,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        fontFamily: 'Poppins',
      ),
      actionTextColor: primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 4,
    ),
  );

  // Utility Methods for Theme-aware Colors
  static Color getAdaptiveColor(
    BuildContext context, {
    required Color lightColor,
    required Color darkColor,
  }) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkColor
        : lightColor;
  }

  static Color getPrimaryVariant(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF5B21B6)
        : const Color(0xFF4F46E5);
  }

  static Color getSuccessColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF10B981)
        : const Color(0xFF059669);
  }

  static Color getWarningColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFF59E0B)
        : const Color(0xFFD97706);
  }

  static Color getErrorVariant(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFDC2626)
        : const Color(0xFFB91C1C);
  }

  // Premium Gradient
  static LinearGradient get premiumGradient => const LinearGradient(
        colors: [premiumGradientStart, premiumGradientEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // Surface Elevation Colors (Material 3 style)
  static Color getSurfaceElevation(BuildContext context, int elevation) {
    final baseColor = Theme.of(context).colorScheme.surface;
    final overlayColor = Theme.of(context).colorScheme.primary;

    // Material 3 elevation opacity values
    final elevationOpacities = {
      0: 0.0,
      1: 0.05,
      2: 0.08,
      3: 0.11,
      4: 0.12,
      5: 0.14,
    };

    final opacity = elevationOpacities[elevation] ?? 0.14;
    return Color.alphaBlend(
      overlayColor.withOpacity(opacity),
      baseColor,
    );
  }

  // Text Colors
  static Color getTextColor(BuildContext context, {bool isSecondary = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    return isSecondary ? colorScheme.onSurfaceVariant : colorScheme.onSurface;
  }

  // Border Colors
  static Color getBorderColor(BuildContext context, {bool isActive = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    return isActive ? colorScheme.primary : colorScheme.outline;
  }

  // Shadow Colors
  static List<BoxShadow> getElevationShadow(
      BuildContext context, int elevation) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: elevation * 2.0,
          spreadRadius: 0,
          offset: Offset(0, elevation.toDouble()),
        ),
      ];
    } else {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: elevation * 1.5,
          spreadRadius: 0,
          offset: Offset(0, elevation * 0.5),
        ),
      ];
    }
  }
}
