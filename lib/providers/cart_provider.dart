import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/cart_item.dart';
import '../domain/entities/product.dart';
import 'core_providers.dart';

/// Manages the shopping cart: in-memory state + automatic persistence to
/// local storage on every mutation.
///
/// We extend [AsyncNotifier] rather than plain [Notifier] because the
/// *initial* load is async (reading from SharedPreferences), so consumers
/// naturally get a loading state on first build via [AsyncValue] instead of
/// us inventing a separate `isLoading` flag.
class CartNotifier extends AsyncNotifier<List<CartItem>> {
  @override
  Future<List<CartItem>> build() async {
    final repository = ref.watch(cartRepositoryProvider);
    final result = await repository.getCartItems();
    return result.fold(
      (failure) => <CartItem>[], // Fail soft: empty cart rather than crashing the app.
      (items) => items,
    );
  }

  Future<void> _persist(List<CartItem> items) async {
    final repository = ref.read(cartRepositoryProvider);
    await repository.saveCartItems(items);
  }

  /// Adds [product] to the cart. If it already exists, increments its
  /// quantity by [quantity] instead of creating a duplicate line item.
  Future<void> addToCart(Product product, {int quantity = 1}) async {
    final currentItems = state.valueOrNull ?? [];
    final existingIndex = currentItems.indexWhere((item) => item.product.id == product.id);

    List<CartItem> updatedItems;
    if (existingIndex >= 0) {
      updatedItems = [...currentItems];
      final existing = updatedItems[existingIndex];
      updatedItems[existingIndex] = existing.copyWith(quantity: existing.quantity + quantity);
    } else {
      updatedItems = [...currentItems, CartItem(product: product, quantity: quantity)];
    }

    state = AsyncData(updatedItems);
    await _persist(updatedItems);
  }

  /// Sets the exact quantity for [productId]. Quantities <= 0 remove the item.
  Future<void> updateQuantity(int productId, int newQuantity) async {
    final currentItems = state.valueOrNull ?? [];

    List<CartItem> updatedItems;
    if (newQuantity <= 0) {
      updatedItems = currentItems.where((item) => item.product.id != productId).toList();
    } else {
      updatedItems = currentItems.map((item) {
        if (item.product.id == productId) {
          return item.copyWith(quantity: newQuantity);
        }
        return item;
      }).toList();
    }

    state = AsyncData(updatedItems);
    await _persist(updatedItems);
  }

  Future<void> removeFromCart(int productId) async {
    final currentItems = state.valueOrNull ?? [];
    final updatedItems = currentItems.where((item) => item.product.id != productId).toList();

    state = AsyncData(updatedItems);
    await _persist(updatedItems);
  }

  Future<void> clearCart() async {
    state = const AsyncData([]);
    await _persist([]);
  }
}

final cartProvider = AsyncNotifierProvider<CartNotifier, List<CartItem>>(() {
  return CartNotifier();
});

/// --- Derived/computed providers ---
/// Keeping these separate (rather than computing inline in widgets) means
/// any screen can watch just "cartItemCount", say, and only rebuild when
/// the *count* changes — not on every cart mutation.

const double _taxRate = 0.05;
const double _freeShippingThreshold = 50.0;
const double _shippingFee = 5.99;

final cartItemCountProvider = Provider<int>((ref) {
  final items = ref.watch(cartProvider).valueOrNull ?? [];
  return items.fold<int>(0, (sum, item) => sum + item.quantity);
});

final cartSubtotalProvider = Provider<double>((ref) {
  final items = ref.watch(cartProvider).valueOrNull ?? [];
  return items.fold<double>(0, (sum, item) => sum + item.totalPrice);
});

final cartTaxProvider = Provider<double>((ref) {
  final subtotal = ref.watch(cartSubtotalProvider);
  return subtotal * _taxRate;
});

final cartShippingProvider = Provider<double>((ref) {
  final subtotal = ref.watch(cartSubtotalProvider);
  if (subtotal == 0 || subtotal >= _freeShippingThreshold) return 0.0;
  return _shippingFee;
});

final cartTotalProvider = Provider<double>((ref) {
  final subtotal = ref.watch(cartSubtotalProvider);
  final tax = ref.watch(cartTaxProvider);
  final shipping = ref.watch(cartShippingProvider);
  return subtotal + tax + shipping;
});

/// Whether a specific product is currently in the cart, used to flip the
/// "Add to Cart" button into a quantity stepper on the detail screen.
final isInCartProvider = Provider.family<bool, int>((ref, productId) {
  final items = ref.watch(cartProvider).valueOrNull ?? [];
  return items.any((item) => item.product.id == productId);
});

final cartItemQuantityProvider = Provider.family<int, int>((ref, productId) {
  final items = ref.watch(cartProvider).valueOrNull ?? [];
  final match = items.where((item) => item.product.id == productId);
  return match.isEmpty ? 0 : match.first.quantity;
});
