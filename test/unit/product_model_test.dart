import 'package:flutter_test/flutter_test.dart';

import 'package:ecommerce_app/data/models/product_model.dart';

void main() {
  group('ProductModel.fromJson', () {
    test('parses a complete, well-formed product JSON object', () {
      final json = {
        'id': 1,
        'title': 'Fjallraven Backpack',
        'price': 109.95,
        'description': 'Your perfect pack for everyday use.',
        'category': "men's clothing",
        'image': 'https://fakestoreapi.com/img/1.jpg',
        'rating': {'rate': 3.9, 'count': 120},
      };

      final model = ProductModel.fromJson(json);

      expect(model.id, 1);
      expect(model.title, 'Fjallraven Backpack');
      expect(model.price, 109.95);
      expect(model.description, 'Your perfect pack for everyday use.');
      expect(model.category, "men's clothing");
      expect(model.imageUrl, 'https://fakestoreapi.com/img/1.jpg');
      expect(model.rating, 3.9);
      expect(model.ratingCount, 120);
    });

    test('falls back to safe defaults when optional fields are missing', () {
      final json = {'id': 2};

      final model = ProductModel.fromJson(json);

      expect(model.id, 2);
      expect(model.title, 'Untitled product');
      expect(model.price, 0.0);
      expect(model.description, '');
      expect(model.category, 'misc');
      expect(model.imageUrl, '');
      expect(model.rating, 0.0);
      expect(model.ratingCount, 0);
    });

    test('coerces integer price into a double', () {
      final json = {
        'id': 3,
        'title': 'Cheap item',
        'price': 10, // int, not double — API can return either
        'description': 'desc',
        'category': 'misc',
        'image': 'https://example.com/img.jpg',
        'rating': {'rate': 4, 'count': 5},
      };

      final model = ProductModel.fromJson(json);

      expect(model.price, 10.0);
      expect(model.rating, 4.0);
    });

    test('toJson -> fromJson round-trips without data loss', () {
      const model = ProductModel(
        id: 5,
        title: 'Round Trip Product',
        price: 25.5,
        description: 'desc',
        category: 'electronics',
        imageUrl: 'https://example.com/x.jpg',
        rating: 4.2,
        ratingCount: 88,
      );

      final roundTripped = ProductModel.fromJson(model.toJson());

      expect(roundTripped.id, model.id);
      expect(roundTripped.title, model.title);
      expect(roundTripped.price, model.price);
      expect(roundTripped.category, model.category);
      expect(roundTripped.rating, model.rating);
      expect(roundTripped.ratingCount, model.ratingCount);
    });
  });
}
