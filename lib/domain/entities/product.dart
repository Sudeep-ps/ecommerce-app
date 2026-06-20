import 'package:equatable/equatable.dart';

/// Pure domain entity for a Product — has no knowledge of JSON, APIs, or
/// persistence. This is what the UI and business logic work with.
///
/// Kept separate from [ProductModel] (data layer) so that changes to the
/// API response shape never ripple into widgets/providers.
class Product extends Equatable {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String imageUrl;
  final double rating;
  final int ratingCount;

  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.rating,
    required this.ratingCount,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        price,
        description,
        category,
        imageUrl,
        rating,
        ratingCount,
      ];
}
