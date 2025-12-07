import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:freenest/config/navigation_helper.dart';
import 'package:freenest/model/token_model.dart';
import 'package:freenest/model/user_model.dart';
import 'package:freenest/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Future<SharedPreferences> _storage = SharedPreferences.getInstance();

class SharedService {
  static Future<void> setToken(token) async {
    final SharedPreferences storage = await _storage;
    storage.setString("token", token!.toJson());
  }

  static Future<void> reload() async {
    final SharedPreferences storage = await _storage;
    await storage.reload();
  }

  static Future<void> setString(key, value) async {
    final SharedPreferences storage = await _storage;
    if (value.runtimeType == String) {
      storage.setString(key, value);
    } else {
      storage.setString(key, jsonEncode(value));
    }
  }

  static Future<String?> getString(key) async {
    final SharedPreferences storage = await _storage;
    var value = storage.getString(key);
    return value;
  }

  static Future<bool> remove(key) async {
    final SharedPreferences storage = await _storage;
    return storage.remove(key);
  }

  static Future<void> setStringList(key, List<dynamic> value) async {
    final SharedPreferences storage = await _storage;
    List<String> val = value
        .map((e) => e.runtimeType == String ? e.toString() : jsonEncode(e))
        .toList();
    storage.setStringList(key, val);
  }

  static Future<List<String>?> getStringList(key) async {
    final SharedPreferences storage = await _storage;
    List<String>? value = storage.getStringList(key);
    return value;
  }

  static Future<int?> getUserId() async {
    final SharedPreferences storage = await _storage;
    var user = storage.getString("user");
    return user != null ? UserModel.fromJson(user).id : null;
  }

  static Future<TokenModel?> getToken() async {
    final SharedPreferences storage = await _storage;
    var token = storage.getString("token");
    if (token == null) {
      SharedService.logggedOutWithOutContext();
    }
    return token != null ? TokenModel.fromJson(token) : null;
  }

  static Future<void> setUser(UserModel? userModel) async {
    if (userModel != null) {
      final SharedPreferences storage = await _storage;
      storage.setString("user", userModel.toJson());
    }
  }

  // static Future<void> setUserProfile(UserProfileModel? userProfile) async {
  //   print("userProfile         $userProfile");
  //   final SharedPreferences storage = await _storage;
  //   await setProfileImage(userProfile!.profileLocation);
  //   storage.setString("userProfile", userProfile.toJson());
  // }

  static Future<void> setProfileImage(String? userProfileImage) async {
    final SharedPreferences storage = await _storage;
    storage.setString("userProfileImage", userProfileImage ?? "");
  }

  static Future<String?> getProfileImage() async {
    final SharedPreferences storage = await _storage;

    return storage.getString("userProfileImage");
  }

  // static Future<UserProfileModel?> getUserProfile() async {
  //   final SharedPreferences storage = await _storage;
  //   var user = storage.getString("userProfile");
  //   return user != null ? UserProfileModel.fromJson(user) : null;
  //

  static Future<bool> isLoggedIn() async {
    TokenModel? token = await SharedService.getToken();
    UserModel? user = await SharedService.getUser();
    return token != null &&
        token.accessToken != null &&
        user != null &&
        user.isGuest == false;
  }

  static Future<UserModel?> getUser() async {
    final SharedPreferences storage = await _storage;
    var user = storage.getString("user");
    return user != null ? UserModel.fromJson(user) : null;
  }

  static Future<bool> containsKey(key) async {
    final SharedPreferences storage = await _storage;
    return storage.containsKey(key);
  }

  static Future<void> logggedOut(context) async {
    final SharedPreferences storage = await _storage;
    Navigator.pushNamedAndRemoveUntil(
        context, LoginScreen.routeName, (Route<dynamic> route) => false);
  }

  static Future<void> logggedOutWithOutContext() async {
    final SharedPreferences storage = await _storage;
    for (String key in storage.getKeys()) {
      if (!key.startsWith("offlineModel-")) {
        storage.remove(key);
      }
    }
    NavigatorHelper.navigateToNewRoute(LoginScreen.routeName);
  }

  static Future<void> validateLogin(context) async {
    final SharedPreferences storage = await _storage;
    if (!storage.containsKey("user") || !storage.containsKey("token")) {
      await logggedOut(context);
    }
  }

  static Future<void> validateWelcome(context) async {
    final SharedPreferences storage = await _storage;
    if (storage.containsKey("user") || storage.containsKey("token")) {
      await Navigator.pushNamedAndRemoveUntil(
          context, LoginScreen.routeName, (Route<dynamic> route) => false);
    }
  }
}
