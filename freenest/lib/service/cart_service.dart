import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CartService {
  static const String _cartKey = 'guest_cart';

  /// Save item to local cart
  static Future<void> addToCart(Map<String, dynamic> item) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cartList = prefs.getStringList(_cartKey) ?? [];

    cartList.add(jsonEncode(item));
    await prefs.setStringList(_cartKey, cartList);
  }

  /// Get all cart items
  static Future<List<Map<String, dynamic>>> getCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartList = prefs.getStringList(_cartKey) ?? [];
    return cartList.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  /// Remove specific item
  static Future<void> removeFromCart(String title) async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> cart = await getCart();
    cart.removeWhere((item) => item['title'] == title);
    final updatedList = cart.map((e) => jsonEncode(e)).toList();
    await prefs.setStringList(_cartKey, updatedList);
  }

  /// Clear cart
  static Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }
}
