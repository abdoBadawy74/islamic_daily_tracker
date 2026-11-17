import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:islamic_daily_tracker/core/theme/app_colors.dart';
import 'package:islamic_daily_tracker/data/models/azkar_model.dart';

class DhikrCounterWidget extends StatelessWidget {
  final AzkarItem item;
  final VoidCallback onIncrement;
  final VoidCallback onReset;

  const DhikrCounterWidget({
    super.key,
    required this.item,
    required this.onIncrement,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final double pct = item.repetitions > 0
        ? (item.currentCount / item.repetitions).clamp(0.0, 1.0)
        : 0.0;
    final isDone = item.isCompleted;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Counter Display Number
        Text(
          '${item.currentCount}',
          style: TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.bold,
            color: isDone ? AppColors.emerald : AppColors.textPrimary,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isDone
              ? 'مكتمل بنجاح، تقبل الله منك'
              : 'المتبقي: ${item.remaining} من أصل ${item.repetitions}',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDone ? AppColors.emerald : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 20),

        // Big Circular Tap Area with Circular Progress Ring
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onIncrement();
          },
          child: CircularPercentIndicator(
            radius: 88.0,
            lineWidth: 10.0,
            animation: false,
            percent: pct,
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: isDone ? AppColors.gold : AppColors.emerald,
            backgroundColor: AppColors.beigeDark.withValues(alpha: 0.35),
            center: Container(
              width: 145,
              height: 145,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: isDone
                      ? [AppColors.emerald, AppColors.primary]
                      : [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isDone ? Icons.check_circle_rounded : Icons.touch_app_rounded,
                    color: AppColors.textOnPrimary,
                    size: 44,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isDone ? 'اكتمل' : 'اضغط',
                    style: const TextStyle(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Bottom Controls: Reset & Target Badge
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Target Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.beigeDark),
              ),
              child: Row(
                children: [
                  const Icon(Icons.flag_outlined, size: 14, color: AppColors.goldDark),
                  const SizedBox(width: 4),
                  Text(
                    'الهدف: ${item.repetitions}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),

            // Reset Button
            IconButton.filledTonal(
              onPressed: onReset,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              tooltip: 'إعادة تصفير العداد',
            ),
          ],
        ),
      ],
    );
  }
}
