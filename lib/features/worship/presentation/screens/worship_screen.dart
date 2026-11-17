import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_daily_tracker/core/theme/app_colors.dart';
import 'package:islamic_daily_tracker/core/utils/worship_icons.dart';
import 'package:islamic_daily_tracker/core/widgets/app_card.dart';
import 'package:islamic_daily_tracker/core/widgets/empty_state_widget.dart';
import 'package:islamic_daily_tracker/data/models/worship_model.dart';
import 'package:islamic_daily_tracker/features/worship/presentation/widgets/add_edit_worship_dialog.dart';
import 'package:islamic_daily_tracker/features/worship/presentation/widgets/worship_type_badge.dart';
import 'package:islamic_daily_tracker/features/worship/providers/worship_providers.dart';

class WorshipScreen extends ConsumerWidget {
  const WorshipScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredWorships = ref.watch(filteredWorshipsProvider);
    final allAsync = ref.watch(allWorshipsProvider);
    final selectedCat = ref.watch(selectedWorshipCategoryProvider);
    final controller = ref.read(worshipControllerProvider);

    final categories = [
      {'id': null, 'label': 'الكل'},
      {'id': 'prayer', 'label': 'الصلاة'},
      {'id': 'fasting', 'label': 'الصيام'},
      {'id': 'quran', 'label': 'القرآن'},
      {'id': 'azkar', 'label': 'الأذكار'},
      {'id': 'charity', 'label': 'الصدقة'},
      {'id': 'knowledge', 'label': 'العلم'},
      {'id': 'general', 'label': 'عادات'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة العبادات والعادات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, size: 26),
            tooltip: 'إضافة عبادة جديدة',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const AddEditWorshipDialog(),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const AddEditWorshipDialog(),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: AppColors.textOnPrimary),
        label: const Text(
          'إضافة عبادة',
          style: TextStyle(color: AppColors.textOnPrimary, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Category Filter Chips Row
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = selectedCat == cat['id'];

                return Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: FilterChip(
                    label: Text(cat['label'] as String),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    backgroundColor: AppColors.surface,
                    checkmarkColor: AppColors.textOnPrimary,
                    onSelected: (_) {
                      ref.read(selectedWorshipCategoryProvider.notifier).state =
                          cat['id'];
                    },
                  ),
                );
              },
            ),
          ),

          // Worship List
          Expanded(
            child: allAsync.when(
              data: (_) {
                if (filteredWorships.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.checklist_rtl_rounded,
                    title: 'لا توجد عبادات في هذا التصنيف',
                    subtitle: 'يمكنك إضافة عبادة جديدة بالضغط على زر الإضافة بالأسفل',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 6, bottom: 80),
                  itemCount: filteredWorships.length,
                  itemBuilder: (context, index) {
                    final worship = filteredWorships[index];
                    final catColor = WorshipIcons.getCategoryColor(worship.category);
                    final iconData = WorshipIcons.getIcon(worship.iconName);

                    return AppCard(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          // Category Icon
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: catColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(iconData, color: catColor, size: 24),
                          ),
                          const SizedBox(width: 12),

                          // Worship Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        worship.name,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: worship.isActive
                                              ? AppColors.textPrimary
                                              : AppColors.textLight,
                                          decoration: worship.isActive
                                              ? null
                                              : TextDecoration.lineThrough,
                                        ),
                                      ),
                                    ),
                                    if (worship.isRamadanOnly)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.gold.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'رمضان',
                                          style: TextStyle(
                                            fontSize: 9,
                                            color: AppColors.goldDark,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    WorshipTypeBadge(type: worship.type),
                                    if (worship.target != null &&
                                        worship.type != WorshipType.boolean_) ...[
                                      const SizedBox(width: 8),
                                      Text(
                                        'الهدف: ${worship.target}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Actions: Active Switch & Menu
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: worship.isActive,
                                activeThumbColor: AppColors.primary,
                                onChanged: (_) => controller.toggleActive(worship),
                              ),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert, color: AppColors.textLight),
                                onSelected: (val) {
                                  if (val == 'edit') {
                                    showDialog(
                                      context: context,
                                      builder: (_) =>
                                          AddEditWorshipDialog(worshipToEdit: worship),
                                    );
                                  } else if (val == 'delete') {
                                    _confirmDelete(context, controller, worship);
                                  }
                                },
                                itemBuilder: (ctx) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit_outlined, size: 18),
                                        SizedBox(width: 8),
                                        Text('تعديل'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete_outline, color: AppColors.error, size: 18),
                                        SizedBox(width: 8),
                                        Text('حذف', style: TextStyle(color: AppColors.error)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('خطأ: $err')),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WorshipController controller, WorshipModel worship) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف العبادة'),
        content: Text('هل أنت متأكد من رغبتك في حذف "${worship.name}" وجميع سجلاتها السابقة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              controller.deleteWorship(worship.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حذف العبادة')),
              );
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
