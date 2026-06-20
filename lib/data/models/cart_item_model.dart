import '../../domain/entities/cart_item.dart';
import 'product_model.dart';

/// JSON-serializable wrapper around [CartItem] for SharedPreferences
/// persistence. We store the cart as a JSON-encoded list of these.
class CartItemModel extends CartItem {
  const CartItemModel({
    required ProductModel product,
    required super.quantity,
  }) : super(product: product);

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int? ?? 1,
    );
  }

  factory CartItemModel.fromEntity(CartItem item) {
    final p = item.product;
    return CartItemModel(
      product: ProductModel(
        id: p.id,
        title: p.title,
        price: p.price,
        description: p.description,
        category: p.category,
        imageUrl: p.imageUrl,
        rating: p.rating,
        ratingCount: p.ratingCount,
      ),
      quantity: item.quantity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': (product as ProductModel).toJson(),
      'quantity': quantity,
    };
  }
}
