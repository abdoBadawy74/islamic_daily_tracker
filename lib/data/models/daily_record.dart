class DailyRecord {
  final String id;
  final String worshipId;
  final DateTime date;
  final bool isCompleted;
  final int currentValue;
  final int targetValue;
  final String? notes;

  const DailyRecord({
    required this.id,
    required this.worshipId,
    required this.date,
    this.isCompleted = false,
    this.currentValue = 0,
    this.targetValue = 1,
    this.notes,
  });

  double get completionPercentage {
    if (targetValue <= 0) return isCompleted ? 100.0 : 0.0;
    final pct = (currentValue / targetValue) * 100.0;
    return pct.clamp(0.0, 100.0);
  }

  bool get isGoalMet => currentValue >= targetValue || isCompleted;

  DailyRecord copyWith({
    String? id,
    String? worshipId,
    DateTime? date,
    bool? isCompleted,
    int? currentValue,
    int? targetValue,
    String? notes,
  }) {
    return DailyRecord(
      id: id ?? this.id,
      worshipId: worshipId ?? this.worshipId,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
      currentValue: currentValue ?? this.currentValue,
      targetValue: targetValue ?? this.targetValue,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'worship_id': worshipId,
      'date': _dateToString(date),
      'is_completed': isCompleted ? 1 : 0,
      'current_value': currentValue,
      'target_value': targetValue,
      'notes': notes,
    };
  }

  factory DailyRecord.fromMap(Map<String, dynamic> map) {
    return DailyRecord(
      id: map['id'] as String,
      worshipId: map['worship_id'] as String,
      date: DateTime.parse(map['date'] as String),
      isCompleted: (map['is_completed'] as int?) == 1,
      currentValue: map['current_value'] as int? ?? 0,
      targetValue: map['target_value'] as int? ?? 1,
      notes: map['notes'] as String?,
    );
  }

  static String _dateToString(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
