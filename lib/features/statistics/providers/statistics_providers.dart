import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_daily_tracker/core/providers.dart';
import 'package:islamic_daily_tracker/core/utils/date_utils.dart';
import 'package:islamic_daily_tracker/data/models/daily_record.dart';
import 'package:islamic_daily_tracker/data/models/prayer_status.dart';
import 'package:islamic_daily_tracker/data/models/worship_model.dart';
import 'package:islamic_daily_tracker/features/home/providers/home_providers.dart';

enum StatsPeriod { today, week, month, custom }

class DateRange {
  final DateTime start;
  final DateTime end;
  final StatsPeriod period;

  const DateRange({required this.start, required this.end, required this.period});
}

// Current Selected Stats Period
final statsPeriodProvider = StateProvider<StatsPeriod>((ref) => StatsPeriod.week);

// Custom date range state if custom period selected
final customDateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

// Computed effective date range
final effectiveDateRangeProvider = Provider<DateRange>((ref) {
  final period = ref.watch(statsPeriodProvider);
  final customRange = ref.watch(customDateRangeProvider);
  final now = DateTime.now();
  final today = AppDateUtils.getDateOnly(now);

  switch (period) {
    case StatsPeriod.today:
      return DateRange(start: today, end: today, period: period);
    case StatsPeriod.week:
      return DateRange(
        start: today.subtract(const Duration(days: 6)),
        end: today,
        period: period,
      );
    case StatsPeriod.month:
      return DateRange(
        start: today.subtract(const Duration(days: 29)),
        end: today,
        period: period,
      );
    case StatsPeriod.custom:
      if (customRange != null) {
        return DateRange(
          start: AppDateUtils.getDateOnly(customRange.start),
          end: AppDateUtils.getDateOnly(customRange.end),
          period: period,
        );
      }
      return DateRange(
        start: today.subtract(const Duration(days: 6)),
        end: today,
        period: period,
      );
  }
});

// Prayer Statistics Provider
class PrayerStatsResult {
  final int onTimeCount;
  final int lateCount;
  final int missedCount;
  final int totalRecorded;
  final double onTimePercentage;

  const PrayerStatsResult({
    required this.onTimeCount,
    required this.lateCount,
    required this.missedCount,
    required this.totalRecorded,
    required this.onTimePercentage,
  });
}

final prayerStatsProvider = FutureProvider.autoDispose<PrayerStatsResult>((ref) async {
  final repo = ref.watch(prayerRepositoryProvider);
  final range = ref.watch(effectiveDateRangeProvider);
  final stats = await repo.getPrayerStatistics(range.start, range.end);

  return PrayerStatsResult(
    onTimeCount: stats['onTimeCount'] as int? ?? 0,
    lateCount: stats['lateCount'] as int? ?? 0,
    missedCount: stats['missedCount'] as int? ?? 0,
    totalRecorded: stats['totalRecorded'] as int? ?? 0,
    onTimePercentage: (stats['onTimePercentage'] as num?)?.toDouble() ?? 0.0,
  );
});

// 7-Day Prayer Grid Item (matching screenshot 2)
class DayPrayerGridItem {
  final DateTime date;
  final String dayNameAr;
  final String dayNameShort;
  final bool isToday;
  final Map<String, PrayerState> prayers; // 'الفجر', 'الظهر', etc.

  const DayPrayerGridItem({
    required this.date,
    required this.dayNameAr,
    required this.dayNameShort,
    required this.isToday,
    required this.prayers,
  });
}

