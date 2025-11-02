import 'dart:convert';
import 'package:freenest/model/cart_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartService {
  static const String _cartKey = 'guest_cart';

  /// Save item to local cart
  static Future<void> addToCart(CartItemModel item) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cartList = prefs.getStringList(_cartKey) ?? [];

    // Check if item already exists
    List<CartItemModel> existingItems = await getCart();
    int existingIndex = existingItems.indexWhere((e) => e.id == item.id);

    if (existingIndex != -1) {
      // Update quantity if already present
      existingItems[existingIndex] = CartItemModel(
        id: item.id,
        name: item.name,
        quantity: existingItems[existingIndex].quantity + item.quantity,
        hourlyRate: item.hourlyRate,
        imageUrl: item.imageUrl,
      );
    } else {
      existingItems.add(item);
    }

    // Save updated cart
    final updatedList =
        existingItems.map((e) => jsonEncode(e.toMap())).toList();
    await prefs.setStringList(_cartKey, updatedList);
  }

  /// Get all cart items
  static Future<List<CartItemModel>> getCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartList = prefs.getStringList(_cartKey) ?? [];

    return cartList
        .map((e) => CartItemModel.fromMap(jsonDecode(e)))
        .toList();
  }

  /// Remove specific item by ID
  static Future<void> removeFromCart(String id) async {
    final prefs = await SharedPreferences.getInstance();
    List<CartItemModel> cart = await getCart();

    cart.removeWhere((item) => item.id == id);

    final updatedList = cart.map((e) => jsonEncode(e.toMap())).toList();
    await prefs.setStringList(_cartKey, updatedList);
  }

  /// Update quantity by ID
  static Future<void> updateQuantity(String id, int quantity) async {
    final prefs = await SharedPreferences.getInstance();
    List<CartItemModel> cart = await getCart();

    for (var i = 0; i < cart.length; i++) {
      if (cart[i].id == id) {
        cart[i] = CartItemModel(
          id: cart[i].id,
          name: cart[i].name,
          quantity: quantity,
          hourlyRate: cart[i].hourlyRate,
          imageUrl: cart[i].imageUrl,
        );
        break;
      }
    }

    final updatedList = cart.map((e) => jsonEncode(e.toMap())).toList();
    await prefs.setStringList(_cartKey, updatedList);
  }

  /// Clear cart
  static Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }
}
