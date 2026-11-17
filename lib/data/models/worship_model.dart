enum WorshipType { boolean_, counter, quantity, duration }

class WorshipModel {
  final String id;
  final String name;
  final WorshipType type;
  final String category;
  final String iconName;
  final int? target;
  final bool isActive;
  final bool isRamadanOnly;
  final int sortOrder;
  final DateTime createdAt;

  const WorshipModel({
    required this.id,
    required this.name,
    required this.type,
    required this.category,
    this.iconName = 'default',
    this.target,
    this.isActive = true,
    this.isRamadanOnly = false,
    this.sortOrder = 0,
    required this.createdAt,
  });

  WorshipModel copyWith({
    String? id,
    String? name,
    WorshipType? type,
    String? category,
    String? iconName,
    int? target,
    bool? isActive,
    bool? isRamadanOnly,
    int? sortOrder,
    DateTime? createdAt,
  }) {
    return WorshipModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      category: category ?? this.category,
      iconName: iconName ?? this.iconName,
      target: target ?? this.target,
      isActive: isActive ?? this.isActive,
      isRamadanOnly: isRamadanOnly ?? this.isRamadanOnly,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'category': category,
      'icon_name': iconName,
      'target': target,
      'is_active': isActive ? 1 : 0,
      'is_ramadan_only': isRamadanOnly ? 1 : 0,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory WorshipModel.fromMap(Map<String, dynamic> map) {
    return WorshipModel(
      id: map['id'] as String,
      name: map['name'] as String,
      type: WorshipType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => WorshipType.boolean_,
      ),
      category: map['category'] as String? ?? 'general',
      iconName: map['icon_name'] as String? ?? 'default',
      target: map['target'] as int?,
      isActive: (map['is_active'] as int?) == 1,
      isRamadanOnly: (map['is_ramadan_only'] as int?) == 1,
      sortOrder: map['sort_order'] as int? ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  static String worshipTypeToArabic(WorshipType type) {
    switch (type) {
      case WorshipType.boolean_:
        return 'إنجاز';
      case WorshipType.counter:
        return 'عداد';
      case WorshipType.quantity:
        return 'كمية';
      case WorshipType.duration:
        return 'مدة';
    }
  }
}
