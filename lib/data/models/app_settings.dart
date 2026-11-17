class AppSettings {
  final String userName;
  final bool isRamadanMode;
  final int dailyQuranTarget;
  final int defaultDhikrTarget;

  const AppSettings({
    this.userName = '',
    this.isRamadanMode = false,
    this.dailyQuranTarget = 20,
    this.defaultDhikrTarget = 100,
  });

  AppSettings copyWith({
    String? userName,
    bool? isRamadanMode,
    int? dailyQuranTarget,
    int? defaultDhikrTarget,
  }) {
    return AppSettings(
      userName: userName ?? this.userName,
      isRamadanMode: isRamadanMode ?? this.isRamadanMode,
      dailyQuranTarget: dailyQuranTarget ?? this.dailyQuranTarget,
      defaultDhikrTarget: defaultDhikrTarget ?? this.defaultDhikrTarget,
    );
  }

  Map<String, String> toMap() {
    return {
      'user_name': userName,
      'is_ramadan_mode': isRamadanMode ? '1' : '0',
      'daily_quran_target': dailyQuranTarget.toString(),
      'default_dhikr_target': defaultDhikrTarget.toString(),
    };
  }

  factory AppSettings.fromMap(Map<String, String> map) {
    return AppSettings(
      userName: map['user_name'] ?? '',
      isRamadanMode: map['is_ramadan_mode'] == '1',
      dailyQuranTarget: int.tryParse(map['daily_quran_target'] ?? '20') ?? 20,
      defaultDhikrTarget: int.tryParse(map['default_dhikr_target'] ?? '100') ?? 100,
    );
  }
}
