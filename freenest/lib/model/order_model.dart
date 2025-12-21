import 'package:freenest/model/review_model.dart';

class OrderModel {
  final int id;
  final int userId;
  final String serviceTitle;
  final int yearsofExperience;
  final int totalhours;
  final int priceperhour;
  final double totalPrice;
  final String status;
  final String statusText;
  final DateTime createdAt;
  final String assignedTo;
  final String? imageUrl;
  final ReviewModel? review;

  // NEW FIELDS from the JSON
  final int profileId;
  final int quantity;
  final double pricePerUnit;
  final int? reviewId;
  final DateTime updatedAt;
  final int? serviceCategoryId;
  final String? tagline;
  final double rating;

  OrderModel({
    required this.id,
    required this.userId,
    required this.serviceTitle,
    required this.totalhours,
    required this.priceperhour,
    required this.totalPrice,
    required this.status,
    required this.statusText,
    required this.createdAt,
    required this.assignedTo,
    this.yearsofExperience = 0,
    this.imageUrl,
    this.review,

    // Initialize new fields
    required this.profileId,
    required this.quantity,
    required this.pricePerUnit,
    this.reviewId,
    required this.updatedAt,
    this.serviceCategoryId,
    this.tagline,
    this.rating = 0.0,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    String? parseImageUrl(dynamic value) {
      if (value == null) return null;
      if (value is String && value.isNotEmpty) return value;
      return null;
    }

    // Extract profile data if it exists
    final profile = map['profile'] as Map<String, dynamic>? ?? {};

    // Parse profile-specific fields
    final profileId = parseInt(map['profile_id'] ?? profile['id']);
    final serviceTitle = profile['serviceTitle'] ?? map['serviceTitle'] ?? '';
    final hourlyRate = profile['hourlyRate'] ?? map['hourlyRate'] ?? 0;
    final experienceRange =
        profile['experienceRange'] ?? map['years_of_experience'] ?? '0';
    final profileImage = profile['profileImage'] ?? map['imageUrl'];
    final tagline = profile['tagline'];
    final serviceCategoryId = profile['serviceCategoryId'];
    final rating = parseDouble(profile['rating'] ?? 0);

    // Parse order fields
    final totalhours =
        map['total_hours'] ?? map['total_items'] ?? map['quantity'] ?? 1;
    final pricePerUnit =
        map['price_per_unit'] ?? map['pricePerUnit'] ?? hourlyRate;
    final quantity = map['quantity'] ?? totalhours;

    return OrderModel(
      id: map['id'] ?? 0,
      userId: map['user_id'] ?? map['userId'] ?? 0,
      serviceTitle: serviceTitle,
      totalhours: parseInt(totalhours),
      priceperhour: parseInt(hourlyRate),
      totalPrice: parseDouble(map['total_price'] ?? map['totalPrice']),
      status: map['status'] ?? '',
      statusText: map['status'] ?? '', // Using status as statusText fallback
      createdAt:
          DateTime.tryParse(map['created_at'] ?? map['createdAt'] ?? '') ??
              DateTime.now(),
      assignedTo: serviceTitle,
      yearsofExperience: parseInt(experienceRange),
      imageUrl: parseImageUrl(profileImage),
      review: map['review'] != null ? ReviewModel.fromMap(map['review']) : null,

      // New fields
      profileId: profileId,
      quantity: parseInt(quantity),
      pricePerUnit: parseDouble(pricePerUnit),
      reviewId: parseInt(map['reviewId']),
      updatedAt:
          DateTime.tryParse(map['updated_at'] ?? map['updatedAt'] ?? '') ??
              DateTime.now(),
      serviceCategoryId: parseInt(serviceCategoryId),
      tagline: tagline != null ? tagline.toString() : null,
      rating: rating,
    );
  }

  // Updated toMap() method
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'profile_id': profileId,
      'serviceTitle': serviceTitle,
      'totalhours': totalhours,
      'priceperhour': priceperhour,
      'totalPrice': totalPrice,
      'status': status,
      'statusText': statusText,
      'yearsofExperience': yearsofExperience,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'assignedTo': assignedTo,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'price_per_unit': pricePerUnit,
      'reviewId': reviewId,
      'serviceCategoryId': serviceCategoryId,
      'tagline': tagline,
      'rating': rating,
      'review': review?.toMap(),
    };
  }

  // Optional: Create a method to get the profile data map
  Map<String, dynamic> getProfileMap() {
    return {
      'id': profileId,
      'serviceTitle': serviceTitle,
      'hourlyRate': priceperhour,
      'serviceCategoryId': serviceCategoryId,
      'profileImage': imageUrl,
      'tagline': tagline,
      'experienceRange': yearsofExperience.toString(),
      'rating': rating,
    };
  }

  // Updated copyWith method
  OrderModel copyWith({
    int? id,
    int? userId,
    int? totalhours,
    int? priceperhour,
    double? totalPrice,
    String? status,
    String? statusText,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? assignedTo,
    String? imageUrl,
    ReviewModel? review,
    int? profileId,
    int? quantity,
    double? pricePerUnit,
    int? reviewId,
    int? serviceCategoryId,
    String? tagline,
    double? rating,
    int? yearsofExperience,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      serviceTitle: serviceTitle,
      totalhours: totalhours ?? this.totalhours,
      priceperhour: priceperhour ?? this.priceperhour,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      statusText: statusText ?? this.statusText,
      yearsofExperience: yearsofExperience ?? this.yearsofExperience,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      assignedTo: assignedTo ?? this.assignedTo,
      imageUrl: imageUrl ?? this.imageUrl,
      review: review ?? this.review,
      profileId: profileId ?? this.profileId,
      quantity: quantity ?? this.quantity,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      reviewId: reviewId ?? this.reviewId,
      serviceCategoryId: serviceCategoryId ?? this.serviceCategoryId,
      tagline: tagline ?? this.tagline,
      rating: rating ?? this.rating,
    );
  }

  // Helper method to check if order has been reviewed
  bool get hasReview => review != null || reviewId != null;

  // Helper method to get display status
  String get displayStatus {
    switch (status.toLowerCase()) {
      case 'order placed':
        return 'Order Placed';
      case 'confirmed':
        return 'Confirmed';
      case 'in progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}
