import 'dart:convert';
import 'package:freenest/config/app_config.dart';
import 'package:freenest/model/common_reponse.dart';
import 'package:freenest/networking/api_base_helper.dart';
import 'package:http/http.dart' as http;

const baseUrl = AppConfig.baseUrl;

class AuthService {
  final ApiBaseHelper _helper = ApiBaseHelper();
  Future<CommonResponseModel> sendOtp(String email, String name) async {
    final res = await _helper.postWithoutToken(
      "${AppConfig.oauthAPI}/send-otp",
      {"email": email, "name": name},
    );
    return CommonResponseModel.fromMap(res);
  }

  Future<CommonResponseModel> verifyOtp(String email, String otp) async {
    final res = await _helper.postWithoutToken(
      "${AppConfig.oauthAPI}/verify-otp",
      {'email': email, 'otp': otp},
    );
    return CommonResponseModel.fromMap(res);
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

  Future<CommonResponseModel> guestLogin() async {
    try {
      final res = await _helper.postWithoutToken(
        "${AppConfig.oauthAPI}/guest-login",
        {},
      );
      return CommonResponseModel.fromMap(res);
    } catch (e) {
      throw Exception("Guest login failed: $e");
    }
  }
}
