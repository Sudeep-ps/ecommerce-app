import 'package:dartz/dartz.dart';

import '../../core/utils/failure.dart';
import '../entities/cart_item.dart';

/// Contract for persisting/retrieving the shopping cart.
///
/// Implemented with SharedPreferences for this test, but any local DB
/// (Hive, Isar, sqflite) could implement this same interface without the
/// cart provider knowing or caring.
abstract class CartRepository {
  Future<Either<Failure, List<CartItem>>> getCartItems();
  Future<Either<Failure, void>> saveCartItems(List<CartItem> items);
}
