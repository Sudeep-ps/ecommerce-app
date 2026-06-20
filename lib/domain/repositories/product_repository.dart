import 'package:dartz/dartz.dart';

import '../../core/utils/failure.dart';
import '../entities/product.dart';

/// Contract for fetching product data, independent of *how* it's fetched
/// (REST, GraphQL, local DB...). The presentation layer (providers) depends
/// only on this abstraction, never on [ProductRepositoryImpl] directly —
/// classic dependency inversion, and it's what makes the providers trivially
/// unit-testable with a fake/mock repository.
abstract class ProductRepository {
  /// Returns all products, or a [Failure] on error.
  Future<Either<Failure, List<Product>>> getProducts();

  /// Returns a single product by [id].
  Future<Either<Failure, Product>> getProductById(int id);

  /// Returns the list of distinct category names.
  Future<Either<Failure, List<String>>> getCategories();
}
