class AppConstants {
  AppConstants._();

  static const String appName = 'متابع العبادات';
  static const String appNameEn = 'Islamic Daily Tracker';

  // Prayer Names
  static const List<String> prayerNames = [
    'الفجر',
    'الظهر',
    'العصر',
    'المغرب',
    'العشاء',
  ];

  static const List<String> prayerNamesEn = [
    'fajr',
    'dhuhr',
    'asr',
    'maghrib',
    'isha',
  ];

  // Default Worship Items - Arranged Chronologically from Dawn to Night
  static const List<Map<String, dynamic>> defaultWorships = [
    {'name': 'أذكار الصباح', 'type': 'boolean', 'category': 'azkar', 'icon': 'sunrise'},
    {'name': 'جلسة الشروق', 'type': 'boolean', 'category': 'prayer', 'icon': 'sunrise'},
    {'name': 'صلاة الضحى', 'type': 'boolean', 'category': 'prayer', 'icon': 'sun'},
    {'name': 'صلاة الجماعة', 'type': 'counter', 'category': 'prayer', 'icon': 'mosque', 'target': 5},
    {'name': 'تكبيرة الإحرام', 'type': 'counter', 'category': 'prayer', 'icon': 'prayer', 'target': 5},
    {'name': 'النوافل', 'type': 'counter', 'category': 'prayer', 'icon': 'prayer', 'target': 12},
    {'name': 'الصيام', 'type': 'boolean', 'category': 'fasting', 'icon': 'fasting'},
    {'name': 'طلب العلم', 'type': 'boolean', 'category': 'knowledge', 'icon': 'book'},
    {'name': 'ورد القرآن', 'type': 'quantity', 'category': 'quran', 'icon': 'quran', 'target': 4},
    {'name': 'الصدقة', 'type': 'boolean', 'category': 'charity', 'icon': 'charity'},
    {'name': 'عمل خفي', 'type': 'boolean', 'category': 'general', 'icon': 'secret'},
    {'name': 'تنظيم الوقت', 'type': 'boolean', 'category': 'general', 'icon': 'clock'},
    {'name': 'أذكار المساء', 'type': 'boolean', 'category': 'azkar', 'icon': 'sunset'},
    {'name': 'الدعاء', 'type': 'boolean', 'category': 'dua', 'icon': 'hands'},
    {'name': 'القيام', 'type': 'boolean', 'category': 'prayer', 'icon': 'moon'},
    {'name': 'صلاة الوتر', 'type': 'boolean', 'category': 'prayer', 'icon': 'moon'},
    {'name': 'أذكار النوم', 'type': 'boolean', 'category': 'azkar', 'icon': 'sleep'},
    {'name': 'التوبة والاستغفار', 'type': 'counter', 'category': 'dhikr', 'icon': 'heart', 'target': 100},
    {'name': 'المحاسبة اليومية', 'type': 'boolean', 'category': 'general', 'icon': 'review'},
  ];

  // Ramadan-specific worships
  static const List<Map<String, dynamic>> ramadanWorships = [
    {'name': 'الصيام', 'type': 'boolean', 'category': 'fasting', 'icon': 'fasting'},
    {'name': 'صلاة التراويح', 'type': 'boolean', 'category': 'prayer', 'icon': 'taraweeh'},
    {'name': 'القيام', 'type': 'boolean', 'category': 'prayer', 'icon': 'moon'},
    {'name': 'ختمة القرآن', 'type': 'quantity', 'category': 'quran', 'icon': 'quran', 'target': 4},
    {'name': 'الصدقة اليومية', 'type': 'boolean', 'category': 'charity', 'icon': 'charity'},
    {'name': 'الاعتكاف', 'type': 'boolean', 'category': 'general', 'icon': 'mosque'},
  ];

  // Azkar Categories
  static const List<String> azkarCategories = [
    'أذكار الصباح',
    'أذكار المساء',
    'أذكار النوم',
    'أذكار الاستيقاظ',
    'أذكار بعد الصلاة',
    'أذكار متنوعة',
  ];

  // Database
  static const String dbName = 'islamic_tracker.db';
  static const int dbVersion = 4;
}
