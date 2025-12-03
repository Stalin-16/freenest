import 'package:freenest/config/app_config.dart';
import 'package:freenest/model/common_reponse.dart';
import 'package:freenest/model/profile_name.dart';
import 'package:freenest/networking/api_base_helper.dart';
import 'package:freenest/service/pagenated_response.dart';

class ProfileService {
  final ApiBaseHelper _helper = ApiBaseHelper();
  final String baseUrl = AppConfig.customerAPI;
  Future<PaginatedResponse<ProfileList>> getProfilesPaginated({
    required int serviceSubCategoryId,
    required int page,
    int limit = 5,
  }) async {
    try {
      final offset = (page - 1) * limit;

      final res = await _helper.getwithoutToken(
          "$baseUrl/profile-customer?serviceSubCategoryId=$serviceSubCategoryId&offset=$offset&limit=$limit");
      final commonResponse = CommonResponseModel.fromMap(res);

      // Parse the paginated response
      final Map<String, dynamic> dataMap =
          commonResponse.data as Map<String, dynamic>;

      // Extract profiles list
      final List<dynamic> profilesList =
          dataMap['profiles'] as List<dynamic>? ?? [];

      // Map profiles
      final List<ProfileList> profiles = profilesList
          .map((item) => ProfileList.fromMap(item as Map<String, dynamic>))
          .toList();

      // Create paginated response
      return PaginatedResponse<ProfileList>.fromMap(dataMap, profiles);
    } catch (e) {
      print("Error loading paginated profiles: $e");
      throw Exception("Failed to load profiles");
    }
  }

  Future<List<ProfileList>> getAllProfiles(int id) async {
    try {
      final res = await _helper.getwithoutToken(
          "$baseUrl/profile-customer?serviceSubCategoryId=$id");

      // res is already a Map
      final commonResponse = CommonResponseModel.fromMap(res);

      // Ensure 'data' is a List
      final List<dynamic> dataList =
          commonResponse.data as List<dynamic>? ?? [];

      // Map each item to Profile
      final List<ProfileList> profiles = dataList
          .map((item) => ProfileList.fromMap(item as Map<String, dynamic>))
          .toList();

      return profiles;
    } catch (e) {
      throw Exception("Failed to load profiles: $e");
    }
  }

  Future<CommonResponseModel> getProfileById(String id) async {
    try {
      final res =
          await _helper.getwithoutToken("$baseUrl/profile-customer/$id");

      return CommonResponseModel.fromMap(res);
    } catch (e) {
      throw Exception("Failed to load profile: $e");
    }
  }
}
