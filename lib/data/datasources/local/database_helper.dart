import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:islamic_daily_tracker/core/constants/app_constants.dart';
import 'package:islamic_daily_tracker/data/datasources/local/authentic_azkar_data.dart';
import 'package:uuid/uuid.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  final _uuid = const Uuid();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);
    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: _onOpen,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE prayers (
        id TEXT PRIMARY KEY,
        prayer_name TEXT NOT NULL,
        state TEXT NOT NULL,
        date TEXT NOT NULL,
        UNIQUE(prayer_name, date)
      )
    ''');

    await db.execute('''
      CREATE TABLE worships (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL DEFAULT 'general',
        icon_name TEXT DEFAULT 'default',
        target INTEGER,
        is_active INTEGER NOT NULL DEFAULT 1,
        is_ramadan_only INTEGER NOT NULL DEFAULT 0,
        sort_order INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE daily_records (
        id TEXT PRIMARY KEY,
        worship_id TEXT NOT NULL,
        date TEXT NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0,
        current_value INTEGER NOT NULL DEFAULT 0,
        target_value INTEGER NOT NULL DEFAULT 1,
        notes TEXT,
        UNIQUE(worship_id, date)
      )
    ''');

    await db.execute('''
      CREATE TABLE quran_progress (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL UNIQUE,
        surah_number INTEGER,
        ayah_number INTEGER,
        pages_read INTEGER NOT NULL DEFAULT 0,
        daily_target INTEGER NOT NULL DEFAULT 20,
        last_surah_name TEXT,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE azkar_categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon_name TEXT DEFAULT 'default'
      )
    ''');

    await db.execute('''
      CREATE TABLE azkar_items (
        id TEXT PRIMARY KEY,
        category_id TEXT NOT NULL,
        text TEXT NOT NULL,
        repetitions INTEGER NOT NULL DEFAULT 1,
        current_count INTEGER NOT NULL DEFAULT 0,
        source TEXT,
        virtue TEXT,
        FOREIGN KEY (category_id) REFERENCES azkar_categories(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE azkar_progress (
        id TEXT PRIMARY KEY,
        azkar_item_id TEXT NOT NULL,
        date TEXT NOT NULL,
        completed_count INTEGER NOT NULL DEFAULT 0,
        target_count INTEGER NOT NULL DEFAULT 1,
        UNIQUE(azkar_item_id, date)
      )
    ''');

    await db.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // Seed default data
    await _seedWorships(db);
    await _seedAzkar(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _reseedAzkar(db);
    }
    if (oldVersion < 3) {
      await _reseedWorships(db);
      await _reseedAzkar(db);
    }
  }

  Future<void> _onOpen(Database db) async {
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM azkar_items'),
    ) ?? 0;
    // Check if azkar contain old glued text or tawfeeq category
    final oldTextSample = await db.rawQuery(
      "SELECT text FROM azkar_items WHERE text LIKE '%الرَّجِيمِاللّهُ%' OR text LIKE '%الرَّحِيمقُلْ%' LIMIT 1",
    );
    final hasTawfeeq = Sqflite.firstIntValue(
      await db.rawQuery("SELECT COUNT(*) FROM azkar_categories WHERE name = 'أدعية التوفيق والتيسير'"),
    ) ?? 0;
    // If the database has fewer than 50 items or contains old unspaced text or has tawfeeq, re-seed with authentic azkar
    if (count < 50 || oldTextSample.isNotEmpty || hasTawfeeq > 0) {
      await _reseedAzkar(db);
    }

    // Check if worships need re-seeding (e.g. old names or prayer group boolean)
    final needsWorshipReseed = Sqflite.firstIntValue(
      await db.rawQuery("SELECT COUNT(*) FROM worships WHERE name = 'درس علمي' OR name = 'درس تفسير وتدبر' OR (name = 'صلاة الجماعة' AND type = 'boolean')"),
    ) ?? 0;
    if (needsWorshipReseed > 0) {
      await _reseedWorships(db);
    }
  }

  Future<void> _reseedWorships(Database db) async {
    await db.delete('worships');
    await _seedWorships(db);
  }

  Future<void> _reseedAzkar(Database db) async {
    await db.delete('azkar_items');
    await db.delete('azkar_categories');
    await _seedAzkar(db);
  }

  Future<void> _seedWorships(Database db) async {
    final now = DateTime.now().toIso8601String();
    for (int i = 0; i < AppConstants.defaultWorships.length; i++) {
      final w = AppConstants.defaultWorships[i];
      await db.insert('worships', {
        'id': _uuid.v4(),
        'name': w['name'],
        'type': w['type'],
        'category': w['category'],
        'icon_name': w['icon'] ?? 'default',
        'target': w['target'],
        'is_active': 1,
        'is_ramadan_only': 0,
        'sort_order': i,
        'created_at': now,
      });
    }
    for (int i = 0; i < AppConstants.ramadanWorships.length; i++) {
      final w = AppConstants.ramadanWorships[i];
      await db.insert('worships', {
        'id': _uuid.v4(),
        'name': w['name'],
        'type': w['type'],
        'category': w['category'],
        'icon_name': w['icon'] ?? 'default',
        'target': w['target'],
        'is_active': 1,
        'is_ramadan_only': 1,
        'sort_order': AppConstants.defaultWorships.length + i,
        'created_at': now,
      });
    }
  }

  Future<void> _seedAzkar(Database db) async {
    // 1. Morning Azkar (31 Authentic Items)
    final morningId = _uuid.v4();
    await db.insert('azkar_categories', {
      'id': morningId,
      'name': 'أذكار الصباح',
      'icon_name': 'sunrise',
    });
    for (final item in AuthenticAzkarData.sabah) {
      await db.insert('azkar_items', {
        'id': _uuid.v4(),
        'category_id': morningId,
        'text': item['text'],
        'repetitions': item['count'] ?? 1,
        'current_count': 0,
        'source': item['source'],
        'virtue': item['virtue'],
      });
    }

    // 2. Evening Azkar (30 Authentic Items)
    final eveningId = _uuid.v4();
    await db.insert('azkar_categories', {
      'id': eveningId,
      'name': 'أذكار المساء',
      'icon_name': 'sunset',
    });
    for (final item in AuthenticAzkarData.masaa) {
      await db.insert('azkar_items', {
        'id': _uuid.v4(),
        'category_id': eveningId,
        'text': item['text'],
        'repetitions': item['count'] ?? 1,
        'current_count': 0,
        'source': item['source'],
        'virtue': item['virtue'],
      });
    }

    // 4. Sleep Azkar
    final sleepId = _uuid.v4();
    await db.insert('azkar_categories', {
      'id': sleepId,
      'name': 'أذكار النوم',
      'icon_name': 'sleep',
    });
    final sleepAzkar = [
      {'text': 'بِاسْمِكَ رَبِّـي وَضَعْـتُ جَنْـبي، وَبِكَ أَرْفَعُـه، فَإِن أَمْسَـكْتَ نَفْسـي فَارْحَمْـها، وَإِنْ أَرْسَلْتَـها فَاحْفَظْـها بِمـا تَحْفَـظُ بِـهِ عِبـادَكَ الصّـالِحـين.', 'rep': 1, 'source': 'متفق عليه'},
      {'text': 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا', 'rep': 1, 'source': 'البخاري'},
      {'text': 'اللَّهُمَّ قِنِي عَذَابَكَ يَوْمَ تَبْعَثُ عِبَادَكَ', 'rep': 3, 'source': 'أبو داود والترمذي'},
      {'text': 'سُبْحَانَ اللَّهِ', 'rep': 33, 'source': 'متفق عليه'},
      {'text': 'الْحَمْدُ لِلَّهِ', 'rep': 33, 'source': 'متفق عليه'},
      {'text': 'اللَّهُ أَكْبَرُ', 'rep': 34, 'source': 'متفق عليه'},
    ];
    for (final a in sleepAzkar) {
      await db.insert('azkar_items', {
        'id': _uuid.v4(),
        'category_id': sleepId,
        'text': a['text'],
        'repetitions': a['rep'],
        'current_count': 0,
        'source': a['source'],
        'virtue': a['virtue'],
      });
    }

    // 5. Wakeup Azkar
    final wakeupId = _uuid.v4();
    await db.insert('azkar_categories', {
      'id': wakeupId,
      'name': 'أذكار الاستيقاظ',
      'icon_name': 'wakeup',
    });
    final wakeupAzkar = [
      {'text': 'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ', 'rep': 1, 'source': 'البخاري'},
      {'text': 'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ، سُبْحَانَ اللَّهِ وَالْحَمْدُ لِلَّهِ وَلَا إِلَهَ إِلَّا اللَّهُ وَاللَّهُ أَكْبَرُ وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ الْعَلِيِّ الْعَظِيمِ', 'rep': 1, 'source': 'البخاري'},
    ];
    for (final a in wakeupAzkar) {
      await db.insert('azkar_items', {
        'id': _uuid.v4(),
        'category_id': wakeupId,
        'text': a['text'],
        'repetitions': a['rep'],
        'current_count': 0,
        'source': a['source'],
        'virtue': a['virtue'],
      });
    }

    // 6. After Prayer Azkar
    final prayerId = _uuid.v4();
    await db.insert('azkar_categories', {
      'id': prayerId,
      'name': 'أذكار بعد الصلاة',
      'icon_name': 'prayer',
    });
    final afterPrayerAzkar = [
      {'text': 'أَسْتَغْفِرُ اللَّهَ، أَسْتَغْفِرُ اللَّهَ، أَسْتَغْفِرُ اللَّهَ', 'rep': 3, 'source': 'مسلم'},
      {'text': 'اللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ، تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ', 'rep': 1, 'source': 'مسلم'},
      {'text': 'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ، اللَّهُمَّ لَا مَانِعَ لِمَا أَعْطَيْتَ وَلَا مُعْطِيَ لِمَا مَنَعْتَ وَلَا يَنْفَعُ ذَا الْجَدِّ مِنْكَ الْجَدُّ', 'rep': 1, 'source': 'متفق عليه'},
      {'text': 'سُبْحَانَ اللَّهِ', 'rep': 33, 'source': 'مسلم'},
      {'text': 'الْحَمْدُ لِلَّهِ', 'rep': 33, 'source': 'مسلم'},
      {'text': 'اللَّهُ أَكْبَرُ', 'rep': 33, 'source': 'مسلم'},
      {'text': 'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ', 'rep': 1, 'source': 'مسلم', 'virtue': 'تمام المائة بعد التسبيح والتحميد والتكبير'},
      {'text': 'اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ، وَشُكْرِكَ، وَحُسْنِ عِبَادَتِكَ', 'rep': 1, 'source': 'أبو داود والنسائي'},
    ];
    for (final a in afterPrayerAzkar) {
      await db.insert('azkar_items', {
        'id': _uuid.v4(),
        'category_id': prayerId,
        'text': a['text'],
        'repetitions': a['rep'],
        'current_count': 0,
        'source': a['source'],
        'virtue': a['virtue'],
      });
    }

    // 7. Misc Azkar
    final miscId = _uuid.v4();
    await db.insert('azkar_categories', {
      'id': miscId,
      'name': 'أذكار متنوعة',
      'icon_name': 'misc',
    });
    final miscAzkar = [
      {'text': 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ', 'rep': 10, 'source': 'متفق عليه', 'virtue': 'كنز من كنوز الجنة'},
      {'text': 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، سُبْحَانَ اللَّهِ الْعَظِيمِ', 'rep': 10, 'source': 'متفق عليه', 'virtue': 'كلمتان خفيفتان على اللسان ثقيلتان في الميزان حبيبتان إلى الرحمن'},
      {'text': 'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ', 'rep': 10, 'source': 'مسلم'},
      {'text': 'رَبِّ اغْفِرْ لِي وَتُبْ عَلَيَّ إِنَّكَ أَنْتَ التَّوَّابُ الْغَفُورُ', 'rep': 100, 'source': 'أبو داود والترمذي'},
      {'text': 'لَا إِلَهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ', 'rep': 10, 'source': 'الأنبياء 87', 'virtue': 'دعوة ذي النون لم يدع بها مسلم قط إلا استجاب الله له'},
    ];
    for (final a in miscAzkar) {
      await db.insert('azkar_items', {
        'id': _uuid.v4(),
        'category_id': miscId,
        'text': a['text'],
        'repetitions': a['rep'],
        'current_count': 0,
        'source': a['source'],
        'virtue': a['virtue'],
      });
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
