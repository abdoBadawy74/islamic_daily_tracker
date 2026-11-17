import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_daily_tracker/core/theme/app_colors.dart';
import 'package:islamic_daily_tracker/core/utils/date_utils.dart';
import 'package:islamic_daily_tracker/core/widgets/app_card.dart';
import 'package:islamic_daily_tracker/core/widgets/empty_state_widget.dart';
import 'package:islamic_daily_tracker/features/quran/providers/quran_providers.dart';

class QuranHistoryScreen extends ConsumerWidget {
  const QuranHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(quranHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل قراءة القرآن الكريم'),
      ),
      body: historyAsync.when(
        data: (records) {
          if (records.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.history_rounded,
              title: 'لا يوجد سجل قراءة بعد',
              subtitle: 'سجّل وردك اليومي من صفحة القرآن لترى إنجازاتك هنا',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final rec = records[index];
              return AppCard(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.menu_book, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppDateUtils.formatGregorianDate(rec.date),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.emerald.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${rec.pagesRead} صفحة',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: AppColors.emerald,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          if (rec.lastSurahName != null)
                            Text(
                              'سورة ${rec.lastSurahName} ${rec.ayahNumber != null ? "(آية ${rec.ayahNumber})" : ""}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          if (rec.notes != null && rec.notes!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              rec.notes!,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textLight,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
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
    );
  }
}
