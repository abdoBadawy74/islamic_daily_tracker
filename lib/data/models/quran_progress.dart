class QuranProgress {
  final String id;
  final DateTime date;
  final int? surahNumber;
  final int? ayahNumber;
  final int pagesRead;
  final int dailyTarget;
  final String? lastSurahName;
  final String? notes;

  const QuranProgress({
    required this.id,
    required this.date,
    this.surahNumber,
    this.ayahNumber,
    this.pagesRead = 0,
    this.dailyTarget = 20,
    this.lastSurahName,
    this.notes,
  });

  double get completionPercentage {
    if (dailyTarget <= 0) return 0.0;
    return ((pagesRead / dailyTarget) * 100.0).clamp(0.0, 100.0);
  }

  QuranProgress copyWith({
    String? id,
    DateTime? date,
    int? surahNumber,
    int? ayahNumber,
    int? pagesRead,
    int? dailyTarget,
    String? lastSurahName,
    String? notes,
  }) {
    return QuranProgress(
      id: id ?? this.id,
      date: date ?? this.date,
      surahNumber: surahNumber ?? this.surahNumber,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      pagesRead: pagesRead ?? this.pagesRead,
      dailyTarget: dailyTarget ?? this.dailyTarget,
      lastSurahName: lastSurahName ?? this.lastSurahName,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': _dateToString(date),
      'surah_number': surahNumber,
      'ayah_number': ayahNumber,
      'pages_read': pagesRead,
      'daily_target': dailyTarget,
      'last_surah_name': lastSurahName,
      'notes': notes,
    };
  }

  factory QuranProgress.fromMap(Map<String, dynamic> map) {
    return QuranProgress(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      surahNumber: map['surah_number'] as int?,
      ayahNumber: map['ayah_number'] as int?,
      pagesRead: map['pages_read'] as int? ?? 0,
      dailyTarget: map['daily_target'] as int? ?? 20,
      lastSurahName: map['last_surah_name'] as String?,
      notes: map['notes'] as String?,
    );
  }

  static String _dateToString(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
