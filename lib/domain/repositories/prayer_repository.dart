import 'package:islamic_daily_tracker/data/models/prayer_status.dart';

abstract class PrayerRepository {
  Future<List<PrayerStatus>> getPrayersByDate(DateTime date);
  Future<void> savePrayerStatus(PrayerStatus status);
  Future<List<PrayerStatus>> getPrayerStatsByDateRange(DateTime start, DateTime end);
  Future<Map<String, dynamic>> getPrayerStatistics(DateTime start, DateTime end);
}
