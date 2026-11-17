import 'package:flutter/material.dart';
import 'package:islamic_daily_tracker/core/theme/app_colors.dart';
import 'package:islamic_daily_tracker/data/models/worship_model.dart';

class WorshipTypeBadge extends StatelessWidget {
  final WorshipType type;

  const WorshipTypeBadge({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: config.color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 12, color: config.color),
          const SizedBox(width: 4),
          Text(
            config.label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: config.color,
            ),
          ),
        ],
      ),
    );
  }

  _TypeConfig _getConfig(WorshipType type) {
    switch (type) {
      case WorshipType.boolean_:
        return const _TypeConfig(
          label: 'إنجاز/نعم-لا',
          color: AppColors.primary,
          icon: Icons.check_box_outlined,
        );
      case WorshipType.counter:
        return const _TypeConfig(
          label: 'عداد',
          color: AppColors.goldDark,
          icon: Icons.pin_outlined,
        );
      case WorshipType.quantity:
        return const _TypeConfig(
          label: 'كمية',
          color: AppColors.emerald,
          icon: Icons.format_list_numbered,
        );
      case WorshipType.duration:
        return const _TypeConfig(
          label: 'مدة زمنية',
          color: Colors.blueAccent,
          icon: Icons.timer_outlined,
        );
    }
  }
}

class _TypeConfig {
  final String label;
  final Color color;
  final IconData icon;

  const _TypeConfig({required this.label, required this.color, required this.icon});
}
