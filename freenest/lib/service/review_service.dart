import 'package:freenest/config/app_config.dart';
import 'package:freenest/model/common_reponse.dart';
import 'package:freenest/model/review_model.dart';
import 'package:freenest/networking/api_base_helper.dart';

class ReviewApiService {
  static final ApiBaseHelper _api = ApiBaseHelper();
  static String baseUrl = AppConfig.customerAPI;

  // Submit review for an order
  static Future<void> submitReview({
    required int orderId,
    required double rating,
    required String comment,
  }) async {
    final body = {
      'orderId': orderId,
      'rating': rating,
      'comment': comment,
    };

    final res = await _api.post('$baseUrl/reviews', body);
    print("🔍 Submit Review API Response: $res");

    final result = CommonResponseModel.fromMap(res);

    if (result.status == 200 || result.status == 201) {
      return; // Success
    } else {
      throw Exception("Failed to submit review: ${result.message}");
    }
  }

  // Get review by order ID
  static Future<ReviewModel?> getReviewByOrderId(int orderId) async {
    final res = await _api.get('$baseUrl/reviews/order/$orderId');
    print("🔍 Get Review by Order ID API Response: $res");

    final result = CommonResponseModel.fromMap(res);

    if (result.status == 200) {
      final data = result.data;
      if (data != null) {
        return ReviewModel.fromMap(data);
      }
      return null;
    } else if (result.status == 404) {
      return null; // Review not found
    } else {
      throw Exception("Failed to fetch review: ${result.message}");
    }
  }

  // Get all reviews for current user
  static Future<List<ReviewModel>> getUserReviews() async {
    final res = await _api.get('$baseUrl/reviews/my-reviews');
    print("🔍 Get User Reviews API Response: $res");

    final result = CommonResponseModel.fromMap(res);

    if (result.status == 200) {
      final data = result.data;

      // Handle both object and list
      if (data is Map<String, dynamic>) {
        return [ReviewModel.fromMap(data)];
      } else if (data is List) {
        return data.map((e) => ReviewModel.fromMap(e)).toList();
      } else {
        throw Exception("Unexpected data format: ${data.runtimeType}");
      }
    } else {
      throw Exception("Failed to fetch reviews: ${result.message}");
    }
  }

  // Update review
  static Future<void> updateReview({
    required int reviewId,
    required double rating,
    required String comment,
  }) async {
    final body = {
      'rating': rating,
      'comment': comment,
    };

    final res = await _api.put('$baseUrl/reviews/$reviewId', body);
    print("🔍 Update Review API Response: $res");

    final result = CommonResponseModel.fromMap(res);

    if (result.status == 200) {
      return; // Success
    } else {
      throw Exception("Failed to update review: ${result.message}");
    }
  }

  // Delete review
  static Future<void> deleteReview(int reviewId) async {
    final res = await _api.delete('$baseUrl/reviews/$reviewId');
    print("🔍 Delete Review API Response: $res");

    final result = CommonResponseModel.fromMap(res);

    if (result.status == 200) {
      return; // Success
    } else {
      throw Exception("Failed to delete review: ${result.message}");
    }
  }

  // Get review by ID
  static Future<ReviewModel> getReviewById(int reviewId) async {
    final res = await _api.get('$baseUrl/reviews/$reviewId');
    print("🔍 Get Review by ID API Response: $res");

    final result = CommonResponseModel.fromMap(res);

    if (result.status == 200) {
      final data = result.data;
      if (data != null) {
        return ReviewModel.fromMap(data);
      }
      throw Exception("Review data is null");
    } else {
      throw Exception("Failed to fetch review: ${result.message}");
    }
  }
}