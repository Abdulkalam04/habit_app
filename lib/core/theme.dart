import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Colors: near-black canvas, warm off-white text, ONE sharp accent.
class AppColors {
  static const bg = Color(0xFF0B0B0C);
  static const surface = Color(0xFF141416);
  static const surfaceHigh = Color(0xFF1C1C1F);
  static const line = Color(0xFF2A2A2E);
  static const text = Color(0xFFF2F0EA);
  static const muted = Color(0xFF8A8A90);
  static const accent = Color(0xFFC6F432); // acid lime
  static const onAccent = Color(0xFF0B0B0C);
  static const danger = Color(0xFFFF5A47);
}

/// Spacing scale. Use these instead of random numbers.
class AppSpace {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 40.0;
  static const xxl = 64.0;
}

/// Radii. Mixing sharp and round corners avoids the "template" look.
class AppRadius {
  static const sm = 6.0;
  static const md = 14.0;
  static const lg = 28.0;
  static const pill = 999.0;
}

/// Animation timings and curves used across the app.
class AppMotion {
  static const fast = Duration(milliseconds: 180);
  static const medium = Duration(milliseconds: 380);
  static const slow = Duration(milliseconds: 700);
  static const curve = Curves.easeOutCubic;
  static const bounce = Curves.easeOutBack;
}

class AppTheme {
  static ThemeData get dark {
    final display = GoogleFonts.fraunces; // serif headlines
    final body = GoogleFonts.dmSans; // clean body text

    final textTheme = TextTheme(
      displayLarge: display(
        fontSize: 64,
        height: 1.0,
        fontWeight: FontWeight.w600,
        letterSpacing: -2,
        color: AppColors.text,
      ),
      displayMedium: display(
        fontSize: 44,
        height: 1.05,
        fontWeight: FontWeight.w600,
        letterSpacing: -1.5,
        color: AppColors.text,
      ),
      headlineMedium: display(
        fontSize: 28,
        height: 1.15,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.5,
        color: AppColors.text,
      ),
      titleLarge: body(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
      titleMedium: body(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.text,
      ),
      bodyLarge: body(
        fontSize: 16,
        height: 1.5,
        color: AppColors.text,
      ),
      bodyMedium: body(
        fontSize: 14,
        height: 1.5,
        color: AppColors.muted,
      ),
      labelLarge: body(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: AppColors.text,
      ),
      labelSmall: body(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.6, // small caps-style labels
        color: AppColors.muted,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bg,
      canvasColor: AppColors.bg,
      textTheme: textTheme,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.bg,
        primary: AppColors.accent,
        onPrimary: AppColors.onAccent,
        secondary: AppColors.accent,
        error: AppColors.danger,
        onSurface: AppColors.text,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.line,
        thickness: 1,
        space: 1,
      ),
      // Removes the default Material ripple/splash look.
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.onAccent,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.all(AppSpace.md),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        hintStyle: textTheme.bodyMedium,
      ),
    );
  } 
}