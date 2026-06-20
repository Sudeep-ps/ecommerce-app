import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/quantity_stepper.dart';
import '../../../../domain/entities/product.dart';
import '../../../../providers/cart_provider.dart';
import '../../../../providers/product_detail_provider.dart';
import '../../../../providers/theme_provider.dart';
import '../../../cart/presentation/screens/cart_screen.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  /// Quantity selected *before* adding to cart (local UI state — distinct
  /// from the quantity already persisted in the cart for this product).
  int _selectedQuantity = 1;

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.productId));

    return productAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(),
        body: ErrorView(
          message: error.toString(),
          onRetry: () =>
              ref.invalidate(productDetailProvider(widget.productId)),
        ),
      ),
      data: (product) => Scaffold(
        body: _ProductDetailContent(
          product: product,
          selectedQuantity: _selectedQuantity,
          onQuantityChanged: (q) => setState(() => _selectedQuantity = q),
        ),
        bottomNavigationBar: ProductDetailBottomBar(
          product: product,
          selectedQuantity: _selectedQuantity,
          onQuantityChanged: (q) => setState(() => _selectedQuantity = q),
        ),
      ),
    );
  }
}

class _ProductDetailContent extends ConsumerWidget {
  final Product product;
  final int selectedQuantity;
  final ValueChanged<int> onQuantityChanged;

  const _ProductDetailContent({
    required this.product,
    required this.selectedQuantity,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final alreadyInCart = ref.watch(isInCartProvider(product.id));
    final cartQuantity = ref.watch(cartItemQuantityProvider(product.id));
    final totalCartCount = ref.watch(cartItemCountProvider);
    final themeMode = ref.watch(themeModeProvider);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 320,
          pinned: true,
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          leading: const BackButton(color: Colors.black),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    tooltip: AppStrings.myCart,
                    icon: const Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CartScreen()),
                      );
                    },
                  ),
                  if (totalCartCount > 0)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        constraints:
                            const BoxConstraints(minWidth: 18, minHeight: 18),
                        decoration: BoxDecoration(
                          color: colorScheme.error,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          totalCartCount > 99 ? '99+' : '$totalCartCount',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colorScheme.onError,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Hero(
              tag: 'product-image-${product.id}',
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(32, 80, 32, 32),
                child: CachedNetworkImage(
                  imageUrl: product.imageUrl,
                  fit: BoxFit.contain,
                  errorWidget: (context, url, error) => Icon(
                    Icons.image_not_supported_outlined,
                    size: 48,
                    color: colorScheme.outline,
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Chip(
                  label: Text(_capitalize(product.category)),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(height: 12),
                Text(
                  product.title,
                  style: textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.star_rounded,
                        size: 20, color: Colors.amber.shade600),
                    const SizedBox(width: 4),
                    Text(
                      '${product.rating} (${product.ratingCount} reviews)',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  AppStrings.description,
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  product.description,
                  style: textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (alreadyInCart) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          colorScheme.primaryContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_rounded,
                            color: colorScheme.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '$cartQuantity already in your cart',
                          style: textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _capitalize(String text) {
    return text
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}

/// Bottom action bar: quantity stepper + Add to Cart button. Built as a
/// separate widget passed into Scaffold.bottomNavigationBar-equivalent
/// area via a wrapper below, so it stays pinned while content scrolls.
class ProductDetailBottomBar extends ConsumerWidget {
  final Product product;
  final int selectedQuantity;
  final ValueChanged<int> onQuantityChanged;

  const ProductDetailBottomBar({
    super.key,
    required this.product,
    required this.selectedQuantity,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, 16 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
            top: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            QuantityStepper(
              quantity: selectedQuantity,
              onChanged: onQuantityChanged,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FilledButton.icon(
                onPressed: () async {
                  await ref.read(cartProvider.notifier).addToCart(
                        product,
                        quantity: selectedQuantity,
                      );

                  if (context.mounted) {
                    Fluttertoast.showToast(msg: AppStrings.addedToCart);
                  }
                },
                icon: const Icon(Icons.shopping_cart_rounded),
                label: const Text(AppStrings.addToCart),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
