import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_daily_tracker/core/theme/app_colors.dart';
import 'package:islamic_daily_tracker/data/models/prayer_status.dart';
import 'package:islamic_daily_tracker/features/statistics/providers/statistics_providers.dart';

class PrayerHabitGrid extends ConsumerWidget {
  const PrayerHabitGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gridAsync = ref.watch(last7DaysPrayerGridProvider);

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'سجل الصلوات لآخر 7 أيام',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'أسبوعي',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          gridAsync.when(
            data: (days) {
              final prayerKeys = [
                {'name': 'فجر'},
                {'name': 'ظهر'},
                {'name': 'عصر'},
                {'name': 'مغرب'},
                {'name': 'عشاء'},
              ];

              return Column(
                children: [
                  // Column Headers Row
                  Row(
                    children: [
                      const SizedBox(width: 58), // Width of day label column
                      ...prayerKeys.map((p) {
                        return Expanded(
                          child: Center(
                            child: Text(
                              p['name']!,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Day Rows
                  ...days.map((day) {
                    final isToday = day.isToday;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          // Day Label
                          SizedBox(
                            width: 58,
                            child: Text(
                              day.dayNameAr,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                                color: isToday ? AppColors.primary : AppColors.textPrimary,
                              ),
                            ),
                          ),

                          // 5 Prayer Cells
                          ...prayerKeys.map((pk) {
                            final state = day.prayers[pk['name']];
                            return Expanded(
                              child: _buildPrayerCell(state, isToday),
                            );
                          }),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 12),

                  // Legend (matching screenshot 2)
                  const Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    alignment: WrapAlignment.center,
                    children: [
                      _LegendItem(color: AppColors.emerald, icon: Icons.check, label: 'في وقتها'),
                      _LegendItem(color: Colors.orange, icon: Icons.access_time_filled, label: 'قضاء/تأخير'),
                      _LegendItem(color: Colors.redAccent, icon: Icons.close, label: 'فائتة'),
                      _LegendItem(color: Colors.grey, icon: null, label: 'لم تحن'),
                    ],
                  ),
                ],
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (err, _) => Center(
              child: Text('خطأ في تحميل السجل: $err'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerCell(PrayerState? state, bool isToday) {
    Color bg;
    Widget child;
    Border? border;

    switch (state) {
      case PrayerState.onTime:
        bg = AppColors.emerald;
        child = const Icon(Icons.check, color: Colors.white, size: 16);
        break;
      case PrayerState.late_:
        bg = Colors.orange;
        child = const Icon(Icons.access_time_filled, color: Colors.white, size: 14);
        break;
      case PrayerState.missed:
        bg = Colors.red.shade400;
        child = const Icon(Icons.close, color: Colors.white, size: 16);
        break;
      case PrayerState.notRecorded:
      case null:
        if (isToday) {
          bg = Colors.orange.withValues(alpha: 0.08);
          border = Border.all(color: Colors.orange.withValues(alpha: 0.6), width: 1.5);
          child = const SizedBox.shrink();
        } else {
          bg = Colors.grey.shade100;
          border = Border.all(color: Colors.grey.shade300, width: 1);
          child = const SizedBox.shrink();
        }
        break;
    }

    return Container(
      height: 34,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: border,
      ),
      child: Center(child: child),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final IconData? icon;
  final String label;

  const _LegendItem({required this.color, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
          child: icon != null
              ? Icon(icon, size: 10, color: Colors.white)
              : null,
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }
}
