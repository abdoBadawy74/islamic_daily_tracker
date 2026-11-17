import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_daily_tracker/core/theme/app_colors.dart';
import 'package:islamic_daily_tracker/features/azkar/presentation/screens/electronic_tasbih_screen.dart';
import 'package:islamic_daily_tracker/navigation/main_shell.dart';

class QuickStatsShortcutsWidget extends ConsumerWidget {
  const QuickStatsShortcutsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Text(
              'أقسام المتابعة السريعة',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              // Prayer Shortcut
              Expanded(
                child: _buildItem(
                  context: context,
                  title: 'الصلوات',
                  icon: Icons.mosque_rounded,
                  color: AppColors.primary,
                  onTap: () {
                    ref.read(bottomNavIndexProvider.notifier).state = 1; // Worships
                  },
                ),
              ),
              const SizedBox(width: 10),

              // Quran Shortcut
              Expanded(
                child: _buildItem(
                  context: context,
                  title: 'المصحف',
                  icon: Icons.menu_book_rounded,
                  color: AppColors.emerald,
                  onTap: () {
                    ref.read(bottomNavIndexProvider.notifier).state = 2; // Quran
                  },
                ),
              ),
              const SizedBox(width: 10),

              // Dhikr / Tasbih Shortcut
              Expanded(
                child: _buildItem(
                  context: context,
                  title: 'المسبحة',
                  icon: Icons.fingerprint_rounded,
                  color: AppColors.goldDark,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ElectronicTasbihScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.beigeDark.withValues(alpha: 0.6)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
