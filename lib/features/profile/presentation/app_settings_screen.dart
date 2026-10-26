import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/app_card.dart';

class AppSettingsScreen extends ConsumerWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appearance',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.neonPurple : AppColors.primaryPurple,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose your preferred appearance mode. Themes apply instantly across all screens.',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 20),

            // Light Mode Option
            _buildThemeOptionCard(
              context: context,
              title: 'Light Mode',
              subtitle: 'Clean white surface with royal purple accents',
              icon: Icons.light_mode_rounded,
              iconColor: const Color(0xFFF59E0B),
              isSelected: currentTheme == ThemeMode.light,
              onTap: () => themeNotifier.setThemeMode(ThemeMode.light),
              previewColors: const [
                Color(0xFFF8F9FE),
                Color(0xFFFFFFFF),
                Color(0xFF6750A4),
              ],
            ),
            const SizedBox(height: 14),

            // Dark Mode Option
            _buildThemeOptionCard(
              context: context,
              title: 'Dark Mode',
              subtitle: 'Deep navy background with neon-purple glowing accents',
              icon: Icons.dark_mode_rounded,
              iconColor: AppColors.neonPurple,
              isSelected: currentTheme == ThemeMode.dark,
              onTap: () => themeNotifier.setThemeMode(ThemeMode.dark),
              previewColors: const [
                Color(0xFF0B0F19),
                Color(0xFF151D2E),
                Color(0xFF8B5CF6),
              ],
            ),
            const SizedBox(height: 14),

            // System Default Option
            _buildThemeOptionCard(
              context: context,
              title: 'System Default',
              subtitle: 'Matches your device operating system theme automatically',
              icon: Icons.settings_suggest_rounded,
              iconColor: isDark ? AppColors.blue : AppColors.primaryPurple,
              isSelected: currentTheme == ThemeMode.system,
              onTap: () => themeNotifier.setThemeMode(ThemeMode.system),
              previewColors: const [
                Color(0xFF6750A4),
                Color(0xFF8B5CF6),
                Color(0xFF3882F6),
              ],
            ),
            const SizedBox(height: 32),

            // Interactive Live Preview Box
            Text(
              'Theme Preview & Contrast',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 12),
            AppCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.neonPurple.withOpacity(0.2)
                              : AppColors.primaryPurple.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.visibility_rounded,
                          size: 20,
                          color: isDark ? AppColors.neonPurple : AppColors.primaryPurple,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sample Task Card',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                            Text(
                              'Active Theme: ${isDark ? "Dark (Navy & Neon Purple)" : "Light (White & Purple)"}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSuccessBackground
                              : AppColors.lightSuccessBackground,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'High Contrast',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkSuccessText
                                : AppColors.lightSuccessText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'High-readability typography, verified color tokens, and accessible contrast conform with Android WCAG AA guidelines.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOptionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isSelected,
    required VoidCallback onTap,
    required List<Color> previewColors,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.neonPurple : AppColors.primaryPurple;

    return AppCard(
      onTap: onTap,
      border: Border.all(
        color: isSelected
            ? primaryColor
            : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
        width: isSelected ? 2 : 1,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Color chips
                    Row(
                      children: previewColors.map((c) {
                        return Container(
                          margin: const EdgeInsets.only(left: 3),
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark ? Colors.white24 : Colors.black12,
                              width: 1,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Radio<bool>(
            value: true,
            groupValue: isSelected ? true : null,
            activeColor: primaryColor,
            onChanged: (_) => onTap(),
          ),
        ],
      ),
    );
  }
}
