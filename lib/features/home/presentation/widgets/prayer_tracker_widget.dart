import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_daily_tracker/core/theme/app_colors.dart';
import 'package:islamic_daily_tracker/core/widgets/app_card.dart';
import 'package:islamic_daily_tracker/data/models/prayer_status.dart';
import 'package:islamic_daily_tracker/features/home/providers/home_providers.dart';

class PrayerTrackerWidget extends ConsumerWidget {
  const PrayerTrackerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayersAsync = ref.watch(dailyPrayersProvider);
    final homeActions = ref.read(homeActionsProvider);

    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.mosque_outlined, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'الصلوات الخمس',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const Text(
                'اضغط لتغيير الحالة',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 5 Prayers Row
          prayersAsync.when(
            data: (prayers) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: prayers.map((p) => _PrayerItem(
                  prayer: p,
                  onTap: () => homeActions.cyclePrayerStatus(p),
                )).toList(),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (err, stack) => Center(
              child: Text('خطأ: $err', style: const TextStyle(color: AppColors.error)),
            ),
          ),

          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Legend for prayer states
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegend(AppColors.onTime, 'في وقتها'),
              _buildLegend(AppColors.late_, 'متأخرة'),
              _buildLegend(AppColors.missed, 'فائتة'),
              _buildLegend(AppColors.notRecorded, 'غير مسجلة'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _PrayerItem extends StatelessWidget {
  final PrayerStatus prayer;
  final VoidCallback onTap;

  const _PrayerItem({required this.prayer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusConfig = _getStatusConfig(prayer.state);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 58,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: statusConfig.bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: statusConfig.borderColor,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              statusConfig.icon,
              color: statusConfig.iconColor,
              size: 22,
            ),
            const SizedBox(height: 6),
            Text(
              prayer.prayerName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: statusConfig.textColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              statusConfig.label,
              style: TextStyle(
                fontSize: 9,
                color: statusConfig.textColor.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _StatusConfig _getStatusConfig(PrayerState state) {
    switch (state) {
      case PrayerState.onTime:
        return _StatusConfig(
          icon: Icons.check_circle_rounded,
          iconColor: AppColors.onTime,
          bgColor: AppColors.onTime.withValues(alpha: 0.1),
          borderColor: AppColors.onTime,
          textColor: AppColors.primaryDark,
          label: 'في وقتها',
        );
      case PrayerState.late_:
        return _StatusConfig(
          icon: Icons.access_time_filled_rounded,
          iconColor: AppColors.late_,
          bgColor: AppColors.late_.withValues(alpha: 0.1),
          borderColor: AppColors.late_,
          textColor: Colors.deepOrange,
          label: 'متأخرة',
        );
      case PrayerState.missed:
        return _StatusConfig(
          icon: Icons.cancel_rounded,
          iconColor: AppColors.missed,
          bgColor: AppColors.missed.withValues(alpha: 0.1),
          borderColor: AppColors.missed,
          textColor: AppColors.error,
          label: 'فائتة',
        );
      case PrayerState.notRecorded:
        return _StatusConfig(
          icon: Icons.radio_button_unchecked_rounded,
          iconColor: AppColors.notRecorded,
          bgColor: AppColors.surface,
          borderColor: AppColors.beigeDark,
          textColor: AppColors.textLight,
          label: 'لم تسجل',
        );
    }
  }
}

class _StatusConfig {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final Color borderColor;
  final Color textColor;
  final String label;

  const _StatusConfig({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.borderColor,
    required this.textColor,
    required this.label,
  });
}
