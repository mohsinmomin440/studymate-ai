import 'package:flutter/services.dart';

/// Haptic feedback service
class Haptics {
  static void light() {
    HapticFeedback.lightImpact();
  }

  static void medium() {
    HapticFeedback.mediumImpact();
  }

  static void heavy() {
    HapticFeedback.heavyImpact();
  }

  static void selection() {
    HapticFeedback.selectionClick();
  }

  static void success() {
    HapticFeedback.mediumImpact();
  }

  static void error() {
    HapticFeedback.heavyImpact();
  }

  static void warning() {
    HapticFeedback.vibrate();
  }
}
