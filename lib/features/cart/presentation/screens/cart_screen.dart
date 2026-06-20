import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../providers/cart_provider.dart';
import '../widgets/cart_item_tile.dart';
import '../widgets/order_summary_card.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.myCart),
        actions: [
          cartAsync.maybeWhen(
            data: (items) => items.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    tooltip: AppStrings.clearCart,
                    icon: const Icon(Icons.delete_sweep_outlined),
                    onPressed: () => unawaited(_confirmClearCart(context, ref)),
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: cartAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text(error.toString()),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyStateView(
              icon: Icons.shopping_cart_outlined,
              title: AppStrings.emptyCartTitle,
              subtitle: AppStrings.emptyCartSubtitle,
            );
          }

          final subtotal = ref.watch(cartSubtotalProvider);
          final tax = ref.watch(cartTaxProvider);
          final shipping = ref.watch(cartShippingProvider);
          final total = ref.watch(cartTotalProvider);

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return CartItemTile(
                      cartItem: item,
                      onQuantityChanged: (newQty) {
                        // Fire-and-forget: the stepper callback is sync, and
                        // CartNotifier already updates UI state immediately
                        // before persisting, so there's nothing to await here.
                        unawaited(
                          ref
                              .read(cartProvider.notifier)
                              .updateQuantity(item.product.id, newQty),
                        );
                      },
                      onRemove: () {
                        unawaited(
                          ref.read(cartProvider.notifier).removeFromCart(item.product.id),
                        );
                        Fluttertoast.showToast(msg: '${item.product.title} removed');
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  0,
                  16,
                  16 + MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  children: [
                    OrderSummaryCard(
                      subtotal: subtotal,
                      tax: tax,
                      shipping: shipping,
                      total: total,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => unawaited(_checkout(context, ref)),
                        child: const Text(AppStrings.checkout),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmClearCart(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.clearCart),
        content: const Text('Remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(AppStrings.clearCart),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(cartProvider.notifier).clearCart();
    }
  }

  /// This is a mock checkout for the purposes of the assignment — there's
  /// no real payment/order API to call against. In a production app this
  /// would call a checkout endpoint and navigate to an order confirmation
  /// screen instead of just clearing the cart locally.
  Future<void> _checkout(BuildContext context, WidgetRef ref) async {
    await ref.read(cartProvider.notifier).clearCart();

    if (context.mounted) {
      Fluttertoast.showToast(msg: AppStrings.checkoutSuccess);
      Navigator.of(context).pop();
    }
  }
}
