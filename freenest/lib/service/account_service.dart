import 'package:freenest/config/app_config.dart';
import 'package:freenest/model/common_reponse.dart';
import 'package:freenest/model/user_trasaction_model.dart';

import 'package:freenest/networking/api_base_helper.dart';

class AccountService {
  static final ApiBaseHelper _api = ApiBaseHelper();
  static String baseUrl = AppConfig.customerAPI;

  Future<CommonResponseModel> getTransactions(int page, int limit) async {
    try {
      final response = await _api.get(
          "$baseUrl/credits/get-transaction-summaries?page=$page&limit=$limit");
      if (response != null && response['status'] == 200) {
        return CommonResponseModel.fromMap(response);
      } else {
        // You might want to handle error cases differently
        return CommonResponseModel.fromMap(response);
      }
    } catch (e) {
      throw Exception("Failed to fetch transactions: $e");
    }
  }

  // Get current balance
  Future<CommonResponseModel> getCurrentBalance() async {
    try {
      final response = await _api.get("$baseUrl/credits/balance");

      if (response['success'] == true) {
        return CommonResponseModel.fromMap(response);
      } else {
        return CommonResponseModel.fromMap(response);
      }
    } catch (e) {
      throw Exception("Failed to fetch balance: $e");
    }
  }

  //Update User
  Future<CommonResponseModel> updateUser(Map<String, dynamic> data) async {
    try {
      final response =
          await _api.put("$baseUrl/credits/profile-customer", data);
      if (response['status'] == 200) {
        return CommonResponseModel.fromMap(response);
      } else {
        return CommonResponseModel.fromMap(response);
      }
    } catch (e) {
      throw Exception("Failed to update user: $e");
    }
  }
}
