import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';
import 'typography.dart';
import 'spacing.dart';

/// Main app theme configuration
class AppTheme {
  static ThemeData get dark => _buildTheme(Brightness.dark);
  static ThemeData get light => _buildTheme(Brightness.light);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colors = isDark ? const _DarkScheme() : const _LightScheme();

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: colors.primary,
      onPrimary: colors.onPrimary,
      primaryContainer: colors.primaryContainer,
      onPrimaryContainer: colors.onPrimaryContainer,
      secondary: colors.secondary,
      onSecondary: colors.onSecondary,
      secondaryContainer: colors.secondaryContainer,
      onSecondaryContainer: colors.onSecondaryContainer,
      tertiary: colors.tertiary,
      onTertiary: colors.onTertiary,
      tertiaryContainer: colors.tertiaryContainer,
      onTertiaryContainer: colors.onTertiaryContainer,
      error: colors.error,
      onError: colors.onError,
      errorContainer: colors.errorContainer,
      onErrorContainer: colors.onErrorContainer,
      surface: colors.surface,
      onSurface: colors.onSurface,
      onSurfaceVariant: colors.onSurfaceVariant,
      outline: colors.outline,
      outlineVariant: colors.outlineVariant,
      shadow: colors.shadow,
      scrim: colors.scrim,
      inverseSurface: colors.inverseSurface,
      onInverseSurface: colors.onInverseSurface,
      inversePrimary: colors.inversePrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: isDark ? AppTypography.dark : AppTypography.light,
      scaffoldBackgroundColor: colors.scaffoldBackground,
      canvasColor: colors.canvasColor,
      cardTheme: CardThemeData(
        color: colors.cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: colors.cardBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: (isDark ? AppTypography.dark : AppTypography.light)
            .titleLarge
            ?.copyWith(
              color: colors.appBarTitleColor,
            ),
        iconTheme: IconThemeData(color: colors.iconColor),
        actionsIconTheme: IconThemeData(color: colors.iconColor),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.bottomNavBackground,
        selectedItemColor: colors.bottomNavSelected,
        unselectedItemColor: colors.bottomNavUnselected,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
        selectedLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.fabBackground,
        foregroundColor: colors.fabForeground,
        elevation: isDark ? 0 : AppElevation.level3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          elevation: isDark ? 0 : AppElevation.level1,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          textStyle:
              (isDark ? AppTypography.dark : AppTypography.light).labelLarge,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          textStyle:
              (isDark ? AppTypography.dark : AppTypography.light).labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          side: BorderSide(color: colors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          textStyle:
              (isDark ? AppTypography.dark : AppTypography.light).labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          textStyle:
              (isDark ? AppTypography.dark : AppTypography.light).labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.inputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: BorderSide(color: colors.inputBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: BorderSide(color: colors.inputBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: BorderSide(color: colors.error, width: 1),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: BorderSide(color: colors.inputBorderDisabled, width: 1),
        ),
        labelStyle: (isDark ? AppTypography.dark : AppTypography.light)
            .bodyMedium
            ?.copyWith(
              color: colors.inputLabel,
            ),
        hintStyle: (isDark ? AppTypography.dark : AppTypography.light)
            .bodyMedium
            ?.copyWith(
              color: colors.inputHint,
            ),
        errorStyle: (isDark ? AppTypography.dark : AppTypography.light)
            .bodySmall
            ?.copyWith(
              color: colors.error,
            ),
        floatingLabelStyle: (isDark ? AppTypography.dark : AppTypography.light)
            .bodySmall
            ?.copyWith(
              color: colors.primary,
            ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.chipBackground,
        selectedColor: colors.chipSelected,
        disabledColor: colors.chipDisabled,
        labelStyle:
            (isDark ? AppTypography.dark : AppTypography.light).labelMedium,
        secondaryLabelStyle: (isDark ? AppTypography.dark : AppTypography.light)
            .labelMedium
            ?.copyWith(
              color: colors.onPrimary,
            ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.chip),
          side: BorderSide(color: colors.chipBorder, width: 1),
        ),
        brightness: brightness,
      ),
      dividerTheme: DividerThemeData(
        color: colors.divider,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        tileColor: Colors.transparent,
        selectedTileColor: colors.listTileSelected,
        iconColor: colors.iconColor,
        textColor: colors.onSurface,
        titleTextStyle:
            (isDark ? AppTypography.dark : AppTypography.light).titleMedium,
        subtitleTextStyle:
            (isDark ? AppTypography.dark : AppTypography.light).bodyMedium,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.dialogBackground,
        elevation: isDark ? 0 : AppElevation.level4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.dialog),
        ),
        titleTextStyle:
            (isDark ? AppTypography.dark : AppTypography.light).titleLarge,
        contentTextStyle:
            (isDark ? AppTypography.dark : AppTypography.light).bodyMedium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.bottomSheetBackground,
        elevation: isDark ? 0 : AppElevation.level4,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.bottomSheet),
          ),
        ),
        modalBackgroundColor: colors.bottomSheetBackground,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.snackBarBackground,
        contentTextStyle: (isDark ? AppTypography.dark : AppTypography.light)
            .bodyMedium
            ?.copyWith(
              color: colors.onSurface,
            ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: isDark ? 0 : AppElevation.level3,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colors.tooltipBackground,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        textStyle: (isDark ? AppTypography.dark : AppTypography.light)
            .bodySmall
            ?.copyWith(
              color: colors.onSurface,
            ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.primary,
        linearTrackColor: colors.progressTrack,
        circularTrackColor: colors.progressTrack,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: colors.primary,
        inactiveTrackColor: colors.sliderInactive,
        thumbColor: colors.primary,
        overlayColor: colors.primary.withValues(alpha: 0.1),
        valueIndicatorColor: colors.primary,
        valueIndicatorTextStyle:
            (isDark ? AppTypography.dark : AppTypography.light)
                .labelSmall
                ?.copyWith(
                  color: colors.onPrimary,
                ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: colors.tabSelected,
        unselectedLabelColor: colors.tabUnselected,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: colors.primary, width: 3),
          insets: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        ),
        labelStyle:
            (isDark ? AppTypography.dark : AppTypography.light).labelLarge,
        unselectedLabelStyle:
            (isDark ? AppTypography.dark : AppTypography.light).labelLarge,
        dividerColor: Colors.transparent,
      ),
      extensions: <ThemeExtension<dynamic>>[
        AppGradients(isDark: isDark),
        AppCustomColors(isDark: isDark),
      ],
    );
  }
}

