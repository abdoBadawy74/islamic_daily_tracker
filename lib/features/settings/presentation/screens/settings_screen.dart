import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_daily_tracker/core/providers.dart';
import 'package:islamic_daily_tracker/core/theme/app_colors.dart';
import 'package:islamic_daily_tracker/core/widgets/app_card.dart';
import 'package:islamic_daily_tracker/data/models/app_settings.dart';
import 'package:islamic_daily_tracker/features/home/providers/home_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _nameController = TextEditingController();
  final _quranTargetController = TextEditingController();
  final _dhikrTargetController = TextEditingController();
  bool _isRamadanMode = false;
  bool _isLoaded = false;

  @override
  void dispose() {
    _nameController.dispose();
    _quranTargetController.dispose();
    _dhikrTargetController.dispose();
    super.dispose();
  }

  void _initFields(AppSettings settings) {
    if (!_isLoaded) {
      _nameController.text = settings.userName;
      _quranTargetController.text = settings.dailyQuranTarget.toString();
      _dhikrTargetController.text = settings.defaultDhikrTarget.toString();
      _isRamadanMode = settings.isRamadanMode;
      _isLoaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات والملف الشخصي'),
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: const Text(
              'حفظ',
              style: TextStyle(
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: settingsAsync.when(
        data: (settings) {
          _initFields(settings);

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile Section
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.person_outline, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text(
                            'الملف الشخصي',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'الاسم الكريم',
                          hintText: 'اكتب اسمك ليظهر في الترحيب اليومي',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                      ),
                    ],
                  ),
                ),

                // Ramadan Mode Card
                AppCard(
                  backgroundColor: _isRamadanMode
                      ? AppColors.gold.withValues(alpha: 0.1)
                      : AppColors.cardBg,
                  border: _isRamadanMode
                      ? Border.all(color: AppColors.gold, width: 1.5)
                      : null,
                  child: Column(
                    children: [
                      SwitchListTile(
                        value: _isRamadanMode,
                        activeThumbColor: AppColors.gold,
                        contentPadding: EdgeInsets.zero,
                        title: const Row(
                          children: [
                            Icon(Icons.nightlight_round_outlined, color: AppColors.goldDark),
                            SizedBox(width: 8),
                            Text(
                              'وضع شهر رمضان المبارك',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        subtitle: const Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: Text(
                            'عند التفعيل، تُضاف عبادات رمضان الخاصة (الصيام، التراويح، القيام، ختمة القرآن، الصدقة اليومية، الاعتكاف) تلقائيًا إلى جدول المحاسبة اليومية.',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ),
                        onChanged: (val) {
                          setState(() => _isRamadanMode = val);
                        },
                      ),
                    ],
                  ),
                ),

                // Daily Targets Section
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.flag_outlined, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text(
                            'الأهداف اليومية الافتراضية',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _quranTargetController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'ورد القرآن المستهدف يوميًا',
                          suffixText: 'صفحة',
                          prefixIcon: Icon(Icons.menu_book_outlined),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _dhikrTargetController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'الهدف الافتراضي للذكر والتسبيح',
                          suffixText: 'مرة',
                          prefixIcon: Icon(Icons.pin_outlined),
                        ),
                      ),
                    ],
                  ),
                ),

                // About App Card
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info_outline, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text(
                            'عن التطبيق',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'تطبيق المحاسبة والعبادات اليومية',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'تطبيق إسلامي شامل مصمم لمساعدتك على الالتزام بالصلوات الخمس في أوقاتها، ومتابعة الورد القرآني، والأذكار المأثورة، وبناء العادات الإيمانية والمحافظة عليها على مدار العام مع وضع خاص لشهر رمضان المبارك.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.6),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'الإصدار: 1.0.0 (بدون إعلانات - لوجه الله تعالى)',
                        style: TextStyle(fontSize: 11, color: AppColors.goldDark, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                // Reset Data Danger Zone
                AppCard(
                  backgroundColor: AppColors.error.withValues(alpha: 0.05),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.delete_forever, color: AppColors.error, size: 28),
                        title: const Text(
                          'إعادة ضبط سجلات المحاسبة',
                          style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text(
                          'حذف سجلات الصلوات والعبادات اليومية السابقة',
                          style: TextStyle(fontSize: 11),
                        ),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          ),
                          onPressed: _confirmResetData,
                          child: const Text('إعادة ضبط', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('خطأ: $err')),
      ),
    );
  }

  void _saveSettings() async {
    final repo = ref.read(settingsRepositoryProvider);
    final quranTarget = int.tryParse(_quranTargetController.text.trim()) ?? 20;
    final dhikrTarget = int.tryParse(_dhikrTargetController.text.trim()) ?? 100;

    final updated = AppSettings(
      userName: _nameController.text.trim(),
      isRamadanMode: _isRamadanMode,
      dailyQuranTarget: quranTarget,
      defaultDhikrTarget: dhikrTarget,
    );

    await repo.saveAllSettings(updated);
    ref.invalidate(appSettingsProvider);
    ref.invalidate(activeWorshipsProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ الإعدادات بنجاح'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  void _confirmResetData() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد إعادة الضبط'),
        content: const Text(
          'هل أنت متأكد من رغبتك في حذف جميع السجلات والإنجازات السابقة؟ لا يمكن التراجع عن هذا الإجراء.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              final repo = ref.read(settingsRepositoryProvider);
              await repo.resetAllData();
              ref.invalidate(dailyPrayersProvider);
              ref.invalidate(dailyRecordsProvider);
              ref.invalidate(dailyProgressProvider);
              if (ctx.mounted) {
                Navigator.pop(ctx);
              }
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم تصفير جميع البيانات السابقة')),
                );
              }
            },
            child: const Text('تأكيد الحذف'),
          ),
        ],
      ),
    );
  }
}
