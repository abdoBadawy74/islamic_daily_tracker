import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:islamic_daily_tracker/core/theme/app_colors.dart';
import 'package:islamic_daily_tracker/core/widgets/app_card.dart';
import 'package:islamic_daily_tracker/features/home/providers/home_providers.dart';

class DailyProgressWidget extends ConsumerWidget {
  const DailyProgressWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(dailyProgressProvider);
    final pct = (progress.percentage / 100.0).clamp(0.0, 1.0);

    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          // Circular Progress Indicator
          CircularPercentIndicator(
            radius: 46.0,
            lineWidth: 9.0,
            animation: true,
            animateFromLastPercent: true,
            percent: pct,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${progress.percentage.toInt()}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.primary,
                  ),
                ),
                const Text(
                  'إنجاز',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: progress.percentage >= 80
                ? AppColors.emerald
                : progress.percentage >= 50
                    ? AppColors.gold
                    : AppColors.primary,
            backgroundColor: AppColors.beigeDark.withValues(alpha: 0.4),
          ),
          const SizedBox(width: 18),

          // Details text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'المحاسبة اليومية',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'تم إنجاز ${progress.completedCount} من أصل ${progress.totalCount} عبادة',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                // Linear sub bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 6,
                    backgroundColor: AppColors.beigeDark.withValues(alpha: 0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress.percentage >= 80
                          ? AppColors.emerald
                          : progress.percentage >= 50
                              ? AppColors.gold
                              : AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _getMotivationText(progress.percentage),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.emerald,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMotivationText(double pct) {
    if (pct >= 90) return 'ما شاء الله! همّة إيمانية عالية';
    if (pct >= 70) return 'أحسنت! واصل ثباتك وطاعتك';
    if (pct >= 50) return 'بداية طيبة، استعن بالله وأتمم وردك';
    if (pct > 0) return 'خطوة مباركة، لا تفتر عن الذكر';
    return 'جدّد نيتك وابدأ يومك بذكر الله';
  }
}
