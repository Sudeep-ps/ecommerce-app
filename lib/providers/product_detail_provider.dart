import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/product.dart';
import 'core_providers.dart';
import 'product_providers.dart';

/// Fetches a single product detail by id.
///
/// `.family` lets each product detail screen have its own independently
/// cached [AsyncValue], keyed by [id] — navigating between two product
/// detail pages doesn't cause one to clobber the other's cache.
final productDetailProvider = FutureProvider.family<Product, int>((ref, id) async {
  // Optimization: if we already fetched the full list (very likely, since
  // the user navigated here from the list screen), reuse it instead of
  // firing a redundant network call.
  final cachedList = ref.read(productListProvider).valueOrNull;
  if (cachedList != null) {
    final match = cachedList.where((p) => p.id == id).toList();
    if (match.isNotEmpty) return match.first;
  }

  final repository = ref.watch(productRepositoryProvider);
  final result = await repository.getProductById(id);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (product) => product,
  );
});