/// Abstract interface for color schemes
abstract class _AppColorScheme {
  // ColorScheme properties
  Color get primary;
  Color get onPrimary;
  Color get primaryContainer;
  Color get onPrimaryContainer;
  Color get secondary;
  Color get onSecondary;
  Color get secondaryContainer;
  Color get onSecondaryContainer;
  Color get tertiary;
  Color get onTertiary;
  Color get tertiaryContainer;
  Color get onTertiaryContainer;
  Color get error;
  Color get onError;
  Color get errorContainer;
  Color get onErrorContainer;
  Color get surface;
  Color get onSurface;
  Color get onSurfaceVariant;
  Color get outline;
  Color get outlineVariant;
  Color get shadow;
  Color get scrim;
  Color get inverseSurface;
  Color get onInverseSurface;
  Color get inversePrimary;

  // Custom properties
  Color get scaffoldBackground;
  Color get canvasColor;
  Color get cardColor;
  Color get cardBorder;
  Color get appBarTitleColor;
  Color get iconColor;
  Color get bottomNavBackground;
  Color get bottomNavSelected;
  Color get bottomNavUnselected;
  Color get fabBackground;
  Color get fabForeground;
  Color get inputFill;
  Color get inputBorder;
  Color get inputBorderDisabled;
  Color get inputLabel;
  Color get inputHint;
  Color get chipBackground;
  Color get chipSelected;
  Color get chipDisabled;
  Color get chipBorder;
  Color get divider;
  Color get listTileSelected;
  Color get dialogBackground;
  Color get bottomSheetBackground;
  Color get snackBarBackground;
  Color get tooltipBackground;
  Color get progressTrack;
  Color get sliderInactive;
  Color get tabSelected;
  Color get tabUnselected;
}

