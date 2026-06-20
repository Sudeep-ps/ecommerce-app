import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/api_constants.dart';
import '../../core/utils/app_exceptions.dart';
import '../models/cart_item_model.dart';

abstract class CartLocalDataSource {
  Future<List<CartItemModel>> getCartItems();
  Future<void> saveCartItems(List<CartItemModel> items);
}

/// Persists the cart as a JSON string under [StorageKeys.cartItems] in
/// SharedPreferences. Simple and dependency-light, which is appropriate for
/// cart data (small, doesn't need querying) — a heavier app might reach for
/// Hive/Isar/sqflite instead, but the [CartRepository] abstraction means
/// that swap wouldn't touch any other layer.
class CartLocalDataSourceImpl implements CartLocalDataSource {
  final SharedPreferences sharedPreferences;

  CartLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<CartItemModel>> getCartItems() async {
    try {
      final jsonString = sharedPreferences.getString(StorageKeys.cartItems);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded
          .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw const CacheException('Failed to read cart from local storage');
    }
  }

  @override
  Future<void> saveCartItems(List<CartItemModel> items) async {
    try {
      final jsonString = jsonEncode(items.map((e) => e.toJson()).toList());
      final success = await sharedPreferences.setString(StorageKeys.cartItems, jsonString);
      if (!success) {
        throw const CacheException('Failed to write cart to local storage');
      }
    } catch (e) {
      throw const CacheException('Failed to save cart to local storage');
    }
  }
}
