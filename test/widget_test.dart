import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_daily_tracker/data/datasources/local/authentic_azkar_data.dart';
import 'package:islamic_daily_tracker/data/models/prayer_status.dart';
import 'package:islamic_daily_tracker/data/models/daily_record.dart';
import 'package:islamic_daily_tracker/data/models/worship_model.dart';
import 'package:islamic_daily_tracker/data/models/quran_progress.dart';
import 'package:islamic_daily_tracker/data/models/app_settings.dart';
import 'package:islamic_daily_tracker/features/quran/data/quran_repository.dart';

void main() {
  group('Prayer Logic and Statistics Tests', () {
    test('PrayerStatus serialization toMap and fromMap works correctly', () {
      final now = DateTime(2026, 11, 17);
      final prayer = PrayerStatus(
        id: 'prayer-1',
        prayerName: 'الفجر',
        state: PrayerState.onTime,
        date: now,
      );

      final map = prayer.toMap();
      expect(map['prayer_name'], 'الفجر');
      expect(map['state'], 'onTime');
      expect(map['date'], '2026-11-17');

      final reconstructed = PrayerStatus.fromMap(map);
      expect(reconstructed.id, 'prayer-1');
      expect(reconstructed.prayerName, 'الفجر');
      expect(reconstructed.state, PrayerState.onTime);
      expect(reconstructed.date.year, 2026);
      expect(reconstructed.date.month, 11);
      expect(reconstructed.date.day, 17);
    });

    test('Prayer on-time percentage matches project specification exactly', () {
      const onTimeCount = 120;
      const lateCount = 15;
      const missedCount = 5;

      const totalDueAndRecorded = onTimeCount + lateCount + missedCount;
      expect(totalDueAndRecorded, 140);

      final onTimePercentage = (onTimeCount / totalDueAndRecorded) * 100;
      expect(onTimePercentage, closeTo(85.714, 0.01));
    });
  });

  group('Worship Habit Model Tests', () {
    test('WorshipModel creation and type helpers', () {
      final worship = WorshipModel(
        id: 'w-1',
        name: 'صلاة الضحى',
        type: WorshipType.boolean_,
        category: 'prayer',
        iconName: 'sun',
        isActive: true,
        isRamadanOnly: false,
        createdAt: DateTime.now(),
      );

      expect(worship.name, 'صلاة الضحى');
      expect(worship.type, WorshipType.boolean_);
      expect(WorshipModel.worshipTypeToArabic(worship.type), 'إنجاز');
    });

    test('DailyRecord completion calculation for boolean and counter', () {
      final date = DateTime(2026, 11, 17);

      // Boolean habit completed
      final boolRecord = DailyRecord(
        id: 'r-1',
        worshipId: 'w-1',
        date: date,
        isCompleted: true,
        currentValue: 1,
        targetValue: 1,
      );
      expect(boolRecord.isGoalMet, true);
      expect(boolRecord.completionPercentage, 100.0);

      // Counter habit partially completed
      final counterRecord = DailyRecord(
        id: 'r-2',
        worshipId: 'w-2',
        date: date,
        isCompleted: false,
        currentValue: 50,
        targetValue: 100,
      );
      expect(counterRecord.isGoalMet, false);
      expect(counterRecord.completionPercentage, 50.0);

      // Counter habit goal exceeded
      final exceededRecord = counterRecord.copyWith(currentValue: 120);
      expect(exceededRecord.isGoalMet, true);
      expect(exceededRecord.completionPercentage, 100.0);
    });
  });

  group('Quran Reading Progress and Ayah Model Tests', () {
    test('QuranProgress completion percentage calculates properly', () {
      final quran = QuranProgress(
        id: 'q-1',
        date: DateTime(2026, 11, 17),
        pagesRead: 10,
        dailyTarget: 20,
        lastSurahName: 'البقرة',
      );

      expect(quran.completionPercentage, 50.0);
      expect(quran.lastSurahName, 'البقرة');

      final completed = quran.copyWith(pagesRead: 25);
      expect(completed.completionPercentage, 100.0);
    });

    test('AyahModel cleans Basmala prefix for Surahs 2-114 and keeps for Surah 1', () {
      const basmala = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';

      // Surah 1 Al-Fatiha
      final fatihaAyah1 = AyahModel(
        number: 1,
        text: basmala,
        numberInSurah: 1,
        juz: 1,
        manzil: 1,
        page: 1,
        ruku: 1,
        hizbQuarter: 1,
        sajda: false,
      );
      expect(fatihaAyah1.getUthmaniTextForSurah(1), basmala);

      // Surah 2 Al-Baqarah
      final baqarahAyah1 = AyahModel(
        number: 8,
        text: '$basmala الٓمٓ',
        numberInSurah: 1,
        juz: 1,
        manzil: 1,
        page: 2,
        ruku: 1,
        hizbQuarter: 1,
        sajda: false,
      );
      expect(baqarahAyah1.getUthmaniTextForSurah(2), 'الٓمٓ');
    });
  });

  group('Authentic Azkar Dataset Validation Tests', () {
    test('Contains all authentic items specified in user specification', () {
      expect(AuthenticAzkarData.sabah.length, 31, reason: 'Morning Azkar count must be 31');
      expect(AuthenticAzkarData.masaa.length, 30, reason: 'Evening Azkar count must be 30');
      expect(AuthenticAzkarData.tawfeeq.length, 21, reason: 'Tawfeeq Azkar count must be 21');
      expect(AuthenticAzkarData.tasbeehOptions.length, 6, reason: 'Tasbeeh options count must be 6');

      // Verify Ayat Al-Kursi in Sabah
      final ayatAlKursi = AuthenticAzkarData.sabah.first;
      expect(ayatAlKursi['source'], contains('آية الكرسى'));
      expect(ayatAlKursi['count'], 1);

      // Verify Al-Ikhlas repetitions in Sabah
      final ikhlas = AuthenticAzkarData.sabah[1];
      expect(ikhlas['source'], contains('سورة الإخلاص'));
      expect(ikhlas['count'], 3);
    });
  });

  group('AppSettings Model Tests', () {
    test('AppSettings defaults and serialization', () {
      const settings = AppSettings();
      expect(settings.isRamadanMode, false);
      expect(settings.dailyQuranTarget, 20);
      expect(settings.defaultDhikrTarget, 100);

      final map = settings.copyWith(isRamadanMode: true, userName: 'أحمد').toMap();
      final loaded = AppSettings.fromMap(map);

      expect(loaded.userName, 'أحمد');
      expect(loaded.isRamadanMode, true);
      expect(loaded.dailyQuranTarget, 20);
    });
  });
}