/// Color scheme for dark mode
class _DarkScheme implements _AppColorScheme {
  const _DarkScheme();

  @override
  Color get primary => DarkColors.primaryStart;
  @override
  Color get onPrimary => Colors.white;
  @override
  Color get primaryContainer => DarkColors.primaryStart.withValues(alpha: 0.2);
  @override
  Color get onPrimaryContainer => DarkColors.primaryEnd;
  @override
  Color get secondary => DarkColors.accent;
  @override
  Color get onSecondary => DarkColors.background;
  @override
  Color get secondaryContainer => DarkColors.accent.withValues(alpha: 0.2);
  @override
  Color get onSecondaryContainer => DarkColors.accent;
  @override
  Color get tertiary => DarkColors.warning;
  @override
  Color get onTertiary => DarkColors.background;
  @override
  Color get tertiaryContainer => DarkColors.warning.withValues(alpha: 0.2);
  @override
  Color get onTertiaryContainer => DarkColors.warning;
  @override
  Color get error => DarkColors.error;
  @override
  Color get onError => Colors.white;
  @override
  Color get errorContainer => DarkColors.error.withValues(alpha: 0.2);
  @override
  Color get onErrorContainer => DarkColors.error;
  @override
  Color get surface => DarkColors.surface;
  @override
  Color get onSurface => DarkColors.textPrimary;
  @override
  Color get onSurfaceVariant => DarkColors.textSecondary;
  @override
  Color get outline => DarkColors.border;
  @override
  Color get outlineVariant => DarkColors.border.withValues(alpha: 0.5);
  @override
  Color get shadow => Colors.black.withValues(alpha: 0.3);
  @override
  Color get scrim => Colors.black.withValues(alpha: 0.5);
  @override
  Color get inverseSurface => LightColors.background;
  @override
  Color get onInverseSurface => LightColors.textPrimary;
  @override
  Color get inversePrimary => LightColors.primaryStart;

  @override
  Color get scaffoldBackground => DarkColors.background;
  @override
  Color get canvasColor => DarkColors.surface;
  @override
  Color get cardColor => DarkColors.surfaceElevated;
  @override
  Color get cardBorder => DarkColors.border;
  @override
  Color get appBarTitleColor => DarkColors.textPrimary;
  @override
  Color get iconColor => DarkColors.textSecondary;
  @override
  Color get bottomNavBackground => DarkColors.surface;
  @override
  Color get bottomNavSelected => DarkColors.primaryEnd;
  @override
  Color get bottomNavUnselected => DarkColors.textSecondary;
  @override
  Color get fabBackground => DarkColors.primaryStart;
  @override
  Color get fabForeground => Colors.white;
  @override
  Color get inputFill => DarkColors.surfaceElevated;
  @override
  Color get inputBorder => DarkColors.border;
  @override
  Color get inputBorderDisabled => DarkColors.border.withValues(alpha: 0.3);
  @override
  Color get inputLabel => DarkColors.textSecondary;
  @override
  Color get inputHint => DarkColors.textSecondary.withValues(alpha: 0.6);
  @override
  Color get chipBackground => DarkColors.surfaceElevated;
  @override
  Color get chipSelected => DarkColors.primaryStart.withValues(alpha: 0.3);
  @override
  Color get chipDisabled => DarkColors.border.withValues(alpha: 0.3);
  @override
  Color get chipBorder => DarkColors.border;
  @override
  Color get divider => DarkColors.border;
  @override
  Color get listTileSelected => DarkColors.primaryStart.withValues(alpha: 0.15);
  @override
  Color get dialogBackground => DarkColors.surfaceElevated;
  @override
  Color get bottomSheetBackground => DarkColors.surfaceElevated;
  @override
  Color get snackBarBackground => DarkColors.surfaceElevated;
  @override
  Color get tooltipBackground => DarkColors.surfaceElevated;
  @override
  Color get progressTrack => DarkColors.border;
  @override
  Color get sliderInactive => DarkColors.border;
  @override
  Color get tabSelected => DarkColors.primaryEnd;
  @override
  Color get tabUnselected => DarkColors.textSecondary;
}

