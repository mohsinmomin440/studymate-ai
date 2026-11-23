import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Reusable SVG Icon widget with fallbacks
class AppSvgIcon extends StatelessWidget {
  final String assetPath;
  final double size;
  final Color? color;
  final IconData? fallbackIcon;

  const AppSvgIcon({
    super.key,
    required this.assetPath,
    this.size = 24,
    this.color,
    this.fallbackIcon,
  });

  // Pre-configured factory constructors for common icons
  factory AppSvgIcon.streakFlame({double size = 24}) => AppSvgIcon(
        assetPath: 'assets/svg/streak_flame.svg',
        size: size,
        fallbackIcon: Icons.local_fire_department_rounded,
      );

  factory AppSvgIcon.xpBolt({double size = 24}) => AppSvgIcon(
        assetPath: 'assets/svg/xp_bolt.svg',
        size: size,
        fallbackIcon: Icons.bolt_rounded,
      );

  factory AppSvgIcon.trophy({double size = 24}) => AppSvgIcon(
        assetPath: 'assets/svg/trophy.svg',
        size: size,
        fallbackIcon: Icons.emoji_events_rounded,
      );

  factory AppSvgIcon.celebration({double size = 24}) => AppSvgIcon(
        assetPath: 'assets/svg/celebration.svg',
        size: size,
        fallbackIcon: Icons.celebration_rounded,
      );

  factory AppSvgIcon.studyBook({double size = 24}) => AppSvgIcon(
        assetPath: 'assets/svg/study_book.svg',
        size: size,
        fallbackIcon: Icons.menu_book_rounded,
      );

  factory AppSvgIcon.robotAi({double size = 24}) => AppSvgIcon(
        assetPath: 'assets/svg/robot_ai.svg',
        size: size,
        fallbackIcon: Icons.smart_toy_rounded,
      );

  factory AppSvgIcon.cameraScan({double size = 24}) => AppSvgIcon(
        assetPath: 'assets/svg/camera_scan.svg',
        size: size,
        fallbackIcon: Icons.camera_alt_rounded,
      );

  factory AppSvgIcon.cardsStack({double size = 24}) => AppSvgIcon(
        assetPath: 'assets/svg/cards_stack.svg',
        size: size,
        fallbackIcon: Icons.style_rounded,
      );

  factory AppSvgIcon.timerClock({double size = 24}) => AppSvgIcon(
        assetPath: 'assets/svg/timer_clock.svg',
        size: size,
        fallbackIcon: Icons.timer_rounded,
      );

  factory AppSvgIcon.target({double size = 24}) => AppSvgIcon(
        assetPath: 'assets/svg/target_bullseye.svg',
        size: size,
        fallbackIcon: Icons.track_changes_rounded,
      );

  factory AppSvgIcon.badge(String badgeId, {double size = 36}) {
    final Map<String, String> badgeMap = {
      'first_quiz': 'assets/svg/badge_first_quiz.svg',
      'quiz_master_10': 'assets/svg/badge_quiz_master.svg',
      'first_note': 'assets/svg/badge_note_taker.svg',
      'first_chat': 'assets/svg/badge_curious_mind.svg',
      'streak_7': 'assets/svg/badge_streak_7.svg',
      'streak_30': 'assets/svg/badge_streak_30.svg',
      'cards_100': 'assets/svg/badge_cards_100.svg',
      'focus_5_hours': 'assets/svg/badge_focus_5.svg',
    };

    final asset = badgeMap[badgeId] ?? 'assets/svg/trophy.svg';
    return AppSvgIcon(
      assetPath: asset,
      size: size,
      fallbackIcon: Icons.emoji_events_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
      placeholderBuilder: (BuildContext context) {
        if (fallbackIcon != null) {
          return Icon(
            fallbackIcon,
            size: size,
            color: color,
          );
        }
        return SizedBox(width: size, height: size);
      },
    );
  }
}
