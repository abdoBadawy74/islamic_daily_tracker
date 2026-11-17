import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_daily_tracker/core/theme/app_colors.dart';
import 'package:islamic_daily_tracker/core/utils/worship_icons.dart';
import 'package:islamic_daily_tracker/data/models/worship_model.dart';
import 'package:islamic_daily_tracker/features/worship/providers/worship_providers.dart';
import 'package:uuid/uuid.dart';

class AddEditWorshipDialog extends ConsumerStatefulWidget {
  final WorshipModel? worshipToEdit;

  const AddEditWorshipDialog({super.key, this.worshipToEdit});

  @override
  ConsumerState<AddEditWorshipDialog> createState() => _AddEditWorshipDialogState();
}

class _AddEditWorshipDialogState extends ConsumerState<AddEditWorshipDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _targetController;
  late WorshipType _selectedType;
  late String _selectedCategory;
  late bool _isRamadanOnly;
  late bool _isActive;

  final List<String> _categories = [
    'prayer',
    'fasting',
    'quran',
    'azkar',
    'charity',
    'knowledge',
    'general',
  ];

  @override
  void initState() {
    super.initState();
    final w = widget.worshipToEdit;
    _nameController = TextEditingController(text: w?.name ?? '');
    _targetController = TextEditingController(text: w?.target?.toString() ?? '');
    _selectedType = w?.type ?? WorshipType.boolean_;
    _selectedCategory = w?.category ?? 'general';
    _isRamadanOnly = w?.isRamadanOnly ?? false;
    _isActive = w?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.worshipToEdit != null;

    return AlertDialog(
      title: Text(isEditing ? 'تعديل العبادة' : 'إضافة عبادة جديدة'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Worship Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم العبادة أو العادة الإيمانية *',
                  hintText: 'مثال: صلاة الوتر، ورد الاستغفار',
                  prefixIcon: Icon(Icons.edit_note_rounded),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'يرجى كتابة اسم العبادة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Category Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'التصنيف',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: _categories.map((c) {
                  return DropdownMenuItem(
                    value: c,
                    child: Text(WorshipIcons.getCategoryArabicName(c)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
              const SizedBox(height: 14),

              // Type Selector
              DropdownButtonFormField<WorshipType>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'طريقة تسجيل الإنجاز *',
                  prefixIcon: Icon(Icons.checklist_rounded),
                ),
                items: WorshipType.values.map((t) {
                  return DropdownMenuItem(
                    value: t,
                    child: Text(WorshipModel.worshipTypeToArabic(t)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedType = val;
                      if (_selectedType == WorshipType.boolean_) {
                        _targetController.clear();
                      } else if (_targetController.text.isEmpty) {
                        _targetController.text = _getDefaultTargetForType(val).toString();
                      }
                    });
                  }
                },
              ),

              // Target input if not boolean
              if (_selectedType != WorshipType.boolean_) ...[
                const SizedBox(height: 14),
                TextFormField(
                  controller: _targetController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: _getTargetLabel(_selectedType),
                    prefixIcon: const Icon(Icons.flag_outlined),
                    suffixText: _getTargetSuffix(_selectedType),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'يرجى تحديد الهدف اليومي';
                    }
                    final n = int.tryParse(val);
                    if (n == null || n <= 0) {
                      return 'يرجى إدخال رقم صحيح أكبر من الصفر';
                    }
                    return null;
                  },
                ),
              ],

              const SizedBox(height: 14),

              // Ramadan Only Toggle
              SwitchListTile(
                title: const Text('خاصة بشهر رمضان المبارك'),
                subtitle: const Text('تظهر فقط عند تفعيل وضع رمضان'),
                value: _isRamadanOnly,
                activeThumbColor: AppColors.gold,
                contentPadding: EdgeInsets.zero,
                onChanged: (val) => setState(() => _isRamadanOnly = val),
              ),

              if (isEditing)
                SwitchListTile(
                  title: const Text('تفعيل العبادة'),
                  subtitle: const Text('إظهارها في الصفحة الرئيسية'),
                  value: _isActive,
                  activeThumbColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) => setState(() => _isActive = val),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _saveWorship,
          child: Text(isEditing ? 'تعديل' : 'إضافة'),
        ),
      ],
    );
  }

  int _getDefaultTargetForType(WorshipType type) {
    switch (type) {
      case WorshipType.counter:
        return 100;
      case WorshipType.quantity:
        return 20;
      case WorshipType.duration:
        return 30;
      case WorshipType.boolean_:
        return 1;
    }
  }

  String _getTargetLabel(WorshipType type) {
    switch (type) {
      case WorshipType.counter:
        return 'الهدف اليومي للتكرار *';
      case WorshipType.quantity:
        return 'الكمية المستهدفة (صفحات/أجزاء) *';
      case WorshipType.duration:
        return 'المدة المستهدفة بالدقائق *';
      case WorshipType.boolean_:
        return 'الهدف';
    }
  }

  String _getTargetSuffix(WorshipType type) {
    switch (type) {
      case WorshipType.counter:
        return 'مرة';
      case WorshipType.quantity:
        return 'صفحة';
      case WorshipType.duration:
        return 'دقيقة';
      case WorshipType.boolean_:
        return '';
    }
  }

  void _saveWorship() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = ref.read(worshipControllerProvider);
    final targetVal = _selectedType == WorshipType.boolean_
        ? 1
        : int.tryParse(_targetController.text) ?? 1;

    if (widget.worshipToEdit != null) {
      final updated = widget.worshipToEdit!.copyWith(
        name: _nameController.text.trim(),
        type: _selectedType,
        category: _selectedCategory,
        target: targetVal,
        isRamadanOnly: _isRamadanOnly,
        isActive: _isActive,
      );
      await controller.updateWorship(updated);
    } else {
      final newWorship = WorshipModel(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        type: _selectedType,
        category: _selectedCategory,
        target: targetVal,
        isRamadanOnly: _isRamadanOnly,
        isActive: true,
        createdAt: DateTime.now(),
      );
      await controller.addWorship(newWorship);
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.worshipToEdit != null
              ? 'تم تعديل العبادة بنجاح'
              : 'تمت إضافة العبادة بنجاح'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }
}