/// Color scheme for light mode
class _LightScheme implements _AppColorScheme {
  const _LightScheme();

  @override
  Color get primary => LightColors.primaryStart;
  @override
  Color get onPrimary => Colors.white;
  @override
  Color get primaryContainer =>
      LightColors.primaryStart.withValues(alpha: 0.15);
  @override
  Color get onPrimaryContainer => LightColors.primaryStart;
  @override
  Color get secondary => LightColors.accent;
  @override
  Color get onSecondary => Colors.white;
  @override
  Color get secondaryContainer => LightColors.accent.withValues(alpha: 0.15);
  @override
  Color get onSecondaryContainer => LightColors.accent;
  @override
  Color get tertiary => LightColors.warning;
  @override
  Color get onTertiary => Colors.white;
  @override
  Color get tertiaryContainer => LightColors.warning.withValues(alpha: 0.15);
  @override
  Color get onTertiaryContainer => LightColors.warning;
  @override
  Color get error => LightColors.error;
  @override
  Color get onError => Colors.white;
  @override
  Color get errorContainer => LightColors.error.withValues(alpha: 0.15);
  @override
  Color get onErrorContainer => LightColors.error;
  @override
  Color get surface => LightColors.surface;
  @override
  Color get onSurface => LightColors.textPrimary;
  @override
  Color get onSurfaceVariant => LightColors.textSecondary;
  @override
  Color get outline => LightColors.border;
  @override
  Color get outlineVariant => LightColors.border.withValues(alpha: 0.5);
  @override
  Color get shadow => Colors.black.withValues(alpha: 0.08);
  @override
  Color get scrim => Colors.black.withValues(alpha: 0.3);
  @override
  Color get inverseSurface => DarkColors.background;
  @override
  Color get onInverseSurface => DarkColors.textPrimary;
  @override
  Color get inversePrimary => DarkColors.primaryEnd;

  @override
  Color get scaffoldBackground => LightColors.background;
  @override
  Color get canvasColor => LightColors.surface;
  @override
  Color get cardColor => LightColors.surface;
  @override
  Color get cardBorder => LightColors.border;
  @override
  Color get appBarTitleColor => LightColors.textPrimary;
  @override
  Color get iconColor => LightColors.textSecondary;
  @override
  Color get bottomNavBackground => LightColors.surface;
  @override
  Color get bottomNavSelected => LightColors.primaryStart;
  @override
  Color get bottomNavUnselected => LightColors.textSecondary;
  @override
  Color get fabBackground => LightColors.primaryStart;
  @override
  Color get fabForeground => Colors.white;
  @override
  Color get inputFill => LightColors.surface;
  @override
  Color get inputBorder => LightColors.border;
  @override
  Color get inputBorderDisabled => LightColors.border.withValues(alpha: 0.5);
  @override
  Color get inputLabel => LightColors.textSecondary;
  @override
  Color get inputHint => LightColors.textSecondary.withValues(alpha: 0.6);
  @override
  Color get chipBackground => LightColors.surface;
  @override
  Color get chipSelected => LightColors.primaryStart.withValues(alpha: 0.15);
  @override
  Color get chipDisabled => LightColors.border.withValues(alpha: 0.5);
  @override
  Color get chipBorder => LightColors.border;
  @override
  Color get divider => LightColors.border;
  @override
  Color get listTileSelected => LightColors.primaryStart.withValues(alpha: 0.1);
  @override
  Color get dialogBackground => LightColors.surface;
  @override
  Color get bottomSheetBackground => LightColors.surface;
  @override
  Color get snackBarBackground => LightColors.surfaceElevated;
  @override
  Color get tooltipBackground => LightColors.surfaceElevated;
  @override
  Color get progressTrack => LightColors.border;
  @override
  Color get sliderInactive => LightColors.border;
  @override
  Color get tabSelected => LightColors.primaryStart;
  @override
  Color get tabUnselected => LightColors.textSecondary;
}

