import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:islamic_daily_tracker/core/theme/app_colors.dart';
import 'package:islamic_daily_tracker/core/utils/worship_icons.dart';
import 'package:islamic_daily_tracker/core/widgets/app_card.dart';
import 'package:islamic_daily_tracker/data/models/azkar_model.dart';
import 'package:islamic_daily_tracker/features/azkar/presentation/screens/azkar_detail_screen.dart';
import 'package:islamic_daily_tracker/features/azkar/presentation/screens/electronic_tasbih_screen.dart';
import 'package:islamic_daily_tracker/features/azkar/providers/azkar_providers.dart';

class AzkarScreen extends ConsumerWidget {
  const AzkarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(azkarCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الأذكار والتسبيح'),
        actions: [
          IconButton(
            icon: const Icon(Icons.fingerprint_rounded),
            tooltip: 'المسبحة الإلكترونية',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ElectronicTasbihScreen()),
              );
            },
          ),
        ],
      ),
      body: categoriesAsync.when(
        data: (categories) {
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              // Inspirational Banner
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.emerald, AppColors.primaryDark],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.auto_awesome, color: AppColors.goldLight, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '﴿أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ﴾',
                            style: TextStyle(
                              color: AppColors.textOnPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'أكثر من ذكر الله في كل وقت وحين',
                            style: TextStyle(
                              color: AppColors.goldLight,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Electronic Misbaha Featured Card (Direct link to screen 4)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.emerald.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.emerald.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ElectronicTasbihScreen()),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.emerald, AppColors.primaryDark],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.touch_app_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'المسبحة الإلكترونية التفاعلية',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryDark,
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Badge(
                                      label: Text('تفاعلي', style: TextStyle(fontSize: 10)),
                                      backgroundColor: AppColors.gold,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'عداد تسبيح ذكي باللمس، مع أهداف متعددة واهتزاز تفاعلي',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: AppColors.emerald,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Categories Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'أبواب الأذكار والأدعية',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    Text(
                      '${categories.length} أبواب مباركة',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),

              // Categories List
              ...categories.map((cat) => _CategoryCard(category: cat)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('خطأ: $err')),
      ),
    );
  }
}

class _CategoryCard extends ConsumerWidget {
  final AzkarCategory category;

  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(categoryProgressProvider(category.id));

    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AzkarDetailScreen(category: category),
          ),
        );
      },
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  WorshipIcons.getIcon(category.iconName),
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    progressAsync.when(
                      data: (prog) => Text(
                        '${prog.completedItems} من ${prog.totalItems} ذكر مكتمل',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      loading: () => const Text(
                        'جاري التحميل...',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      error: (e, s) => const SizedBox(),
                    ),
                  ],
                ),
              ),
              progressAsync.when(
                data: (prog) => prog.percentage >= 100.0
                    ? const Icon(Icons.check_circle, color: AppColors.emerald, size: 24)
                    : Text(
                        '${prog.percentage.toInt()}%',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                loading: () => const SizedBox(),
                error: (e, s) => const SizedBox(),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: 10),
          progressAsync.when(
            data: (prog) => ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearPercentIndicator(
                lineHeight: 4.0,
                percent: (prog.percentage / 100.0).clamp(0.0, 1.0),
                padding: EdgeInsets.zero,
                backgroundColor: AppColors.beigeDark.withValues(alpha: 0.5),
                progressColor: prog.percentage >= 100.0 ? AppColors.emerald : AppColors.primary,
                barRadius: const Radius.circular(4),
              ),
            ),
            loading: () => const SizedBox(),
            error: (e, s) => const SizedBox(),
          ),
        ],
      ),
    );
  }
}
