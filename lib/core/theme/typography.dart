import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App typography using Plus Jakarta Sans for headings and Inter for body text
/// With Gujarati and Hindi fallbacks
class AppTypography {
  static TextTheme get _baseTextTheme => TextTheme(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 57,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.25,
          height: 1.12,
        ),
        displayMedium: GoogleFonts.plusJakartaSans(
          fontSize: 45,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
          height: 1.16,
        ),
        displaySmall: GoogleFonts.plusJakartaSans(
          fontSize: 36,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.22,
        ),
        headlineLarge: GoogleFonts.plusJakartaSans(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.25,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.29,
        ),
        headlineSmall: GoogleFonts.plusJakartaSans(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.33,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.27,
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
          height: 1.5,
        ),
        titleSmall: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 1.43,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          height: 1.43,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
          height: 1.33,
        ),
        labelLarge: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 1.43,
        ),
        labelMedium: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          height: 1.33,
        ),
        labelSmall: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          height: 1.45,
        ),
      );

  /// Dark mode text theme
  static TextTheme dark = _baseTextTheme.apply(
    bodyColor: const Color(0xFFF4F6FF),
    displayColor: const Color(0xFFF4F6FF),
  );

  /// Light mode text theme
  static TextTheme light = _baseTextTheme.apply(
    bodyColor: const Color(0xFF14172B),
    displayColor: const Color(0xFF14172B),
  );

  /// Gujarati text style fallback
  static TextStyle gujarati({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
  }) =>
      GoogleFonts.notoSansGujarati(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );

  /// Hindi text style fallback
  static TextStyle hindi({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
  }) =>
      GoogleFonts.notoSansDevanagari(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );
}
