import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ecommerce_app/core/utils/failure.dart';
import 'package:ecommerce_app/domain/entities/cart_item.dart';
import 'package:ecommerce_app/domain/entities/product.dart';
import 'package:ecommerce_app/domain/repositories/cart_repository.dart';
import 'package:ecommerce_app/domain/repositories/product_repository.dart';
import 'package:ecommerce_app/features/product_list/presentation/screens/product_list_screen.dart';
import 'package:ecommerce_app/providers/core_providers.dart';

class MockProductRepository extends Mock implements ProductRepository {}

class MockCartRepository extends Mock implements CartRepository {}

const _products = [
  Product(
    id: 1,
    title: 'Wireless Headphones',
    price: 49.99,
    description: 'Noise cancelling over-ear headphones',
    category: 'electronics',
    imageUrl: 'https://example.com/headphones.jpg',
    rating: 4.5,
    ratingCount: 200,
  ),
  Product(
    id: 2,
    title: 'Running Shoes',
    price: 79.99,
    description: 'Lightweight running shoes',
    category: 'footwear',
    imageUrl: 'https://example.com/shoes.jpg',
    rating: 4.2,
    ratingCount: 150,
  ),
];

void main() {
  late MockProductRepository mockProductRepository;
  late MockCartRepository mockCartRepository;
  late SharedPreferences sharedPreferences;

  setUp(() async {
    mockProductRepository = MockProductRepository();
    mockCartRepository = MockCartRepository();

    when(() => mockProductRepository.getProducts())
        .thenAnswer((_) async => const Right(_products));
    when(() => mockCartRepository.getCartItems())
        .thenAnswer((_) async => const Right(<CartItem>[]));

    // themeModeProvider reads sharedPreferencesProvider on first build, so
    // every widget that touches the AppBar (which all of them do here)
    // needs a real-but-in-memory SharedPreferences instance available.
    SharedPreferences.setMockInitialValues({});
    sharedPreferences = await SharedPreferences.getInstance();
  });

  Widget buildTestApp() {
    return ProviderScope(
      overrides: [
        productRepositoryProvider.overrideWithValue(mockProductRepository),
        cartRepositoryProvider.overrideWithValue(mockCartRepository),
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const MaterialApp(home: ProductListScreen()),
    );
  }

  testWidgets('shows a shimmer loader, then renders fetched products', (tester) async {
    await tester.pumpWidget(buildTestApp());

    // First frame: loading shimmer should be present, no product titles yet.
    expect(find.text('Wireless Headphones'), findsNothing);

    // Let the FutureProvider resolve and the UI rebuild.
    await tester.pumpAndSettle();

    expect(find.text('Wireless Headphones'), findsOneWidget);
    expect(find.text('Running Shoes'), findsOneWidget);
  });

  testWidgets('typing in the search field filters the visible products', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Wireless Headphones'), findsOneWidget);
    expect(find.text('Running Shoes'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Running');
    await tester.pumpAndSettle();

    expect(find.text('Running Shoes'), findsOneWidget);
    expect(find.text('Wireless Headphones'), findsNothing);
  });

  testWidgets('shows empty state when search matches nothing', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'nonexistent product xyz');
    await tester.pumpAndSettle();

    expect(find.text('No products found'), findsOneWidget);
  });
}
