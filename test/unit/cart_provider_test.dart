import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ecommerce_app/core/utils/failure.dart';
import 'package:ecommerce_app/domain/entities/cart_item.dart';
import 'package:ecommerce_app/domain/entities/product.dart';
import 'package:ecommerce_app/domain/repositories/cart_repository.dart';
import 'package:ecommerce_app/providers/cart_provider.dart';
import 'package:ecommerce_app/providers/core_providers.dart';

class MockCartRepository extends Mock implements CartRepository {}

const _testProductA = Product(
  id: 1,
  title: 'Test Product A',
  price: 10.0,
  description: 'desc',
  category: 'misc',
  imageUrl: 'https://example.com/a.jpg',
  rating: 4.0,
  ratingCount: 10,
);

const _testProductB = Product(
  id: 2,
  title: 'Test Product B',
  price: 25.5,
  description: 'desc',
  category: 'misc',
  imageUrl: 'https://example.com/b.jpg',
  rating: 4.5,
  ratingCount: 20,
);

void main() {
  late MockCartRepository mockRepository;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(<CartItem>[]);
  });

  setUp(() {
    mockRepository = MockCartRepository();

    // Default stubs: empty cart on load, saves always succeed.
    when(() => mockRepository.getCartItems())
        .thenAnswer((_) async => const Right(<CartItem>[]));
    when(() => mockRepository.saveCartItems(any()))
        .thenAnswer((_) async => const Right(null));

    container = ProviderContainer(
      overrides: [
        cartRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('CartNotifier', () {
    test('initial state loads cart items from repository', () async {
      final items = await container.read(cartProvider.future);
      expect(items, isEmpty);
      verify(() => mockRepository.getCartItems()).called(1);
    });

    test('addToCart adds a new product with default quantity 1', () async {
      await container.read(cartProvider.future); // ensure loaded

      await container.read(cartProvider.notifier).addToCart(_testProductA);

      final state = container.read(cartProvider).valueOrNull;
      expect(state, hasLength(1));
      expect(state!.first.product.id, _testProductA.id);
      expect(state.first.quantity, 1);

      verify(() => mockRepository.saveCartItems(any())).called(1);
    });

    test('addToCart with explicit quantity sets that quantity', () async {
      await container.read(cartProvider.future);

      await container.read(cartProvider.notifier).addToCart(_testProductA, quantity: 3);

      final state = container.read(cartProvider).valueOrNull;
      expect(state!.first.quantity, 3);
    });

    test('addToCart on an existing product increments quantity instead of duplicating', () async {
      await container.read(cartProvider.future);

      final notifier = container.read(cartProvider.notifier);
      await notifier.addToCart(_testProductA, quantity: 2);
      await notifier.addToCart(_testProductA, quantity: 3);

      final state = container.read(cartProvider).valueOrNull;
      expect(state, hasLength(1)); // still one line item
      expect(state!.first.quantity, 5); // 2 + 3
    });

    test('updateQuantity changes the quantity of an existing item', () async {
      await container.read(cartProvider.future);
      final notifier = container.read(cartProvider.notifier);

      await notifier.addToCart(_testProductA, quantity: 1);
      await notifier.updateQuantity(_testProductA.id, 7);

      final state = container.read(cartProvider).valueOrNull;
      expect(state!.first.quantity, 7);
    });

    test('updateQuantity with 0 or below removes the item entirely', () async {
      await container.read(cartProvider.future);
      final notifier = container.read(cartProvider.notifier);

      await notifier.addToCart(_testProductA, quantity: 1);
      await notifier.updateQuantity(_testProductA.id, 0);

      final state = container.read(cartProvider).valueOrNull;
      expect(state, isEmpty);
    });

    test('removeFromCart removes only the targeted product', () async {
      await container.read(cartProvider.future);
      final notifier = container.read(cartProvider.notifier);

      await notifier.addToCart(_testProductA);
      await notifier.addToCart(_testProductB);
      await notifier.removeFromCart(_testProductA.id);

      final state = container.read(cartProvider).valueOrNull;
      expect(state, hasLength(1));
      expect(state!.first.product.id, _testProductB.id);
    });

    test('clearCart empties the cart and persists the empty list', () async {
      await container.read(cartProvider.future);
      final notifier = container.read(cartProvider.notifier);

      await notifier.addToCart(_testProductA);
      await notifier.addToCart(_testProductB);
      await notifier.clearCart();

      final state = container.read(cartProvider).valueOrNull;
      expect(state, isEmpty);
    });

    test('a repository failure on load results in an empty cart, not a crash', () async {
      final failingRepository = MockCartRepository();
      when(() => failingRepository.getCartItems())
          .thenAnswer((_) async => const Left(CacheFailure('boom')));

      final failingContainer = ProviderContainer(
        overrides: [
          cartRepositoryProvider.overrideWithValue(failingRepository),
        ],
      );
      addTearDown(failingContainer.dispose);

      final items = await failingContainer.read(cartProvider.future);
      expect(items, isEmpty);
    });
  });

  group('Derived cart providers', () {
    test('cartItemCountProvider sums quantities across all line items', () async {
      await container.read(cartProvider.future);
      final notifier = container.read(cartProvider.notifier);

      await notifier.addToCart(_testProductA, quantity: 2);
      await notifier.addToCart(_testProductB, quantity: 3);

      expect(container.read(cartItemCountProvider), 5);
    });

    test('cartSubtotalProvider sums (price * quantity) across all items', () async {
      await container.read(cartProvider.future);
      final notifier = container.read(cartProvider.notifier);

      await notifier.addToCart(_testProductA, quantity: 2); // 10.0 * 2 = 20.0
      await notifier.addToCart(_testProductB, quantity: 1); // 25.5 * 1 = 25.5

      expect(container.read(cartSubtotalProvider), 45.5);
    });

    test('cartShippingProvider is free once subtotal crosses the threshold', () async {
      await container.read(cartProvider.future);
      final notifier = container.read(cartProvider.notifier);

      // Below $50 threshold -> shipping fee applies.
      await notifier.addToCart(_testProductA, quantity: 1); // $10
      expect(container.read(cartShippingProvider), greaterThan(0));

      // Push subtotal over $50 -> free shipping.
      await notifier.addToCart(_testProductB, quantity: 2); // +$51 = $61 total
      expect(container.read(cartShippingProvider), 0.0);
    });

    test('cartTotalProvider equals subtotal + tax + shipping', () async {
      await container.read(cartProvider.future);
      final notifier = container.read(cartProvider.notifier);
      await notifier.addToCart(_testProductA, quantity: 1);

      final subtotal = container.read(cartSubtotalProvider);
      final tax = container.read(cartTaxProvider);
      final shipping = container.read(cartShippingProvider);
      final total = container.read(cartTotalProvider);

      expect(total, closeTo(subtotal + tax + shipping, 0.0001));
    });

    test('isInCartProvider reflects current membership', () async {
      await container.read(cartProvider.future);
      final notifier = container.read(cartProvider.notifier);

      expect(container.read(isInCartProvider(_testProductA.id)), isFalse);

      await notifier.addToCart(_testProductA);

      expect(container.read(isInCartProvider(_testProductA.id)), isTrue);
      expect(container.read(isInCartProvider(_testProductB.id)), isFalse);
    });
  });
}
