import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:islamic_daily_tracker/core/theme/app_colors.dart';
import 'package:islamic_daily_tracker/core/widgets/app_card.dart';
import 'package:islamic_daily_tracker/features/quran/presentation/widgets/log_reading_dialog.dart';
import 'package:islamic_daily_tracker/features/quran/presentation/screens/quran_history_screen.dart';
import 'package:islamic_daily_tracker/features/quran/providers/quran_providers.dart';

class QuranProgressCard extends ConsumerWidget {
  const QuranProgressCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayProgressAsync = ref.watch(todayQuranProgressProvider);
    final totalPagesAsync = ref.watch(totalPagesReadProvider);

    return todayProgressAsync.when(
      data: (progress) {
        final pct = (progress.completionPercentage / 100.0).clamp(0.0, 1.0);
        final totalPages = totalPagesAsync.value ?? 0;

        return AppCard(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'الورد اليومي للقرآن',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (progress.lastSurahName != null)
                            Text(
                              'آخر موضع: سورة ${progress.lastSurahName} ${progress.ayahNumber != null ? "(آية ${progress.ayahNumber})" : ""}',
                              style: const TextStyle(fontSize: 11, color: AppColors.goldDark),
                            ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.history_rounded, color: AppColors.primary),
                    tooltip: 'سجل القراءة السابق',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const QuranHistoryScreen()),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Progress values
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${progress.pagesRead} من ${progress.dailyTarget} صفحة',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  Text(
                    '${progress.completionPercentage.toInt()}%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Linear Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearPercentIndicator(
                  lineHeight: 10.0,
                  percent: pct,
                  padding: EdgeInsets.zero,
                  backgroundColor: AppColors.beigeDark.withValues(alpha: 0.4),
                  progressColor: AppColors.primary,
                  barRadius: const Radius.circular(8),
                ),
              ),
              const SizedBox(height: 12),

              // Bottom Info & Quick Log Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_stories_outlined, size: 16, color: AppColors.textLight),
                      const SizedBox(width: 4),
                      Text(
                        'إجمالي ما قرأت: $totalPages صفحة',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => const LogReadingDialog(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.add, size: 16, color: AppColors.textOnPrimary),
                    label: const Text(
                      'تسجيل قراءة',
                      style: TextStyle(fontSize: 12, color: AppColors.textOnPrimary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, _) => Center(child: Text('خطأ: $err')),
    );
  }
}
