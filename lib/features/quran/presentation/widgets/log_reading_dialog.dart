import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_daily_tracker/core/theme/app_colors.dart';
import 'package:islamic_daily_tracker/features/quran/data/surah_data.dart';
import 'package:islamic_daily_tracker/features/quran/providers/quran_providers.dart';

class LogReadingDialog extends ConsumerStatefulWidget {
  final int? initialSurahNumber;

  const LogReadingDialog({super.key, this.initialSurahNumber});

  @override
  ConsumerState<LogReadingDialog> createState() => _LogReadingDialogState();
}

class _LogReadingDialogState extends ConsumerState<LogReadingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _pagesController = TextEditingController(text: '1');
  final _ayahController = TextEditingController();
  final _notesController = TextEditingController();
  late int _selectedSurahNumber;

  @override
  void initState() {
    super.initState();
    _selectedSurahNumber = widget.initialSurahNumber ?? 1;
  }

  @override
  void dispose() {
    _pagesController.dispose();
    _ayahController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.bookmark_add_outlined, color: AppColors.primary),
          SizedBox(width: 8),
          Text('تسجيل ورد القراءة'),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pages Read Input
              TextFormField(
                controller: _pagesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'عدد الصفحات المقروءة اليوم *',
                  prefixIcon: Icon(Icons.file_copy_outlined),
                  suffixText: 'صفحة',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'يرجى إدخال عدد الصفحات';
                  final n = int.tryParse(val);
                  if (n == null || n <= 0) return 'يرجى إدخال رقم صحيح أكبر من 0';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Surah Dropdown
              DropdownButtonFormField<int>(
                initialValue: _selectedSurahNumber,
                decoration: const InputDecoration(
                  labelText: 'السورة',
                  prefixIcon: Icon(Icons.menu_book_rounded),
                ),
                items: QuranData.surahs.map((s) {
                  return DropdownMenuItem(
                    value: s.number,
                    child: Text('${s.number}. سورة ${s.nameArabic}'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedSurahNumber = val);
                },
              ),
              const SizedBox(height: 14),

              // Ayah reached
              TextFormField(
                controller: _ayahController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'رقم آخر آية وصلت إليها (اختياري)',
                  prefixIcon: Icon(Icons.tag),
                ),
              ),
              const SizedBox(height: 14),

              // Notes
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'ملاحظات أو تدبرات (اختياري)',
                  prefixIcon: Icon(Icons.note_alt_outlined),
                ),
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
          onPressed: _saveReading,
          child: const Text('تسجيل'),
        ),
      ],
    );
  }

  void _saveReading() async {
    if (!_formKey.currentState!.validate()) return;

    final pages = int.parse(_pagesController.text.trim());
    final ayah = int.tryParse(_ayahController.text.trim());
    final notes = _notesController.text.trim();
    final surah = QuranData.surahs.firstWhere((s) => s.number == _selectedSurahNumber);

    final actions = ref.read(quranActionsProvider);
    await actions.logReading(
      pagesRead: pages,
      surahNumber: _selectedSurahNumber,
      surahName: surah.nameArabic,
      ayahNumber: ayah,
      notes: notes.isNotEmpty ? notes : null,
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('بارك الله فيك، تم تسجيل قراءة $pages صفحة من سورة ${surah.nameArabic}'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }
}
