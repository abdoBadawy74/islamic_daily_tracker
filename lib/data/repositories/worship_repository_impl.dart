import 'package:islamic_daily_tracker/data/datasources/local/worship_local_datasource.dart';
import 'package:islamic_daily_tracker/data/models/worship_model.dart';
import 'package:islamic_daily_tracker/data/models/daily_record.dart';
import 'package:islamic_daily_tracker/domain/repositories/worship_repository.dart';

class WorshipRepositoryImpl implements WorshipRepository {
  final WorshipLocalDatasource _datasource;

  WorshipRepositoryImpl(this._datasource);

  @override
  Future<List<WorshipModel>> getAllWorships({bool includeInactive = false, bool includeRamadan = false}) {
    return _datasource.getAllWorships(
      includeInactive: includeInactive,
      includeRamadan: includeRamadan,
    );
  }

  @override
  Future<void> addWorship(WorshipModel worship) {
    return _datasource.addWorship(worship);
  }

  @override
  Future<void> updateWorship(WorshipModel worship) {
    return _datasource.updateWorship(worship);
  }

  @override
  Future<void> deleteWorship(String id) {
    return _datasource.deleteWorship(id);
  }

  @override
  Future<List<DailyRecord>> getRecordsByDate(DateTime date) {
    return _datasource.getRecordsByDate(date);
  }

  @override
  Future<void> saveRecord(DailyRecord record) {
    return _datasource.saveRecord(record);
  }

  @override
  Future<List<DailyRecord>> getRecordsByDateRange(DateTime start, DateTime end) {
    return _datasource.getRecordsByDateRange(start, end);
  }
}
