import 'dart:convert';
import 'package:freenest/config/app_config.dart';
import 'package:freenest/model/common_reponse.dart';
import 'package:freenest/networking/api_base_helper.dart';
import 'package:http/http.dart' as http;

const baseUrl = AppConfig.baseUrl;

class AuthService {
  final ApiBaseHelper _helper = ApiBaseHelper();
  Future<Map<String, dynamic>> sendOtp(String email) async {
    final res = await _helper.post(
      "/send-otp",
      jsonEncode({'email': email}),
    );
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    final res = await http.post(
      Uri.parse('$baseUrl/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'otp': otp}),
    );
    return jsonDecode(res.body);
  }

Future<CommonResponseModel> googleLogin(
    String email, String googleId, String? name) async {
  try {
    final res = await _helper.postWithoutToken(
      "${AppConfig.oauthAPI}/google-login",
      {"email": email, "googleId": googleId, "user_name": name},
    );
    return CommonResponseModel.fromMap(res);
  } catch (e) {
    throw Exception("Google login failed: $e");
  }
}
}