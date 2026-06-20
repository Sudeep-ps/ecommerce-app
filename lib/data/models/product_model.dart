import '../../domain/entities/product.dart';

/// Data-layer representation of a product, matching the FakeStore API
/// (https://fakestoreapi.com/products) response shape:
///
/// ```json
/// {
///   "id": 1,
///   "title": "...",
///   "price": 109.95,
///   "description": "...",
///   "category": "men's clothing",
///   "image": "https://...",
///   "rating": { "rate": 3.9, "count": 120 }
/// }
/// ```
///
/// [ProductModel] knows how to parse JSON; [toEntity] converts it into the
/// transport-agnostic [Product] used everywhere else in the app.
class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.title,
    required super.price,
    required super.description,
    required super.category,
    required super.imageUrl,
    required super.rating,
    required super.ratingCount,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final ratingJson = json['rating'] as Map<String, dynamic>?;

    return ProductModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? 'Untitled product',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'misc',
      imageUrl: json['image'] as String? ?? '',
      rating: (ratingJson?['rate'] as num?)?.toDouble() ?? 0.0,
      ratingCount: (ratingJson?['count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'description': description,
      'category': category,
      'image': imageUrl,
      'rating': {'rate': rating, 'count': ratingCount},
    };
  }

  Product toEntity() => Product(
        id: id,
        title: title,
        price: price,
        description: description,
        category: category,
        imageUrl: imageUrl,
        rating: rating,
        ratingCount: ratingCount,
      );
}
