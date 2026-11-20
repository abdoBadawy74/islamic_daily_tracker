import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_daily_tracker/core/constants/app_constants.dart';
import 'package:islamic_daily_tracker/core/providers.dart';
import 'package:islamic_daily_tracker/core/theme/app_colors.dart';
import 'package:islamic_daily_tracker/core/utils/date_utils.dart';
import 'package:islamic_daily_tracker/core/widgets/app_card.dart';
import 'package:islamic_daily_tracker/data/models/daily_record.dart';
import 'package:islamic_daily_tracker/data/models/prayer_status.dart';
import 'package:islamic_daily_tracker/data/models/quran_progress.dart';
import 'package:islamic_daily_tracker/data/models/worship_model.dart';

final historySelectedDateProvider = StateProvider.autoDispose<DateTime>((ref) {
  return AppDateUtils.getDateOnly(DateTime.now());
});

final historyDatePrayersProvider =
    FutureProvider.autoDispose.family<List<PrayerStatus>, DateTime>((ref, date) async {
  final repo = ref.watch(prayerRepositoryProvider);
  final existing = await repo.getPrayersByDate(date);
  return AppConstants.prayerNames.map((name) {
    return existing.firstWhere(
      (p) => p.prayerName == name,
      orElse: () => PrayerStatus(
        id: '',
        prayerName: name,
        state: PrayerState.notRecorded,
        date: date,
      ),
    );
  }).toList();
});

final historyDateRecordsProvider =
    FutureProvider.autoDispose.family<List<DailyRecord>, DateTime>((ref, date) async {
  final repo = ref.watch(worshipRepositoryProvider);
  return repo.getRecordsByDate(date);
});

final historyDateQuranProvider =
    FutureProvider.autoDispose.family<QuranProgress?, DateTime>((ref, date) async {
  final repo = ref.watch(quranRepositoryProvider);
  return repo.getProgressByDate(date);
});

class CalendarHistoryScreen extends ConsumerWidget {
  const CalendarHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(historySelectedDateProvider);
    final prayersAsync = ref.watch(historyDatePrayersProvider(selectedDate));
    final recordsAsync = ref.watch(historyDateRecordsProvider(selectedDate));
    final quranAsync = ref.watch(historyDateQuranProvider(selectedDate));
    final worshipsAsync = ref.watch(worshipRepositoryProvider).getAllWorships(includeInactive: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل الأيام والتقويم'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            tooltip: 'اختر تاريخًا معينًا',
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: AppColors.primary,
                        onPrimary: Colors.white,
                        surface: AppColors.surface,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                ref.read(historySelectedDateProvider.notifier).state =
                    AppDateUtils.getDateOnly(picked);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Date Switcher Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              color: AppColors.primaryDark,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      ref.read(historySelectedDateProvider.notifier).state =
                          selectedDate.subtract(const Duration(days: 1));
                    },
                    icon: const Icon(Icons.chevron_right, color: Colors.white, size: 28),
                  ),
                  Column(
                    children: [
                      Text(
                        AppDateUtils.getDayName(selectedDate),
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppDateUtils.formatHijriDate(selectedDate),
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                      Text(
                        AppDateUtils.formatGregorianDate(selectedDate),
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      ref.read(historySelectedDateProvider.notifier).state =
                          selectedDate.add(const Duration(days: 1));
                    },
                    icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Prayers Status on this Day
            AppCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'الصلوات في هذا اليوم',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 10),
                  prayersAsync.when(
                    data: (prayers) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: prayers.map((p) {
                        return Column(
                          children: [
                            Icon(
                              _getPrayerIcon(p.state),
                              color: _getPrayerColor(p.state),
                              size: 24,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              p.prayerName,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _getPrayerLabel(p.state),
                              style: TextStyle(
                                fontSize: 9,
                                color: _getPrayerColor(p.state),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Text('خطأ: $err'),
                  ),
                ],
              ),
            ),

            // Quran on this Day
            AppCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ورد القرآن الكريم',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  quranAsync.when(
                    data: (quran) {
                      if (quran == null || quran.pagesRead == 0) {
                        return const Text(
                          'لم يتم تسجيل قراءة قرآن في هذا اليوم',
                          style: TextStyle(color: AppColors.textLight, fontSize: 12),
                        );
                      }
                      return Row(
                        children: [
                          const Icon(Icons.menu_book, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'تمت قراءة ${quran.pagesRead} ربع من أصل ${quran.dailyTarget} مستهدفة',
                            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                          ),
                          if (quran.lastSurahName != null) ...[
                            const SizedBox(width: 6),
                            Text(
                              '(سورة ${quran.lastSurahName})',
                              style: const TextStyle(fontSize: 12, color: AppColors.goldDark),
                            ),
                          ],
                        ],
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (err, _) => Text('خطأ: $err'),
                  ),
                ],
              ),
            ),

            // Worship Records List on this Day
            AppCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'سجل العبادات المنفذة',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<List<WorshipModel>>(
                    future: worshipsAsync,
                    builder: (context, worshipSnapshot) {
                      if (!worshipSnapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final worships = worshipSnapshot.data!;

                      return recordsAsync.when(
                        data: (records) {
                          if (records.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                'لم يتم تسجيل أي عبادات في هذا اليوم',
                                style: TextStyle(color: AppColors.textLight, fontSize: 12),
                              ),
                            );
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: worships.length,
                            itemBuilder: (context, index) {
                              final w = worships[index];
                              final rec = records.cast<DailyRecord?>().firstWhere(
                                (r) => r?.worshipId == w.id,
                                orElse: () => null,
                              );
                              final isDone = rec?.isGoalMet ?? false;

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Icon(
                                      isDone ? Icons.check_circle : Icons.circle_outlined,
                                      color: isDone ? AppColors.emerald : AppColors.textLight,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        w.name,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isDone ? AppColors.textPrimary : AppColors.textLight,
                                          fontWeight: isDone ? FontWeight.w600 : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    if (rec != null && w.type != WorshipType.boolean_)
                                      Text(
                                        '${rec.currentValue} / ${rec.targetValue}',
                                        style: const TextStyle(fontSize: 11, color: AppColors.emerald),
                                      ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        loading: () => const LinearProgressIndicator(),
                        error: (err, _) => Text('خطأ: $err'),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  IconData _getPrayerIcon(PrayerState state) {
    switch (state) {
      case PrayerState.onTime:
        return Icons.check_circle_rounded;
      case PrayerState.late_:
        return Icons.access_time_filled_rounded;
      case PrayerState.missed:
        return Icons.cancel_rounded;
      case PrayerState.notRecorded:
        return Icons.radio_button_unchecked_rounded;
    }
  }

  Color _getPrayerColor(PrayerState state) {
    switch (state) {
      case PrayerState.onTime:
        return AppColors.onTime;
      case PrayerState.late_:
        return AppColors.late_;
      case PrayerState.missed:
        return AppColors.missed;
      case PrayerState.notRecorded:
        return AppColors.notRecorded;
    }
  }

  String _getPrayerLabel(PrayerState state) {
    switch (state) {
      case PrayerState.onTime:
        return 'في وقتها';
      case PrayerState.late_:
        return 'متأخرة';
      case PrayerState.missed:
        return 'فائتة';
      case PrayerState.notRecorded:
        return 'غير مسجلة';
    }
  }
}
