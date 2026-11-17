import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:islamic_daily_tracker/core/theme/app_colors.dart';
import 'package:islamic_daily_tracker/core/widgets/app_card.dart';
import 'package:islamic_daily_tracker/core/widgets/empty_state_widget.dart';
import 'package:islamic_daily_tracker/data/models/azkar_model.dart';
import 'package:islamic_daily_tracker/features/azkar/presentation/widgets/dhikr_counter_widget.dart';
import 'package:islamic_daily_tracker/features/azkar/providers/azkar_providers.dart';

class AzkarDetailScreen extends ConsumerStatefulWidget {
  final AzkarCategory category;

  const AzkarDetailScreen({super.key, required this.category});

  @override
  ConsumerState<AzkarDetailScreen> createState() => _AzkarDetailScreenState();
}

class _AzkarDetailScreenState extends ConsumerState<AzkarDetailScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(azkarItemsByCategoryProvider(widget.category.id));
    final progressAsync = ref.watch(categoryProgressProvider(widget.category.id));
    final actions = ref.read(azkarActionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt_rounded),
            tooltip: 'إعادة تصفير جميع أذكار هذا القسم',
            onPressed: () => _confirmResetCategory(actions),
          ),
        ],
      ),
      body: itemsAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const EmptyStateWidget(
              title: 'لا توجد أذكار في هذا القسم',
            );
          }

          if (_currentIndex >= items.length) {
            _currentIndex = items.length - 1;
          }

          final currentItem = items[_currentIndex];
          final progress = progressAsync.value ??
              const CategoryProgressSummary(totalItems: 0, completedItems: 0, percentage: 0);

          return Column(
            children: [
              // Category Overall Progress Bar at Top
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: AppColors.surface,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'إنجاز القسم: ${progress.completedItems} من ${items.length} ذكر',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${progress.percentage.toInt()}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearPercentIndicator(
                        lineHeight: 6.0,
                        percent: (progress.percentage / 100.0).clamp(0.0, 1.0),
                        padding: EdgeInsets.zero,
                        backgroundColor: AppColors.beigeDark.withValues(alpha: 0.5),
                        progressColor: AppColors.primary,
                        barRadius: const Radius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),

              // Main Content Scrollable
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Dhikr Arabic Text Card
                      AppCard(
                        margin: EdgeInsets.zero,
                        padding: const EdgeInsets.all(20),
                        backgroundColor: AppColors.cardBg,
                        child: Column(
                          children: [
                            // Dhikr number badge
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'الذكر ${_currentIndex + 1} من ${items.length}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                if (currentItem.isCompleted)
                                  const Row(
                                    children: [
                                      Icon(Icons.check_circle, color: AppColors.emerald, size: 16),
                                      SizedBox(width: 4),
                                      Text(
                                        'تم',
                                        style: TextStyle(
                                          color: AppColors.emerald,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Authentic Arabic text with elegant separation for Isti'adhah & Basmala
                            _buildDhikrBody(currentItem.text),

                            const SizedBox(height: 14),

                            // Source / Virtue
                            if (currentItem.source != null || currentItem.virtue != null) ...[
                              const Divider(height: 1),
                              const SizedBox(height: 10),
                              if (currentItem.source != null)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.menu_book, size: 13, color: AppColors.goldDark),
                                    const SizedBox(width: 4),
                                    Text(
                                      'المصدر: ${currentItem.source!}',
                                      style: const TextStyle(fontSize: 11, color: AppColors.goldDark),
                                    ),
                                  ],
                                ),
                              if (currentItem.virtue != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  currentItem.virtue!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Interactive Counter Widget
                      DhikrCounterWidget(
                        item: currentItem,
                        onIncrement: () {
                          actions.incrementDhikr(currentItem, widget.category.id);
                        },
                        onReset: () {
                          actions.resetDhikr(currentItem, widget.category.id);
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Navigation Controls between items
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: const BoxDecoration(
                  color: AppColors.cardBg,
                  border: Border(top: BorderSide(color: AppColors.beigeDark)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Previous Dhikr Button
                    ElevatedButton.icon(
                      onPressed: _currentIndex > 0
                          ? () => setState(() => _currentIndex--)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.surface,
                        foregroundColor: AppColors.textPrimary,
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.arrow_forward_ios, size: 14),
                      label: const Text('السابق'),
                    ),

                    // Quick Jump Dots / Indicators
                    Text(
                      '${_currentIndex + 1} / ${items.length}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),

                    // Next Dhikr Button
                    ElevatedButton.icon(
                      onPressed: _currentIndex < items.length - 1
                          ? () => setState(() => _currentIndex++)
                          : null,
                      icon: const Icon(Icons.arrow_back_ios, size: 14),
                      label: const Text('التالي'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('خطأ: $err')),
      ),
    );
  }

  Widget _buildDhikrBody(String rawText) {
    final parts = rawText
        .split('\n\n')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    if (parts.length <= 1) {
      return Text(
        rawText,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          height: 1.85,
          color: AppColors.textPrimary,
        ),
      );
    }

    return Column(
      children: parts.map((part) {
        final isIstiadha = part.contains('أَعُوذُ بِاللهِ مِنَ الشَّيْطَانِ الرَّجِيمِ');
        final isBasmala = part.contains('بِسْمِ اللهِ الرَّحْمَٰنِ الرَّحِيمِ');

        if (isIstiadha) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Text(
              part,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
          );
        }

        if (isBasmala) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Text(
              part,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            part,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              height: 1.85,
              color: AppColors.textPrimary,
            ),
          ),
        );
      }).toList(),
    );
  }

  void _confirmResetCategory(AzkarActions actions) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إعادة تصفير العدادات'),
        content: Text('هل ترغب في إعادة تصفير جميع عدادات أذكار "${widget.category.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              actions.resetCategory(widget.category.id);
              Navigator.pop(ctx);
            },
            child: const Text('تصفير'),
          ),
        ],
      ),
    );
  }
}
