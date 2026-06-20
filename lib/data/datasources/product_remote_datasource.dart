import '../../core/network/dio_client.dart';
import '../../core/utils/app_exceptions.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts();
  Future<ProductModel> getProductById(int id);
  Future<List<String>> getCategories();
}

/// Talks to the FakeStore API via [DioClient]. Throws typed exceptions
/// ([ServerException]/[NetworkException]) on failure — never returns null
/// or swallows errors silently — so the repository layer can reliably
/// translate them into [Failure]s.
class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final DioClient dioClient;

  ProductRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<ProductModel>> getProducts() async {
    final response = await dioClient.get('/products');

    if (response.statusCode == 200) {
      final data = response.data as List<dynamic>;
      return data
          .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    throw const ServerException('Failed to load products');
  }

  @override
  Future<ProductModel> getProductById(int id) async {
    final response = await dioClient.get('/products/$id');

    if (response.statusCode == 200) {
      return ProductModel.fromJson(response.data as Map<String, dynamic>);
    }
    throw const ServerException('Failed to load product');
  }

  @override
  Future<List<String>> getCategories() async {
    final response = await dioClient.get('/products/categories');

    if (response.statusCode == 200) {
      final data = response.data as List<dynamic>;
      return data.map((e) => e.toString()).toList();
    }
    throw const ServerException('Failed to load categories');
  }
}
