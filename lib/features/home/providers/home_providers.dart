import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_daily_tracker/core/constants/app_constants.dart';
import 'package:islamic_daily_tracker/core/providers.dart';
import 'package:islamic_daily_tracker/core/utils/date_utils.dart';
import 'package:islamic_daily_tracker/data/models/prayer_status.dart';
import 'package:islamic_daily_tracker/data/models/worship_model.dart';
import 'package:islamic_daily_tracker/data/models/daily_record.dart';
import 'package:islamic_daily_tracker/data/models/app_settings.dart';
import 'package:uuid/uuid.dart';

// Selected Date State
final selectedDateProvider = StateProvider<DateTime>((ref) {
  return AppDateUtils.getDateOnly(DateTime.now());
});

// App Settings Provider
final appSettingsProvider = FutureProvider<AppSettings>((ref) async {
  final repo = ref.watch(settingsRepositoryProvider);
  return repo.getSettings();
});

// Prayers for Selected Date
final dailyPrayersProvider = FutureProvider.autoDispose<List<PrayerStatus>>((ref) async {
  final date = ref.watch(selectedDateProvider);
  final repo = ref.watch(prayerRepositoryProvider);
  final existing = await repo.getPrayersByDate(date);

  // Return standard 5 prayers, matching recorded or returning notRecorded
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

// Active Worships (including Ramadan if Ramadan mode enabled)
final activeWorshipsProvider = FutureProvider.autoDispose<List<WorshipModel>>((ref) async {
  final repo = ref.watch(worshipRepositoryProvider);
  final settings = await ref.watch(appSettingsProvider.future);
  return repo.getAllWorships(
    includeInactive: false,
    includeRamadan: settings.isRamadanMode,
  );
});

// Daily Records for Selected Date
final dailyRecordsProvider = FutureProvider.autoDispose<List<DailyRecord>>((ref) async {
  final date = ref.watch(selectedDateProvider);
  final repo = ref.watch(worshipRepositoryProvider);
  return repo.getRecordsByDate(date);
});

// Daily Completion Progress Calculator
class DailyProgressSummary {
  final int totalCount;
  final int completedCount;
  final double percentage;

  const DailyProgressSummary({
    required this.totalCount,
    required this.completedCount,
    required this.percentage,
  });
}

final dailyProgressProvider = Provider.autoDispose<DailyProgressSummary>((ref) {
  final worshipsAsync = ref.watch(activeWorshipsProvider);
  final recordsAsync = ref.watch(dailyRecordsProvider);

  final worships = worshipsAsync.value ?? [];
  final records = recordsAsync.value ?? [];

  if (worships.isEmpty) {
    return const DailyProgressSummary(totalCount: 0, completedCount: 0, percentage: 0.0);
  }

  int completed = 0;
  for (final w in worships) {
    final record = records.firstWhere(
      (r) => r.worshipId == w.id,
      orElse: () => DailyRecord(id: '', worshipId: w.id, date: DateTime.now()),
    );
    if (record.isGoalMet) {
      completed++;
    }
  }

  final double pct = (completed / worships.length) * 100.0;
  return DailyProgressSummary(
    totalCount: worships.length,
    completedCount: completed,
    percentage: pct.clamp(0.0, 100.0),
  );
});

// Action Handlers
class HomeActions {
  final Ref _ref;
  final _uuid = const Uuid();

  HomeActions(this._ref);

  Future<void> cyclePrayerStatus(PrayerStatus current) async {
    final repo = _ref.read(prayerRepositoryProvider);
    final date = _ref.read(selectedDateProvider);

    PrayerState nextState;
    switch (current.state) {
      case PrayerState.notRecorded:
        nextState = PrayerState.onTime;
        break;
      case PrayerState.onTime:
        nextState = PrayerState.late_;
        break;
      case PrayerState.late_:
        nextState = PrayerState.missed;
        break;
      case PrayerState.missed:
        nextState = PrayerState.notRecorded;
        break;
    }

    final newStatus = current.copyWith(
      id: current.id.isEmpty ? _uuid.v4() : current.id,
      state: nextState,
      date: date,
    );

    await repo.savePrayerStatus(newStatus);
    _ref.invalidate(dailyPrayersProvider);
  }

  Future<void> toggleBooleanWorship(WorshipModel worship, DailyRecord? currentRecord) async {
    final repo = _ref.read(worshipRepositoryProvider);
    final date = _ref.read(selectedDateProvider);
    final isDone = !(currentRecord?.isCompleted ?? false);

    final record = (currentRecord ?? DailyRecord(
      id: _uuid.v4(),
      worshipId: worship.id,
      date: date,
      targetValue: 1,
    )).copyWith(
      isCompleted: isDone,
      currentValue: isDone ? 1 : 0,
      targetValue: 1,
    );

    await repo.saveRecord(record);
    _ref.invalidate(dailyRecordsProvider);
  }

  Future<void> incrementCounterWorship(WorshipModel worship, DailyRecord? currentRecord, {int delta = 1}) async {
    final repo = _ref.read(worshipRepositoryProvider);
    final date = _ref.read(selectedDateProvider);
    final target = worship.target ?? 100;
    final currentVal = (currentRecord?.currentValue ?? 0) + delta;
    final newVal = currentVal < 0 ? 0 : currentVal;

    final record = (currentRecord ?? DailyRecord(
      id: _uuid.v4(),
      worshipId: worship.id,
      date: date,
      targetValue: target,
    )).copyWith(
      currentValue: newVal,
      targetValue: target,
      isCompleted: newVal >= target,
    );

    await repo.saveRecord(record);
    _ref.invalidate(dailyRecordsProvider);
  }

  Future<void> updateQuantityWorship(WorshipModel worship, DailyRecord? currentRecord, int value) async {
    final repo = _ref.read(worshipRepositoryProvider);
    final date = _ref.read(selectedDateProvider);
    final target = worship.target ?? 20;

    final record = (currentRecord ?? DailyRecord(
      id: _uuid.v4(),
      worshipId: worship.id,
      date: date,
      targetValue: target,
    )).copyWith(
      currentValue: value,
      targetValue: target,
      isCompleted: value >= target,
    );

    await repo.saveRecord(record);
    _ref.invalidate(dailyRecordsProvider);
  }
}

final homeActionsProvider = Provider<HomeActions>((ref) {
  return HomeActions(ref);
});
