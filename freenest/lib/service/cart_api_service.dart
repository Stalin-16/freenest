import 'package:freenest/config/app_config.dart';
import 'package:freenest/model/cart_model.dart';
import 'package:freenest/model/common_reponse.dart';
import 'package:freenest/networking/api_base_helper.dart';

class CartApiService {
  static final ApiBaseHelper _api = ApiBaseHelper();
   static  String baseUrl = AppConfig.customerAPI;

   Future<CartItemModel?> addToCart(Map<String, dynamic> item) async {
    try {
      final response = await _api.post(
        "$baseUrl/cart/add",
        item
      );

      final result = CommonResponseModel.fromMap(response);

      if (result.status == 200 && result.data != null) {
        // Assuming API returns the added cart item as 'item' or inside 'data'
        final cartItemData = result.data['item'] ?? result.data;
        return CartItemModel.fromMap(cartItemData);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<List<CartItemModel>> getCart() async {
    final response = await _api.get ("$baseUrl/cart/get");

    final result = CommonResponseModel.fromMap(response);

    if (result.status == 200 && result.data != null) {
      final List<dynamic> cartList = result.data['cart'] ?? [];
      return cartList
          .map((item) => CartItemModel.fromMap(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  static Future<CommonResponseModel> syncCart(
      List<Map<String, dynamic>> cart) async {
    final body = {"cart": cart};
    final response = await _api.post("$baseUrl/cart/sync", body);
    return CommonResponseModel.fromMap(response);
  }

  static Future<CommonResponseModel> updateQuantity(
      String productId, int newQuantity) async {
    final body = {
      "productId": productId,
      "quantity": newQuantity,
    };
    final response = await _api.post("/cart/update", body);
    return CommonResponseModel.fromMap(response);
  }

  static Future<CommonResponseModel> removeFromCart(String productId) async {
    final response = await _api.post("/cart/remove", {"productId": productId});
    return CommonResponseModel.fromMap(response);
  }

  static Future<CommonResponseModel> checkout() async {
    const data={};
    final response = await _api.post("$baseUrl/cart/checkout",data);
    return CommonResponseModel.fromMap(response);
  }
}
