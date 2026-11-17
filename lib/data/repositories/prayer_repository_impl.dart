import 'package:islamic_daily_tracker/data/datasources/local/prayer_local_datasource.dart';
import 'package:islamic_daily_tracker/data/models/prayer_status.dart';
import 'package:islamic_daily_tracker/domain/repositories/prayer_repository.dart';

class PrayerRepositoryImpl implements PrayerRepository {
  final PrayerLocalDatasource _datasource;

  PrayerRepositoryImpl(this._datasource);

  @override
  Future<List<PrayerStatus>> getPrayersByDate(DateTime date) {
    return _datasource.getPrayersByDate(date);
  }

  @override
  Future<void> savePrayerStatus(PrayerStatus status) {
    return _datasource.savePrayerStatus(status);
  }

  @override
  Future<List<PrayerStatus>> getPrayerStatsByDateRange(DateTime start, DateTime end) {
    return _datasource.getPrayerStatsByDateRange(start, end);
  }

  @override
  Future<Map<String, dynamic>> getPrayerStatistics(DateTime start, DateTime end) async {
    final list = await _datasource.getPrayerStatsByDateRange(start, end);
    int onTimeCount = 0;
    int lateCount = 0;
    int missedCount = 0;

    for (final p in list) {
      switch (p.state) {
        case PrayerState.onTime:
          onTimeCount++;
          break;
        case PrayerState.late_:
          lateCount++;
          break;
        case PrayerState.missed:
          missedCount++;
          break;
        case PrayerState.notRecorded:
          // We do not treat notRecorded as missed automatically or include in on-time % denominator
          break;
      }
    }

    final totalDueAndRecorded = onTimeCount + lateCount + missedCount;
    final double onTimePercentage = totalDueAndRecorded > 0
        ? (onTimeCount / totalDueAndRecorded) * 100
        : 0.0;

    return {
      'onTimeCount': onTimeCount,
      'lateCount': lateCount,
      'missedCount': missedCount,
      'totalRecorded': totalDueAndRecorded,
      'onTimePercentage': onTimePercentage,
    };
  }
}
