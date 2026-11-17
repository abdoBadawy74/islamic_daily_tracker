class AzkarCategory {
  final String id;
  final String name;
  final String iconName;

  const AzkarCategory({
    required this.id,
    required this.name,
    this.iconName = 'default',
  });

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'icon_name': iconName};

  factory AzkarCategory.fromMap(Map<String, dynamic> map) => AzkarCategory(
        id: map['id'] as String,
        name: map['name'] as String,
        iconName: map['icon_name'] as String? ?? 'default',
      );
}

class AzkarItem {
  final String id;
  final String categoryId;
  final String text;
  final int repetitions;
  final int currentCount;
  final String? source;
  final String? virtue;

  const AzkarItem({
    required this.id,
    required this.categoryId,
    required this.text,
    this.repetitions = 1,
    this.currentCount = 0,
    this.source,
    this.virtue,
  });

  bool get isCompleted => currentCount >= repetitions;
  int get remaining => (repetitions - currentCount).clamp(0, repetitions);

  AzkarItem copyWith({
    String? id,
    String? categoryId,
    String? text,
    int? repetitions,
    int? currentCount,
    String? source,
    String? virtue,
  }) {
    return AzkarItem(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      text: text ?? this.text,
      repetitions: repetitions ?? this.repetitions,
      currentCount: currentCount ?? this.currentCount,
      source: source ?? this.source,
      virtue: virtue ?? this.virtue,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'text': text,
      'repetitions': repetitions,
      'current_count': currentCount,
      'source': source,
      'virtue': virtue,
    };
  }

  factory AzkarItem.fromMap(Map<String, dynamic> map) {
    return AzkarItem(
      id: map['id'] as String,
      categoryId: map['category_id'] as String,
      text: map['text'] as String,
      repetitions: map['repetitions'] as int? ?? 1,
      currentCount: map['current_count'] as int? ?? 0,
      source: map['source'] as String?,
      virtue: map['virtue'] as String?,
    );
  }
}

class AzkarProgress {
  final String id;
  final String azkarItemId;
  final DateTime date;
  final int completedCount;
  final int targetCount;

  const AzkarProgress({
    required this.id,
    required this.azkarItemId,
    required this.date,
    this.completedCount = 0,
    this.targetCount = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'azkar_item_id': azkarItemId,
      'date':
          '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      'completed_count': completedCount,
      'target_count': targetCount,
    };
  }

  factory AzkarProgress.fromMap(Map<String, dynamic> map) {
    return AzkarProgress(
      id: map['id'] as String,
      azkarItemId: map['azkar_item_id'] as String,
      date: DateTime.parse(map['date'] as String),
      completedCount: map['completed_count'] as int? ?? 0,
      targetCount: map['target_count'] as int? ?? 1,
    );
  }
}