/// Gradient extension for consistent gradient usage
class AppGradients extends ThemeExtension<AppGradients> {
  final bool isDark;

  const AppGradients({required this.isDark});

  LinearGradient get primary => LinearGradient(
        colors: isDark
            ? [DarkColors.primaryStart, DarkColors.primaryEnd]
            : [LightColors.primaryStart, LightColors.primaryEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  LinearGradient get primaryVertical => LinearGradient(
        colors: isDark
            ? [DarkColors.primaryStart, DarkColors.primaryEnd]
            : [LightColors.primaryStart, LightColors.primaryEnd],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  LinearGradient get accent => LinearGradient(
        colors: isDark
            ? [DarkColors.accent, DarkColors.accent.withValues(alpha: 0.7)]
            : [LightColors.accent, LightColors.accent.withValues(alpha: 0.7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  LinearGradient get surfaceGlow => LinearGradient(
        colors: isDark
            ? [
                DarkColors.surfaceElevated,
                DarkColors.surface,
              ]
            : [
                LightColors.surface,
                LightColors.background,
              ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  LinearGradient get cardGlass => LinearGradient(
        colors: isDark
            ? [
                Colors.white.withValues(alpha: 0.05),
                Colors.white.withValues(alpha: 0.02),
              ]
            : [
                Colors.white.withValues(alpha: 0.8),
                Colors.white.withValues(alpha: 0.4),
              ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  @override
  AppGradients copyWith({bool? isDark}) =>
      AppGradients(isDark: isDark ?? this.isDark);

  @override
  AppGradients lerp(ThemeExtension<AppGradients>? other, double t) {
    if (other is! AppGradients) return this;
    return AppGradients(isDark: other.isDark);
  }
}

/// Custom colors extension for easy access
class AppCustomColors extends ThemeExtension<AppCustomColors> {
  final bool isDark;

  const AppCustomColors({required this.isDark});

  Color get success => isDark ? DarkColors.success : LightColors.success;
  Color get warning => isDark ? DarkColors.warning : LightColors.warning;
  Color get error => isDark ? DarkColors.error : LightColors.error;
  Color get accent => isDark ? DarkColors.accent : LightColors.accent;
  Color get streakFlame =>
      isDark ? const Color(0xFFFF6B35) : const Color(0xFFE85D04);
  Color get xpPurple =>
      isDark ? const Color(0xFF9B5DE5) : const Color(0xFF7B2DFF);
  Color get levelGold =>
      isDark ? const Color(0xFFFFD700) : const Color(0xFFFFB300);

  @override
  AppCustomColors copyWith({bool? isDark}) =>
      AppCustomColors(isDark: isDark ?? this.isDark);

  @override
  AppCustomColors lerp(ThemeExtension<AppCustomColors>? other, double t) {
    if (other is! AppCustomColors) return this;
    return AppCustomColors(isDark: other.isDark);
  }
}

/// Extension to easily access gradients and custom colors
extension AppThemeExtension on ThemeData {
  AppGradients get gradients => extension<AppGradients>() as AppGradients;
  AppCustomColors get customColors =>
      extension<AppCustomColors>() as AppCustomColors;
}
