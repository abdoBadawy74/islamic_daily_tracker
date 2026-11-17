import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:islamic_daily_tracker/core/theme/app_colors.dart';

class ElectronicTasbihScreen extends StatefulWidget {
  const ElectronicTasbihScreen({super.key});

  @override
  State<ElectronicTasbihScreen> createState() => _ElectronicTasbihScreenState();
}

class _ElectronicTasbihScreenState extends State<ElectronicTasbihScreen> {
  int _counter = 0;
  int _target = 100;
  int _totalSessionCount = 0;
  bool _hapticEnabled = true;

  late List<String> _dhikrList;
  late String _activeDhikr;

  @override
  void initState() {
    super.initState();
    _dhikrList = [
      'أَسْتَغْفِرُ اللَّهَ',
      'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ',
      'سُبْحَانَ اللَّهِ',
      'الْحَمْدُ لِلَّهِ',
      'اللَّهُ أَكْبَرُ',
      'لَا إِلَهَ إِلَّا اللَّهُ',
      'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
      'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
    ];
    _activeDhikr = _dhikrList[0];
  }

  void _increment() {
    if (_hapticEnabled) {
      HapticFeedback.lightImpact();
    }
    setState(() {
      _counter++;
      _totalSessionCount++;
    });

    if (_target > 0 && _counter == _target) {
      if (_hapticEnabled) {
        HapticFeedback.vibrate();
      }
      _showCompletionNotice();
    }
  }

  void _decrement() {
    if (_counter > 0) {
      if (_hapticEnabled) {
        HapticFeedback.selectionClick();
      }
      setState(() {
        _counter--;
        if (_totalSessionCount > 0) _totalSessionCount--;
      });
    }
  }

  void _reset() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('تصفير العداد؟'),
        content: const Text('هل ترغب في إعادة ضبط عداد التسبيح الحالي؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              setState(() => _counter = 0);
              Navigator.pop(context);
            },
            child: const Text('تصفير'),
          ),
        ],
      ),
    );
  }

  void _showCompletionNotice() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('بارك الله فيك! أتممت الورد المستهدف ($_target مرة)'),
        backgroundColor: AppColors.emerald,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _addNewDhikr() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('إضافة ذكر جديد'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'اكتب الذكر هنا...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                setState(() {
                  _dhikrList.insert(0, text);
                  _activeDhikr = text;
                  _counter = 0;
                });
              }
              Navigator.pop(context);
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _selectTarget() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final targets = [33, 100, 300, 1000, 0];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Text('حدد الهدف للذكر', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 8),
              ...targets.map((t) {
                final isSelected = _target == t;
                return ListTile(
                  title: Text(t == 0 ? 'مفتوح (بدون هدف محدد)' : '$t مرة'),
                  trailing: isSelected ? const Icon(Icons.check, color: AppColors.emerald) : null,
                  onTap: () {
                    setState(() => _target = t);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = _target > 0 ? (_counter / _target).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: const Text(
          'المسبحة الإلكترونية',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_rounded, color: AppColors.textPrimary),
            tooltip: 'إجمالي التسبيحات اليوم',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('إجمالي تسبيحات الجلسة الحالية: $_totalSessionCount تسبيحة'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            // 1. Horizontal Dhikr Selector Chips (as seen in Screenshot 4)
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Add custom Dhikr Button
                  GestureDetector(
                    onTap: _addNewDhikr,
                    child: Container(
                      width: 42,
                      height: 42,
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        color: AppColors.emerald,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 22),
                    ),
                  ),

                  // Dhikr list chips
                  ..._dhikrList.map((d) {
                    final isSelected = d == _activeDhikr;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _activeDhikr = d;
                          _counter = 0;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.emerald : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.emerald : Colors.grey.shade300,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            d,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            const Spacer(flex: 2),

            // 2. Large Counter Display with - and + Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Decrement Button
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.emerald.withValues(alpha: 0.15),
                      foregroundColor: AppColors.emerald,
                      padding: const EdgeInsets.all(12),
                    ),
                    icon: const Icon(Icons.remove, size: 28),
                    onPressed: _decrement,
                  ),

                  // Big bold counter number
                  Text(
                    '$_counter',
                    style: const TextStyle(
                      fontSize: 82,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                      letterSpacing: -1.5,
                      fontFamily: 'sans-serif',
                    ),
                  ),

                  // Increment manual button
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.emerald.withValues(alpha: 0.15),
                      foregroundColor: AppColors.emerald,
                      padding: const EdgeInsets.all(12),
                    ),
                    icon: const Icon(Icons.add, size: 28),
                    onPressed: _increment,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 3. Active Dhikr Label
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _activeDhikr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),

            const Spacer(flex: 2),

            // 4. Large Circular Tap Button with Ring Indicator (matching Screenshot 4)
            Center(
              child: GestureDetector(
                onTap: _increment,
                child: SizedBox(
                  width: 240,
                  height: 240,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Progress Ring
                      SizedBox(
                        width: 240,
                        height: 240,
                        child: CircularProgressIndicator(
                          value: _target > 0 ? progress : 0.0,
                          strokeWidth: 6,
                          backgroundColor: Colors.grey.shade200,
                          color: AppColors.primary,
                        ),
                      ),

                      // Emerald Center Touch Button
                      Container(
                        width: 210,
                        height: 210,
                        decoration: BoxDecoration(
                          color: AppColors.emerald,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.emerald.withValues(alpha: 0.35),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.touch_app_rounded,
                            size: 64,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const Spacer(flex: 3),

            // 5. Bottom Controls Bar (Haptic / Target Pill / Reset)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Haptic / Vibration Toggle
                  IconButton.filledTonal(
                    style: IconButton.styleFrom(
                      backgroundColor: _hapticEnabled
                          ? AppColors.emerald.withValues(alpha: 0.15)
                          : Colors.grey.shade100,
                      foregroundColor: _hapticEnabled ? AppColors.emerald : Colors.grey,
                      padding: const EdgeInsets.all(12),
                    ),
                    icon: Icon(
                      _hapticEnabled ? Icons.vibration_rounded : Icons.smartphone_rounded,
                      size: 22,
                    ),
                    tooltip: 'الاهتزاز عند التسبيح',
                    onPressed: () {
                      setState(() => _hapticEnabled = !_hapticEnabled);
                    },
                  ),

                  // Target Selector Pill (e.g. 100)
                  InkWell(
                    onTap: _selectTarget,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.emerald,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _target == 0 ? 'مفتوح' : '$_target',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  // Reset Button (↺)
                  IconButton.filledTonal(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                      foregroundColor: AppColors.textPrimary,
                      padding: const EdgeInsets.all(12),
                    ),
                    icon: const Icon(Icons.refresh_rounded, size: 24),
                    tooltip: 'إعادة ضبط العداد',
                    onPressed: _reset,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
