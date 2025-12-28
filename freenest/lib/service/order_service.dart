import 'package:freenest/config/app_config.dart';
import 'package:freenest/model/common_reponse.dart';
import 'package:freenest/model/order_model.dart';
import 'package:freenest/networking/api_base_helper.dart';

class OrderApiService {
  static final ApiBaseHelper _api = ApiBaseHelper();
  static String baseUrl = AppConfig.customerAPI;
  static Future<List<OrderModel>> getOrders() async {
    final res = await _api.get('$baseUrl/order/get-all-orders');

    // If using CommonResponseModel
    final result = CommonResponseModel.fromMap(res);

    if (result.status == 200) {
      final data = result.data;

      // Handle both object and list
      if (data is Map<String, dynamic>) {
        return [OrderModel.fromMap(data)];
      } else if (data is List) {
        return data.map((e) => OrderModel.fromMap(e)).toList();
      } else {
        throw Exception("Unexpected data format: ${data.runtimeType}");
      }
    } else {
      throw Exception("Failed to fetch orders: ${result.message}");
    }
  }
}
