import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/failure.dart';
import '../domain/entities/product.dart';
import 'core_providers.dart';

/// Fetches the full product list once. Using [FutureProvider] (rather than
/// re-fetching per filter) means search/category filtering below is pure,
/// client-side, and instant — no extra network calls as the user types.
final productListProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  final result = await repository.getProducts();

  return result.fold(
    (failure) => throw _FailureException(failure),
    (products) => products,
  );
});

/// Distinct category names, derived from the same data so we never issue a
/// second network request just to populate a filter chip row.
final categoryListProvider = Provider<List<String>>((ref) {
  final productsAsync = ref.watch(productListProvider);
  return productsAsync.maybeWhen(
    data: (products) {
      final categories = products.map((p) => p.category).toSet().toList()..sort();
      return categories;
    },
    orElse: () => [],
  );
});

/// Current search query, set by the search bar on the product list screen.
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Currently selected category filter chip ('' = All).
final selectedCategoryProvider = StateProvider<String>((ref) => '');

/// Derived, filtered product list — combines the raw fetched list with the
/// current search query and category selection. Recomputes automatically
/// whenever any of its dependencies change, with no manual wiring needed.
final filteredProductListProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final productsAsync = ref.watch(productListProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final category = ref.watch(selectedCategoryProvider);

  return productsAsync.whenData((products) {
    return products.where((p) {
      final matchesQuery = query.isEmpty || p.title.toLowerCase().contains(query);
      final matchesCategory = category.isEmpty || p.category == category;
      return matchesQuery && matchesCategory;
    }).toList();
  });
});

/// Wraps a [Failure] as an [Exception] so it can flow through
/// [FutureProvider]'s native AsyncValue.error state, letting the UI use
/// `.when(error: ...)` directly instead of manually unwrapping Either here.
class _FailureException implements Exception {
  final Failure failure;
  _FailureException(this.failure);

  @override
  String toString() => failure.message;
}
