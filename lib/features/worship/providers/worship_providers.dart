import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_daily_tracker/core/providers.dart';
import 'package:islamic_daily_tracker/data/models/worship_model.dart';
import 'package:islamic_daily_tracker/features/home/providers/home_providers.dart';

// All Worships (including inactive)
final allWorshipsProvider = FutureProvider.autoDispose<List<WorshipModel>>((ref) async {
  final repo = ref.watch(worshipRepositoryProvider);
  return repo.getAllWorships(includeInactive: true, includeRamadan: true);
});

// Category filter state
final selectedWorshipCategoryProvider = StateProvider<String?>((ref) => null);

// Filtered Worships
final filteredWorshipsProvider = Provider.autoDispose<List<WorshipModel>>((ref) {
  final allAsync = ref.watch(allWorshipsProvider);
  final cat = ref.watch(selectedWorshipCategoryProvider);

  final list = allAsync.value ?? [];
  if (cat == null || cat.isEmpty) return list;
  return list.where((w) => w.category == cat).toList();
});

// Worship Management Controller
class WorshipController {
  final Ref _ref;

  WorshipController(this._ref);

  Future<void> addWorship(WorshipModel worship) async {
    final repo = _ref.read(worshipRepositoryProvider);
    await repo.addWorship(worship);
    _ref.invalidate(allWorshipsProvider);
    _ref.invalidate(activeWorshipsProvider);
  }

  Future<void> updateWorship(WorshipModel worship) async {
    final repo = _ref.read(worshipRepositoryProvider);
    await repo.updateWorship(worship);
    _ref.invalidate(allWorshipsProvider);
    _ref.invalidate(activeWorshipsProvider);
  }

  Future<void> toggleActive(WorshipModel worship) async {
    final updated = worship.copyWith(isActive: !worship.isActive);
    await updateWorship(updated);
  }

  Future<void> deleteWorship(String id) async {
    final repo = _ref.read(worshipRepositoryProvider);
    await repo.deleteWorship(id);
    _ref.invalidate(allWorshipsProvider);
    _ref.invalidate(activeWorshipsProvider);
  }
}

final worshipControllerProvider = Provider<WorshipController>((ref) {
  return WorshipController(ref);
});
