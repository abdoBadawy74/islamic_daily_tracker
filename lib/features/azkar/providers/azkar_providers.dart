import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_daily_tracker/core/providers.dart';
import 'package:islamic_daily_tracker/data/models/azkar_model.dart';

// Azkar Categories
final azkarCategoriesProvider = FutureProvider.autoDispose<List<AzkarCategory>>((ref) async {
  final repo = ref.watch(azkarRepositoryProvider);
  return repo.getCategories();
});

// Azkar Items by Category
final azkarItemsByCategoryProvider =
    FutureProvider.family.autoDispose<List<AzkarItem>, String>((ref, categoryId) async {
  final repo = ref.watch(azkarRepositoryProvider);
  return repo.getItemsByCategory(categoryId);
});

// Category Progress Summary
class CategoryProgressSummary {
  final int totalItems;
  final int completedItems;
  final double percentage;

  const CategoryProgressSummary({
    required this.totalItems,
    required this.completedItems,
    required this.percentage,
  });
}

final categoryProgressProvider =
    FutureProvider.family.autoDispose<CategoryProgressSummary, String>((ref, categoryId) async {
  final items = await ref.watch(azkarItemsByCategoryProvider(categoryId).future);
  if (items.isEmpty) {
    return const CategoryProgressSummary(totalItems: 0, completedItems: 0, percentage: 0.0);
  }

  final completed = items.where((i) => i.isCompleted).length;
  final pct = (completed / items.length) * 100.0;
  return CategoryProgressSummary(
    totalItems: items.length,
    completedItems: completed,
    percentage: pct,
  );
});

// Azkar Actions
class AzkarActions {
  final Ref _ref;

  AzkarActions(this._ref);

  Future<void> incrementDhikr(AzkarItem item, String categoryId) async {
    if (item.currentCount >= item.repetitions) return;
    final repo = _ref.read(azkarRepositoryProvider);
    final newCount = item.currentCount + 1;
    await repo.updateItemCount(item.id, newCount);
    _ref.invalidate(azkarItemsByCategoryProvider(categoryId));
    _ref.invalidate(categoryProgressProvider(categoryId));
  }

  Future<void> resetDhikr(AzkarItem item, String categoryId) async {
    final repo = _ref.read(azkarRepositoryProvider);
    await repo.updateItemCount(item.id, 0);
    _ref.invalidate(azkarItemsByCategoryProvider(categoryId));
    _ref.invalidate(categoryProgressProvider(categoryId));
  }

  Future<void> resetCategory(String categoryId) async {
    final repo = _ref.read(azkarRepositoryProvider);
    final items = await repo.getItemsByCategory(categoryId);
    for (final i in items) {
      await repo.updateItemCount(i.id, 0);
    }
    _ref.invalidate(azkarItemsByCategoryProvider(categoryId));
    _ref.invalidate(categoryProgressProvider(categoryId));
  }
}

final azkarActionsProvider = Provider<AzkarActions>((ref) {
  return AzkarActions(ref);
});
