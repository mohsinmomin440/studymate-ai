/// Common extensions for cleaner code
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/generated/app_localizations.dart';

// BuildContext extensions
extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get screenWidth => mediaQuery.size.width;
  double get screenHeight => mediaQuery.size.height;
  double get statusBarHeight => mediaQuery.padding.top;
  double get bottomPadding => mediaQuery.padding.bottom;
  bool get isDark => theme.brightness == Brightness.dark;
  bool get isKeyboardOpen => mediaQuery.viewInsets.bottom > 0;
  ScaffoldMessengerState get scaffoldMessenger => ScaffoldMessenger.of(this);
  NavigatorState get navigator => Navigator.of(this);
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

// String extensions
extension StringX on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  String capitalizeWords() => split(' ').map((w) => w.capitalize()).join(' ');

  bool get isNotBlank => trim().isNotEmpty;

  String truncate(int maxLength, {String suffix = '...'}) =>
      length <= maxLength ? this : '${substring(0, maxLength)}$suffix';

  String removeHtmlTags() => replaceAll(RegExp(r'<[^>]*>'), '');

  // Date parsing
  DateTime? tryParseDate({String? format}) {
    try {
      if (format != null) {
        return DateFormat(format).parse(this);
      }
      return DateTime.parse(this);
    } catch (_) {
      return null;
    }
  }
}

// DateTime extensions
extension DateTimeX on DateTime {
  String format({String format = 'MMM d, yyyy'}) =>
      DateFormat(format).format(this);

  String formatTime({String format = 'h:mm a'}) =>
      DateFormat(format).format(this);

  String formatRelative() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  bool isToday() => isSameDay(DateTime.now());

  bool isYesterday() =>
      isSameDay(DateTime.now().subtract(const Duration(days: 1)));

  DateTime get startOfDay => DateTime(year, month, day);

  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  String get yyyyMMdd => DateFormat('yyyy-MM-dd').format(this);
}

// Duration extensions
extension DurationX on Duration {
  String format({bool showSeconds = false}) {
    final hours = inHours;
    final minutes = inMinutes.remainder(60);
    final seconds = inSeconds.remainder(60);

    if (hours > 0) {
      return showSeconds
          ? '${hours}h ${minutes}m ${seconds}s'
          : '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return showSeconds ? '${minutes}m ${seconds}s' : '${minutes}m';
    } else {
      return '${seconds}s';
    }
  }

  String formatMMSS() {
    final minutes = inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

// Num extensions
extension NumX on num {
  String formatCompact() {
    if (this >= 1000000) {
      return '${(this / 1000000).toStringAsFixed(1)}M';
    } else if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(1)}K';
    }
    return toString();
  }

  int clampInt(int min, int max) => clamp(min, max).toInt();
}

// Color extensions
extension ColorX on Color {
  Color withAlphaValue(double alpha) =>
      withValues(alpha: alpha.clamp(0.0, 1.0));

  Color lighten(double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  Color darken(double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }
}

// List extensions
extension ListX<T> on List<T> {
  List<T> distinctBy<K>(K Function(T) key) {
    final seen = <K>{};
    return where((element) => seen.add(key(element))).toList();
  }

  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

// Widget extensions
extension WidgetX on Widget {
  Widget paddingAll(double value) =>
      Padding(padding: EdgeInsets.all(value), child: this);

  Widget paddingSymmetric({double horizontal = 0, double vertical = 0}) =>
      Padding(
          padding:
              EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
          child: this);

  Widget paddingOnly(
          {double left = 0,
          double top = 0,
          double right = 0,
          double bottom = 0}) =>
      Padding(
          padding: EdgeInsets.only(
              left: left, top: top, right: right, bottom: bottom),
          child: this);

  Widget centered() => Center(child: this);

  Widget expanded({int flex = 1}) => Expanded(flex: flex, child: this);

  Widget flexible({int flex = 1, FlexFit fit = FlexFit.loose}) =>
      Flexible(flex: flex, fit: fit, child: this);

  Widget constrained(
          {double? minWidth,
          double maxWidth = double.infinity,
          double? minHeight,
          double maxHeight = double.infinity}) =>
      ConstrainedBox(
          constraints: BoxConstraints(
              minWidth: minWidth ?? 0,
              maxWidth: maxWidth,
              minHeight: minHeight ?? 0,
              maxHeight: maxHeight),
          child: this);

  Widget withGap(double gap) => Column(children: [this, SizedBox(height: gap)]);

  Widget withGapWidth(double gap) =>
      Row(children: [this, SizedBox(width: gap)]);

  Widget visible(bool visible) => visible ? this : const SizedBox.shrink();
}

// AsyncValue extensions for Riverpod
extension AsyncValueX<T> on AsyncValue<T> {
  T? get dataOrNull => maybeWhen(data: (d) => d, orElse: () => null);

  Object? get errorOrNull => maybeWhen(error: (e, _) => e, orElse: () => null);

  StackTrace? get stackTraceOrNull =>
      maybeWhen(error: (e, stackTrace) => stackTrace, orElse: () => null);

  bool get isLoading =>
      when(loading: () => true, data: (_) => false, error: (_, __) => false);

  bool get hasError =>
      when(loading: () => false, data: (_) => false, error: (_, __) => true);

  R whenOrNull<R>({
    R Function(T data)? data,
    R Function(Object error, StackTrace stackTrace)? error,
    R Function()? loading,
  }) =>
      when(
          data: data ?? (_) => null as R,
          error: error ?? (_, __) => null as R,
          loading: loading ?? () => null as R);
}
