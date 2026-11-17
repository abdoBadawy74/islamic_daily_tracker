import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:islamic_daily_tracker/core/theme/app_colors.dart';
import 'package:islamic_daily_tracker/core/widgets/app_card.dart';
import 'package:islamic_daily_tracker/features/statistics/providers/statistics_providers.dart';

class PrayerStatsChart extends StatelessWidget {
  final PrayerStatsResult stats;

  const PrayerStatsChart({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final hasData = stats.totalRecorded > 0;

    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.mosque_outlined, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'إحصائيات الصلوات المفروضة',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'التزام: ${stats.onTimePercentage.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (!hasData)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'لم يتم تسجيل أي صلوات في هذه الفترة بعد',
                  style: TextStyle(color: AppColors.textLight, fontSize: 13),
                ),
              ),
            )
          else ...[
            // Pie Chart
            SizedBox(
              height: 160,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 3,
                  centerSpaceRadius: 40,
                  sections: [
                    if (stats.onTimeCount > 0)
                      PieChartSectionData(
                        value: stats.onTimeCount.toDouble(),
                        title: '${stats.onTimeCount}',
                        color: AppColors.onTime,
                        radius: 36,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    if (stats.lateCount > 0)
                      PieChartSectionData(
                        value: stats.lateCount.toDouble(),
                        title: '${stats.lateCount}',
                        color: AppColors.late_,
                        radius: 36,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    if (stats.missedCount > 0)
                      PieChartSectionData(
                        value: stats.missedCount.toDouble(),
                        title: '${stats.missedCount}',
                        color: AppColors.missed,
                        radius: 36,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Detailed Data Table
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.beigeDark.withValues(alpha: 0.5)),
              ),
              child: Column(
                children: [
                  _buildStatRow('الصلوات في وقتها', '${stats.onTimeCount}', AppColors.onTime),
                  const Divider(height: 1),
                  _buildStatRow('الصلوات المتأخرة', '${stats.lateCount}', AppColors.late_),
                  const Divider(height: 1),
                  _buildStatRow('الصلوات الفائتة', '${stats.missedCount}', AppColors.missed),
                  const Divider(height: 1),
                  _buildStatRow('إجمالي الصلوات المسجلة', '${stats.totalRecorded}', AppColors.textPrimary, isBold: true),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
