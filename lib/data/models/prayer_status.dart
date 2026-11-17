enum PrayerState { onTime, late_, missed, notRecorded }

class PrayerStatus {
  final String id;
  final String prayerName;
  final PrayerState state;
  final DateTime date;

  const PrayerStatus({
    required this.id,
    required this.prayerName,
    required this.state,
    required this.date,
  });

  PrayerStatus copyWith({
    String? id,
    String? prayerName,
    PrayerState? state,
    DateTime? date,
  }) {
    return PrayerStatus(
      id: id ?? this.id,
      prayerName: prayerName ?? this.prayerName,
      state: state ?? this.state,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'prayer_name': prayerName,
      'state': state.name,
      'date': _dateToString(date),
    };
  }

  factory PrayerStatus.fromMap(Map<String, dynamic> map) {
    return PrayerStatus(
      id: map['id'] as String,
      prayerName: map['prayer_name'] as String,
      state: PrayerState.values.firstWhere(
        (e) => e.name == map['state'],
        orElse: () => PrayerState.notRecorded,
      ),
      date: DateTime.parse(map['date'] as String),
    );
  }

  static String _dateToString(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
