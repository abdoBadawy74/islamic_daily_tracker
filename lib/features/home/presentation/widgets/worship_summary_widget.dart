import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_daily_tracker/core/theme/app_colors.dart';
import 'package:islamic_daily_tracker/core/utils/worship_icons.dart';
import 'package:islamic_daily_tracker/core/widgets/app_card.dart';
import 'package:islamic_daily_tracker/core/widgets/empty_state_widget.dart';
import 'package:islamic_daily_tracker/data/models/daily_record.dart';
import 'package:islamic_daily_tracker/data/models/worship_model.dart';
import 'package:islamic_daily_tracker/features/home/providers/home_providers.dart';

class WorshipSummaryWidget extends ConsumerWidget {
  const WorshipSummaryWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final worshipsAsync = ref.watch(activeWorshipsProvider);
    final recordsAsync = ref.watch(dailyRecordsProvider);

    return worshipsAsync.when(
      data: (worships) {
        if (worships.isEmpty) {
          return const EmptyStateWidget(
            title: 'لا توجد عبادات مضافة',
            subtitle: 'يمكنك إضافة عبادات جديدة من قسم "العبادات"',
          );
        }

        final records = recordsAsync.value ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'قائمة العبادات اليومية',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${worships.length} عبادة',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: worships.length,
              itemBuilder: (context, index) {
                final worship = worships[index];
                final record = records.cast<DailyRecord?>().firstWhere(
                  (r) => r?.worshipId == worship.id,
                  orElse: () => null,
                );

                return _DailyWorshipCard(
                  worship: worship,
                  record: record,
                );
              },
            ),
          ],
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, _) => Center(child: Text('خطأ: $err')),
    );
  }
}

class _DailyWorshipCard extends ConsumerWidget {
  final WorshipModel worship;
  final DailyRecord? record;

  const _DailyWorshipCard({
    required this.worship,
    required this.record,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeActions = ref.read(homeActionsProvider);
    final isDone = record?.isGoalMet ?? false;
    final catColor = WorshipIcons.getCategoryColor(worship.category);
    final iconData = WorshipIcons.getIcon(worship.iconName);

    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      backgroundColor: isDone ? AppColors.surface : AppColors.cardBg,
      border: isDone
          ? Border.all(color: AppColors.primaryLight.withValues(alpha: 0.5), width: 1.2)
          : null,
      child: Row(
        children: [
          // Category Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: catColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(iconData, color: catColor, size: 20),
          ),
          const SizedBox(width: 12),

          // Name and Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  worship.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDone ? AppColors.primaryDark : AppColors.textPrimary,
                    decoration: isDone ? TextDecoration.none : null,
                  ),
                ),
                const SizedBox(height: 2),
                _buildSubtitle(),
              ],
            ),
          ),

          // Interactive Action based on Type
          _buildActionWidget(context, homeActions),
        ],
      ),
    );
  }

  Widget _buildSubtitle() {
    switch (worship.type) {
      case WorshipType.boolean_:
        return Text(
          WorshipIcons.getCategoryArabicName(worship.category),
          style: const TextStyle(fontSize: 11, color: AppColors.textLight),
        );
      case WorshipType.counter:
        final current = record?.currentValue ?? 0;
        final target = worship.target ?? 100;
        return Text(
          'المنجز: $current / $target مرة',
          style: const TextStyle(fontSize: 11, color: AppColors.emerald),
        );
      case WorshipType.quantity:
        final current = record?.currentValue ?? 0;
        final target = worship.target ?? 20;
        return Text(
          'المنجز: $current / $target صفحة',
          style: const TextStyle(fontSize: 11, color: AppColors.emerald),
        );
      case WorshipType.duration:
        final current = record?.currentValue ?? 0;
        final target = worship.target ?? 30;
        return Text(
          'المنجز: $current / $target دقيقة',
          style: const TextStyle(fontSize: 11, color: AppColors.emerald),
        );
    }
  }

  Widget _buildActionWidget(BuildContext context, HomeActions homeActions) {
    switch (worship.type) {
      case WorshipType.boolean_:
        final isChecked = record?.isCompleted ?? false;
        return Transform.scale(
          scale: 1.1,
          child: Checkbox(
            value: isChecked,
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            onChanged: (_) => homeActions.toggleBooleanWorship(worship, record),
          ),
        );

      case WorshipType.counter:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () => homeActions.incrementCounterWorship(worship, record, delta: -10),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.beigeDark.withValues(alpha: 0.5),
                ),
                child: const Icon(Icons.remove, size: 16, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(width: 6),
            InkWell(
              onTap: () => homeActions.incrementCounterWorship(worship, record, delta: 10),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 14, color: AppColors.textOnPrimary),
                    SizedBox(width: 2),
                    Text(
                      '+10',
                      style: TextStyle(
                        color: AppColors.textOnPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );

      case WorshipType.quantity:
      case WorshipType.duration:
        final current = record?.currentValue ?? 0;
        return InkWell(
          onTap: () => _showQuantityDialog(context, homeActions, current),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.15),
              border: Border.all(color: AppColors.gold),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.edit, size: 12, color: AppColors.goldDark),
                const SizedBox(width: 4),
                Text(
                  '$current',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.goldDark,
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }

  void _showQuantityDialog(BuildContext context, HomeActions homeActions, int initialValue) {
    final controller = TextEditingController(text: initialValue.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('تسجيل إنجاز: ${worship.name}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: worship.type == WorshipType.quantity ? 'عدد الصفحات' : 'عدد الدقائق',
            suffixText: worship.type == WorshipType.quantity ? 'صفحة' : 'دقيقة',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(controller.text) ?? 0;
              homeActions.updateQuantityWorship(worship, record, val);
              Navigator.pop(ctx);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}
