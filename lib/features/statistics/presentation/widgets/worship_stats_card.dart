import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:islamic_daily_tracker/core/theme/app_colors.dart';
import 'package:islamic_daily_tracker/core/widgets/app_card.dart';
import 'package:islamic_daily_tracker/features/statistics/providers/statistics_providers.dart';

class WorshipStatsCard extends StatelessWidget {
  final OverallWorshipStats stats;

  const WorshipStatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Quick Stats Metric Tiles Grid
        AppCard(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ملخص الثبات والإنجاز',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _buildMetricBox(
                    context,
                    title: 'معدل الالتزام',
                    value: '${stats.overallCommitmentRate.toStringAsFixed(1)}%',
                    icon: Icons.trending_up_rounded,
                    color: AppColors.emerald,
                  ),
                  const SizedBox(width: 12),
                  _buildMetricBox(
                    context,
                    title: 'الأيام المتميزة (≥70%)',
                    value: '${stats.successfulDaysCount} يوم',
                    icon: Icons.workspace_premium_outlined,
                    color: AppColors.gold,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildMetricBox(
                    context,
                    title: 'أرباع القرآن',
                    value: '${stats.totalQuranPages} ربع',
                    icon: Icons.menu_book_rounded,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  _buildMetricBox(
                    context,
                    title: 'مرات الذكر والتسبيح',
                    value: '${stats.totalDhikrCount}',
                    icon: Icons.favorite_border_rounded,
                    color: AppColors.goldDark,
                  ),
                ],
              ),
            ],
          ),
        ),

        // Most Consistent Worships (Top 5)
        AppCard(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.star_rounded, color: AppColors.gold, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'أكثر العبادات التزامًا وثباتًا',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (stats.topWorships.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('لا توجد بيانات كافية بعد', style: TextStyle(color: AppColors.textLight)),
                  ),
                )
              else
                ...stats.topWorships.map((item) => _buildCommitmentRow(item, isTop: true)),
            ],
          ),
        ),

        // Worships Needing Improvement
        AppCard(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.energy_savings_leaf_outlined, color: AppColors.late_, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'عبادات تحتاج إلى مزيد من الهمة والمجاهدة',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (stats.needsImprovementWorships.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('لا توجد بيانات كافية بعد', style: TextStyle(color: AppColors.textLight)),
                  ),
                )
              else
                ...stats.needsImprovementWorships.map((item) => _buildCommitmentRow(item, isTop: false)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricBox(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommitmentRow(WorshipCommitmentItem item, {required bool isTop}) {
    final pct = (item.commitmentPercentage / 100.0).clamp(0.0, 1.0);
    final color = isTop ? AppColors.emerald : AppColors.late_;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.worship.name,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              Text(
                '${item.commitmentPercentage.toInt()}% (${item.daysCompleted} يوم)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearPercentIndicator(
              lineHeight: 6.0,
              percent: pct,
              padding: EdgeInsets.zero,
              backgroundColor: AppColors.beigeDark.withValues(alpha: 0.35),
              progressColor: color,
              barRadius: const Radius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
