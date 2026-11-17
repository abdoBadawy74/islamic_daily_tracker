import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_daily_tracker/data/datasources/local/database_helper.dart';
import 'package:islamic_daily_tracker/data/datasources/local/prayer_local_datasource.dart';
import 'package:islamic_daily_tracker/data/datasources/local/worship_local_datasource.dart';
import 'package:islamic_daily_tracker/data/datasources/local/quran_local_datasource.dart';
import 'package:islamic_daily_tracker/data/datasources/local/azkar_local_datasource.dart';
import 'package:islamic_daily_tracker/data/datasources/local/settings_local_datasource.dart';
import 'package:islamic_daily_tracker/data/repositories/prayer_repository_impl.dart';
import 'package:islamic_daily_tracker/data/repositories/worship_repository_impl.dart';
import 'package:islamic_daily_tracker/data/repositories/quran_repository_impl.dart';
import 'package:islamic_daily_tracker/data/repositories/azkar_repository_impl.dart';
import 'package:islamic_daily_tracker/data/repositories/settings_repository_impl.dart';
import 'package:islamic_daily_tracker/domain/repositories/prayer_repository.dart';
import 'package:islamic_daily_tracker/domain/repositories/worship_repository.dart';
import 'package:islamic_daily_tracker/domain/repositories/quran_repository.dart';
import 'package:islamic_daily_tracker/domain/repositories/azkar_repository.dart';
import 'package:islamic_daily_tracker/domain/repositories/settings_repository.dart';

// Database Helper
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

// Datasources
final prayerDatasourceProvider = Provider<PrayerLocalDatasource>((ref) {
  return PrayerLocalDatasource(ref.watch(databaseHelperProvider));
});

final worshipDatasourceProvider = Provider<WorshipLocalDatasource>((ref) {
  return WorshipLocalDatasource(ref.watch(databaseHelperProvider));
});

final quranDatasourceProvider = Provider<QuranLocalDatasource>((ref) {
  return QuranLocalDatasource(ref.watch(databaseHelperProvider));
});

final azkarDatasourceProvider = Provider<AzkarLocalDatasource>((ref) {
  return AzkarLocalDatasource(ref.watch(databaseHelperProvider));
});

final settingsDatasourceProvider = Provider<SettingsLocalDatasource>((ref) {
  return SettingsLocalDatasource(ref.watch(databaseHelperProvider));
});

// Repositories
final prayerRepositoryProvider = Provider<PrayerRepository>((ref) {
  return PrayerRepositoryImpl(ref.watch(prayerDatasourceProvider));
});

final worshipRepositoryProvider = Provider<WorshipRepository>((ref) {
  return WorshipRepositoryImpl(ref.watch(worshipDatasourceProvider));
});

final quranRepositoryProvider = Provider<QuranRepository>((ref) {
  return QuranRepositoryImpl(ref.watch(quranDatasourceProvider));
});

final azkarRepositoryProvider = Provider<AzkarRepository>((ref) {
  return AzkarRepositoryImpl(ref.watch(azkarDatasourceProvider));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(ref.watch(settingsDatasourceProvider));
});
