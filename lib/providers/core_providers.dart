import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/network/dio_client.dart';
import '../data/datasources/cart_local_datasource.dart';
import '../data/datasources/product_remote_datasource.dart';
import '../data/repositories/cart_repository_impl.dart';
import '../data/repositories/product_repository_impl.dart';
import '../domain/repositories/cart_repository.dart';
import '../domain/repositories/product_repository.dart';

/// --- Core / infrastructure providers ---
///
/// These wire up the dependency graph: Dio -> remote data source ->
/// repository, and SharedPreferences -> local data source -> repository.
/// Everything downstream (UI, notifiers) depends only on the repository
/// *interfaces*, so swapping an implementation means changing only the
/// `Impl` returned here.

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});

/// [SharedPreferences.getInstance] is async, so we resolve it once in
/// `main()` (before `runApp`) and inject the instance via
/// `overrideWithValue` on this plain [Provider] — see main.dart. This
/// avoids every consumer having to handle a loading state just to read
/// the cart.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main() before runApp()',
  );
});

final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource>((ref) {
  return ProductRemoteDataSourceImpl(dioClient: ref.watch(dioClientProvider));
});

final cartLocalDataSourceProvider = Provider<CartLocalDataSource>((ref) {
  return CartLocalDataSourceImpl(
    sharedPreferences: ref.watch(sharedPreferencesProvider),
  );
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(
    remoteDataSource: ref.watch(productRemoteDataSourceProvider),
  );
});

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepositoryImpl(
    localDataSource: ref.watch(cartLocalDataSourceProvider),
  );
});