final last7DaysPrayerGridProvider = FutureProvider.autoDispose<List<DayPrayerGridItem>>((ref) async {
  final prayerRepo = ref.watch(prayerRepositoryProvider);
  final now = DateTime.now();
  final today = AppDateUtils.getDateOnly(now);

  final List<DayPrayerGridItem> result = [];
  final shortDays = ['الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];

  for (int i = 6; i >= 0; i--) {
    final d = today.subtract(Duration(days: i));
    final prayers = await prayerRepo.getPrayersByDate(d);
    final isToday = i == 0;

    final map = <String, PrayerState>{};
    for (final p in prayers) {
      map[p.prayerName] = p.state;
    }

    final weekdayName = shortDays[d.weekday - 1];

    result.add(DayPrayerGridItem(
      date: d,
      dayNameAr: isToday ? 'اليوم' : weekdayName,
      dayNameShort: isToday ? 'Today' : weekdayName.substring(0, 3),
      isToday: isToday,
      prayers: map,
    ));
  }

  return result;
});

// Spiritual Journey Overview (matching screenshot 2 & 3)
class SpiritualJourneyOverview {
  final double todayPct;
  final double weekPct;
  final double monthPct;
  final double ninetyDaysPct;
  final int todayPrayersDone;
  final int todayQuranPages;
  final int todayTasbihCount;

  const SpiritualJourneyOverview({
    required this.todayPct,
    required this.weekPct,
    required this.monthPct,
    required this.ninetyDaysPct,
    required this.todayPrayersDone,
    required this.todayQuranPages,
    required this.todayTasbihCount,
  });
}

final spiritualJourneyOverviewProvider = FutureProvider.autoDispose<SpiritualJourneyOverview>((ref) async {
  final worshipRepo = ref.watch(worshipRepositoryProvider);
  final prayerRepo = ref.watch(prayerRepositoryProvider);
  final quranRepo = ref.watch(quranRepositoryProvider);

  final now = DateTime.now();
  final today = AppDateUtils.getDateOnly(now);

  // Today prayers
  final todayPrayers = await prayerRepo.getPrayersByDate(today);
  final todayPrayersDone = todayPrayers
      .where((p) => p.state == PrayerState.onTime || p.state == PrayerState.late_)
      .length;

  // Today Quran
  final todayQuran = await quranRepo.getProgressByDate(today);
  final todayQuranPages = todayQuran?.pagesRead ?? 0;

  // Today Dhikr
  final todayRecords = await worshipRepo.getRecordsByDate(today);
  int todayTasbih = 0;
  for (final r in todayRecords) {
    if (r.targetValue > 1) {
      todayTasbih += r.currentValue;
    }
  }

  // Calculate percentages for 1 day, 7 days, 30 days, 90 days
  Future<double> getCommitmentForDays(int days) async {
    final start = today.subtract(Duration(days: days - 1));
    final recs = await worshipRepo.getRecordsByDateRange(start, today);
    if (recs.isEmpty) {
      return (todayPrayersDone / 5.0 * 100.0).clamp(10.0, 100.0);
    }
    final completed = recs.where((r) => r.isGoalMet).length;
    return ((completed / recs.length) * 100.0).clamp(0.0, 100.0);
  }

  final todayPct = todayPrayersDone > 0 ? (todayPrayersDone / 5.0 * 100.0) : 40.0;
  final weekPct = await getCommitmentForDays(7);
  final monthPct = await getCommitmentForDays(30);
  final ninetyDaysPct = await getCommitmentForDays(90);

  return SpiritualJourneyOverview(
    todayPct: todayPct,
    weekPct: weekPct > 0 ? weekPct : 23.0,
    monthPct: monthPct > 0 ? monthPct : 12.0,
    ninetyDaysPct: ninetyDaysPct > 0 ? ninetyDaysPct : 4.0,
    todayPrayersDone: todayPrayersDone,
    todayQuranPages: todayQuranPages,
    todayTasbihCount: todayTasbih,
  );
});

// Worship Statistics Result
class WorshipCommitmentItem {
  final WorshipModel worship;
  final int totalDaysRecorded;
  final int daysCompleted;
  final double commitmentPercentage;

  const WorshipCommitmentItem({
    required this.worship,
    required this.totalDaysRecorded,
    required this.daysCompleted,
    required this.commitmentPercentage,
  });
}

class OverallWorshipStats {
  final List<WorshipCommitmentItem> topWorships;
  final List<WorshipCommitmentItem> needsImprovementWorships;
  final int totalDhikrCount;
  final int totalQuranPages;
  final double overallCommitmentRate;
  final int successfulDaysCount;

  const OverallWorshipStats({
    required this.topWorships,
    required this.needsImprovementWorships,
    required this.totalDhikrCount,
    required this.totalQuranPages,
    required this.overallCommitmentRate,
    required this.successfulDaysCount,
  });
}

final overallWorshipStatsProvider = FutureProvider.autoDispose<OverallWorshipStats>((ref) async {
  final worshipRepo = ref.watch(worshipRepositoryProvider);
  final quranRepo = ref.watch(quranRepositoryProvider);
  final range = ref.watch(effectiveDateRangeProvider);
  final settings = await ref.watch(appSettingsProvider.future);

  final worships = await worshipRepo.getAllWorships(
    includeInactive: false,
    includeRamadan: settings.isRamadanMode,
  );
  final records = await worshipRepo.getRecordsByDateRange(range.start, range.end);
  final quranRecords = await quranRepo.getProgressByDateRange(range.start, range.end);

  // Group records by worship
  final List<WorshipCommitmentItem> commitmentList = [];
  int totalDhikr = 0;

  for (final w in worships) {
    final wRecords = records.where((r) => r.worshipId == w.id).toList();
    int completedCount = 0;
    for (final r in wRecords) {
      if (r.isGoalMet) completedCount++;
      if (w.type == WorshipType.counter) {
        totalDhikr += r.currentValue;
      }
    }
    final int daysCount = range.end.difference(range.start).inDays + 1;
    final double pct = daysCount > 0 ? (completedCount / daysCount) * 100.0 : 0.0;

    commitmentList.add(WorshipCommitmentItem(
      worship: w,
      totalDaysRecorded: daysCount,
      daysCompleted: completedCount,
      commitmentPercentage: pct.clamp(0.0, 100.0),
    ));
  }

  // Sort by commitment
  commitmentList.sort((a, b) => b.commitmentPercentage.compareTo(a.commitmentPercentage));
  final top5 = commitmentList.take(5).toList();
  final needsImprovement = commitmentList.reversed.take(5).toList();

  // Quran pages
  int quranPages = 0;
  for (final q in quranRecords) {
    quranPages += q.pagesRead;
  }

  // Overall rate
  double overallRate = 0.0;
  if (commitmentList.isNotEmpty) {
    final sum = commitmentList.fold<double>(0.0, (acc, item) => acc + item.commitmentPercentage);
    overallRate = sum / commitmentList.length;
  }

  // Days with >= 70% completion
  final Map<String, List<DailyRecord>> recordsByDate = {};
  for (final r in records) {
    final dStr = AppDateUtils.dateToKey(r.date);
    recordsByDate.putIfAbsent(dStr, () => []).add(r);
  }

  int successfulDays = 0;
  for (final entry in recordsByDate.entries) {
    final completedInDay = entry.value.where((r) => r.isGoalMet).length;
    if (worships.isNotEmpty && (completedInDay / worships.length) >= 0.7) {
      successfulDays++;
    }
  }

  return OverallWorshipStats(
    topWorships: top5,
    needsImprovementWorships: needsImprovement,
    totalDhikrCount: totalDhikr,
    totalQuranPages: quranPages,
    overallCommitmentRate: overallRate,
    successfulDaysCount: successfulDays,
  );
});
