import 'package:freenest/config/app_config.dart';
import 'package:freenest/model/common_reponse.dart';
import 'package:freenest/model/profile_name.dart';
import 'package:freenest/networking/api_base_helper.dart';

class ProfileService {
  final ApiBaseHelper _helper = ApiBaseHelper();
  final String baseUrl = AppConfig.customerAPI;

 Future<List<ProfileList>> getAllProfiles() async {
    try {
      final res = await _helper.getwithoutToken("$baseUrl/profile-customer");

      // res is already a Map
      final commonResponse = CommonResponseModel.fromMap(res);

      // Ensure 'data' is a List
      final List<dynamic> dataList = commonResponse.data as List<dynamic>? ?? [];

      // Map each item to Profile
      final List<ProfileList> profiles =
          dataList.map((item) => ProfileList.fromMap(item as Map<String, dynamic>)).toList();

      return profiles;
    } catch (e) {
      throw Exception("Failed to load profiles: $e");
    }
  }

  Future<CommonResponseModel> getProfileById(String id) async {
    try {
      final res = await _helper.getwithoutToken("$baseUrl/profile-customer/$id");
      
      return CommonResponseModel.fromMap(res);
    } catch (e) {
      throw Exception("Failed to load profile: $e");
    }
  }
}
