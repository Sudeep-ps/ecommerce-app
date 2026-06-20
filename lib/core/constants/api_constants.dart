/// API endpoint constants.
///
/// We use the FakeStore API (https://fakestoreapi.com) as a free, public
/// mock backend so the app demonstrates a *real* network/JSON layer rather
/// than hard-coded local data. Swapping this for a production API later
/// only requires changing these constants + the response mapping in
/// [ProductModel.fromJson].
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://fakestoreapi.com';
  static const String products = '/products';
  static const String productById = '/products/'; // + id
  static const String categories = '/products/categories';
  static const String productsByCategory = '/products/category/'; // + category

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}

/// Keys used for SharedPreferences (local persistence).
class StorageKeys {
  StorageKeys._();

  static const String cartItems = 'CART_ITEMS_KEY';
  static const String themeMode = 'THEME_MODE_KEY';
}
