import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:islamic_daily_tracker/core/theme/app_colors.dart';
import 'package:islamic_daily_tracker/features/statistics/providers/statistics_providers.dart';

class SpiritualJourneyOverviewCard extends ConsumerWidget {
  const SpiritualJourneyOverviewCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(spiritualJourneyOverviewProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.beigeDark.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: overviewAsync.when(
        data: (data) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Top 3 Journey Cards (Prayer, Quran, Tasbih) matching Screenshot 2
              Row(
                children: [
                  // Prayer card
                  Expanded(
                    child: _buildMetricCard(
                      title: 'الصلوات',
                      value: '${data.todayPrayersDone}/5',
                      percent: (data.todayPrayersDone / 5.0).clamp(0.0, 1.0),
                      color: const Color(0xFF6366F1), // Elegant Indigo / Purple as in screenshot 2
                      icon: Icons.mosque_outlined,
                      isActive: true,
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Quran card
                  Expanded(
                    child: _buildMetricCard(
                      title: 'القرآن',
                      value: '${data.todayQuranPages} ص',
                      percent: (data.todayQuranPages / 20.0).clamp(0.0, 1.0),
                      color: const Color(0xFF0EA5E9), // Sky Blue as in screenshot 2
                      icon: Icons.menu_book_outlined,
                      isActive: false,
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Tasbih card
                  Expanded(
                    child: _buildMetricCard(
                      title: 'التسبيح',
                      value: '${data.todayTasbihCount}',
                      percent: (data.todayTasbihCount / 100.0).clamp(0.0, 1.0),
                      color: const Color(0xFFF59E0B), // Warm Gold as in screenshot 2
                      icon: Icons.fingerprint_rounded,
                      isActive: false,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 2. Overview Title
              const Text(
                'نظرة عامة على الالتزام',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),

              // 3. Four Progress Bars (Today, 7 Days, 30 Days, 90 Days) matching Screenshot 2
              _buildHorizontalBar('اليوم', data.todayPct, const Color(0xFFF97316)),
              const SizedBox(height: 12),
              _buildHorizontalBar('7 أيام', data.weekPct, const Color(0xFFF97316)),
              const SizedBox(height: 12),
              _buildHorizontalBar('30 يوم', data.monthPct, const Color(0xFFF97316)),
              const SizedBox(height: 12),
              _buildHorizontalBar('90 يوم', data.ninetyDaysPct, const Color(0xFFF97316)),
            ],
          );
        },
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (err, _) => Center(child: Text('خطأ: $err')),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required double percent,
    required Color color,
    required IconData icon,
    required bool isActive,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: isActive ? color.withValues(alpha: 0.12) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? color.withValues(alpha: 0.5) : Colors.grey.shade200,
          width: isActive ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        children: [
          CircularPercentIndicator(
            radius: 22.0,
            lineWidth: 4.0,
            percent: percent,
            center: Icon(icon, color: color, size: 18),
            progressColor: color,
            backgroundColor: color.withValues(alpha: 0.2),
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalBar(String label, double percentage, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 55,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearPercentIndicator(
              lineHeight: 8.0,
              percent: (percentage / 100.0).clamp(0.0, 1.0),
              padding: EdgeInsets.zero,
              backgroundColor: color.withValues(alpha: 0.15),
              progressColor: color,
              barRadius: const Radius.circular(6),
            ),
          ),
        ),
        const SizedBox(width: 14),
        SizedBox(
          width: 42,
          child: Text(
            '${percentage.toInt()}%',
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
