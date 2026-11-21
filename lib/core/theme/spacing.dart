/// Spacing, radius, and elevation constants for consistent UI
library;

class AppSpacing {
  // Base spacing units (4dp base)
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  // Semantic spacing
  static const double screenPadding = 16;
  static const double cardPadding = 20;
  static const double sectionGap = 32;
  static const double componentGap = 16;
  static const double itemGap = 12;
  static const double tightGap = 8;
}

class AppRadius {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;
  static const double pill = 999;

  // Semantic radius
  static const double button = 16;
  static const double card = 20;
  static const double chip = 999;
  static const double bottomSheet = 28;
  static const double dialog = 24;
}

class AppElevation {
  // Light mode elevations (soft shadows)
  static const double level0 = 0;
  static const double level1 = 1;
  static const double level2 = 3;
  static const double level3 = 6;
  static const double level4 = 10;
  static const double level5 = 15;

  // Dark mode - use borders/glow instead of shadows
  static const double darkLevel0 = 0;
  static const double darkLevel1 = 0;
  static const double darkLevel2 = 0;
  static const double darkLevel3 = 0;
  static const double darkLevel4 = 0;
  static const double darkLevel5 = 0;
}
