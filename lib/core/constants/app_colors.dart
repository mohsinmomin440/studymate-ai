import 'package:flutter/material.dart';

/// Centralized color palette for StudyMate AI.
/// Strictly follows the Light Mode and Dark Mode reference designs:
/// - Light: White and Royal Purple (#6750A4 / #6C5CE7)
/// - Dark: Deep Navy (#0B0F19) and Neon Purple (#8B5CF6 / #7C3AED)
class AppColors {
  AppColors._();

  // Primary Palette
  static const Color primaryPurple = Color(0xFF6750A4);
  static const Color primaryPurpleLight = Color(0xFF7C64C4);
  static const Color primaryPurpleDark = Color(0xFF4F378B);
  static const Color primaryGradientStart = Color(0xFF6366F1);
  static const Color primaryGradientEnd = Color(0xFF8B5CF6);

  // Neon Purple for Dark Mode
  static const Color neonPurple = Color(0xFF8B5CF6);
  static const Color neonPurpleGlow = Color(0xFF9333EA);
  static const Color neonPurpleHover = Color(0xFFA855F7);

  // Accent Colors (Subject & Priority tags)
  static const Color blue = Color(0xFF3882F6);
  static const Color emeraldGreen = Color(0xFF10B981);
  static const Color amberOrange = Color(0xFFF59E0B);
  static const Color pink = Color(0xFFEC4899);
  static const Color slateGrey = Color(0xFF6B7280);
  static const Color crimsonRed = Color(0xFFEF4444);

  // Light Mode Surfaces & Text
  static const Color lightScaffoldBackground = Color(0xFFF8F9FE);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF1E1B4B);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightTextDisabled = Color(0xFF94A3B8);

  // Dark Mode Surfaces & Text (Navy and Neon Purple Showcase)
  static const Color darkScaffoldBackground = Color(0xFF0B0F19);
  static const Color darkSurface = Color(0xFF151D2E);
  static const Color darkSurfaceVariant = Color(0xFF1A2238);
  static const Color darkCardElevated = Color(0xFF1E2842);
  static const Color darkBorder = Color(0xFF263352);
  static const Color darkBorderSubtle = Color(0xFF1E293B);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextDisabled = Color(0xFF64748B);

  // Priority Colors
  static const Color priorityLow = Color(0xFF3882F6);
  static const Color priorityMedium = Color(0xFFF59E0B);
  static const Color priorityHigh = Color(0xFFEF4444);

  // Status Badge Colors (Light)
  static const Color lightSuccessBackground = Color(0xFFDEF7EC);
  static const Color lightSuccessText = Color(0xFF0E9F6E);
  static const Color lightWarningBackground = Color(0xFFFEF3C7);
  static const Color lightWarningText = Color(0xFFD97706);
  static const Color lightDangerBackground = Color(0xFFFDE8E8);
  static const Color lightDangerText = Color(0xFFE02424);

  // Status Badge Colors (Dark)
  static const Color darkSuccessBackground = Color(0xFF064E3B);
  static const Color darkSuccessText = Color(0xFF34D399);
  static const Color darkWarningBackground = Color(0xFF78350F);
  static const Color darkWarningText = Color(0xFFFBBF24);
  static const Color darkDangerBackground = Color(0xFF7F1D1D);
  static const Color darkDangerText = Color(0xFFF87171);

  // Subject Default Colors for UI Picker
  static const List<Color> subjectColorPalette = [
    Color(0xFF6750A4), // Purple
    Color(0xFF3882F6), // Blue
    Color(0xFF10B981), // Green
    Color(0xFFF59E0B), // Orange
    Color(0xFFEC4899), // Pink
    Color(0xFF6B7280), // Slate
  ];
}
