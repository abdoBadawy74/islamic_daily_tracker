import 'package:islamic_daily_tracker/data/models/worship_model.dart';
import 'package:islamic_daily_tracker/data/models/daily_record.dart';

abstract class WorshipRepository {
  Future<List<WorshipModel>> getAllWorships({bool includeInactive = false, bool includeRamadan = false});
  Future<void> addWorship(WorshipModel worship);
  Future<void> updateWorship(WorshipModel worship);
  Future<void> deleteWorship(String id);
  Future<List<DailyRecord>> getRecordsByDate(DateTime date);
  Future<void> saveRecord(DailyRecord record);
  Future<List<DailyRecord>> getRecordsByDateRange(DateTime start, DateTime end);
}
