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
  final AssignedUserModel? assignedUser;
  final String? imageUrl;
  final OrderReviewModel? review;

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
    required this.assignedUser,
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
      if (value is String) {
        // Remove any quotes or unwanted characters
        final cleaned = value.replaceAll('"', '').trim();
        return double.tryParse(cleaned) ?? 0.0;
      }
      return 0.0;
    }

    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toInt();
      if (value is String) {
        // Remove any quotes or unwanted characters
        final cleaned = value.replaceAll('"', '').trim();
        return int.tryParse(cleaned) ?? 0;
      }
      return 0;
    }

    String? parseImageUrl(dynamic value) {
      if (value == null) return null;
      if (value is String && value.isNotEmpty) {
        final cleaned = value.trim();
        // Add base URL if needed (update with your actual base URL)
        if (!cleaned.startsWith('http') && !cleaned.startsWith('/')) {
          return '/$cleaned';
        }
        return cleaned;
      }
      return null;
    }

    String parseString(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      return value.toString();
    }

    // Extract profile data if it exists
    final profile = map['profile'] as Map<String, dynamic>? ?? {};

    // Parse profile-specific fields
    final profileId = parseInt(map['profile_id'] ?? profile['id']);

    // Get serviceTitle from profile or directly from map
    final serviceTitle = profile['serviceTitle']?.toString() ??
        map['serviceTitle']?.toString() ??
        '';

    final hourlyRate =
        parseInt(profile['hourlyRate'] ?? map['hourlyRate'] ?? 0);

    // Parse experienceRange - it's a string in JSON like "2"
    final experienceRangeStr = profile['experienceRange']?.toString() ??
        map['years_of_experience']?.toString() ??
        '0';
    final yearsofExperience = parseInt(experienceRangeStr);

    final profileImage = profile['profileImage'];
    final tagline = profile['tagline']?.toString();
    final serviceCategoryId = profile['serviceCategoryId'];

    // Get rating from overallRating or rating field
    final rating =
        parseDouble(profile['overallRating'] ?? profile['rating'] ?? 0);

    // Parse order fields
    final totalHours = map['total_hours'] ?? map['totalhours'] ?? 0;
    final pricePerUnit =
        map['price_per_unit'] ?? map['pricePerUnit'] ?? hourlyRate;
    final quantity = map['quantity'] ?? 0;

    // Calculate total hours: use total_hours if > 0, otherwise use quantity
    final effectiveTotalHours =
        parseInt(totalHours) > 0 ? parseInt(totalHours) : parseInt(quantity);

    // Parse date times
    final createdAtStr =
        map['created_at']?.toString() ?? map['createdAt']?.toString() ?? '';
    final updatedAtStr =
        map['updated_at']?.toString() ?? map['updatedAt']?.toString() ?? '';

    final createdAt = DateTime.tryParse(createdAtStr) ?? DateTime.now();
    final updatedAt = DateTime.tryParse(updatedAtStr) ?? DateTime.now();

    // Parse assignedUser if exists
    AssignedUserModel? assignedUser;
    if (map['assignedUser'] != null &&
        map['assignedUser'] is Map<String, dynamic>) {
      assignedUser = AssignedUserModel.fromMap(map['assignedUser']);
    }

    // Parse review if exists
    OrderReviewModel? review;
    if (map['reviewDetails'] != null &&
        map['reviewDetails'] is Map<String, dynamic>) {
      review = OrderReviewModel.fromMap(map['reviewDetails']);
    }

    return OrderModel(
      id: parseInt(map['id']),
      userId: parseInt(map['user_id'] ?? map['userId']),
      serviceTitle: serviceTitle,
      totalhours: effectiveTotalHours,
      priceperhour: hourlyRate,
      totalPrice: parseDouble(map['total_price'] ?? map['totalPrice']),
      status: parseString(map['status']),
      statusText: parseString(map['status']), // Using status as statusText
      yearsofExperience: yearsofExperience,
      createdAt: createdAt,
      updatedAt: updatedAt,
      assignedUser: assignedUser,
      imageUrl: parseImageUrl(profileImage),
      review: review,

      // New fields
      profileId: profileId,
      quantity: parseInt(quantity),
      pricePerUnit: parseDouble(pricePerUnit),
      reviewId: parseInt(map['reviewId']),
      serviceCategoryId: parseInt(serviceCategoryId),
      tagline: tagline,
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
      'assignedUser': assignedUser?.toMap(),
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
    String? serviceTitle,
    int? totalhours,
    int? priceperhour,
    double? totalPrice,
    String? status,
    String? statusText,
    DateTime? createdAt,
    DateTime? updatedAt,
    AssignedUserModel? assignedUser,
    String? imageUrl,
    OrderReviewModel? review,
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
      serviceTitle: serviceTitle ?? this.serviceTitle,
      totalhours: totalhours ?? this.totalhours,
      priceperhour: priceperhour ?? this.priceperhour,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      statusText: statusText ?? this.statusText,
      yearsofExperience: yearsofExperience ?? this.yearsofExperience,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      assignedUser: assignedUser ?? this.assignedUser,
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
      case 'reviewed':
        return 'Reviewed';
      default:
        return status;
    }
  }

  @override
  String toString() {
    return 'OrderModel(id: $id, userId: $userId, serviceTitle: $serviceTitle, status: $status)';
  }
}

class AssignedUserModel {
  final int id;
  final String name;
  final String email;
  final String overallRating;

  AssignedUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.overallRating,
  });

  factory AssignedUserModel.fromMap(Map<String, dynamic> map) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) {
        final cleaned = value.replaceAll('"', '').trim();
        return double.tryParse(cleaned) ?? 0.0;
      }
      return 0.0;
    }

    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toInt();
      if (value is String) {
        final cleaned = value.replaceAll('"', '').trim();
        return int.tryParse(cleaned) ?? 0;
      }
      return 0;
    }

    String parseString(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      return value.toString();
    }

    return AssignedUserModel(
      id: parseInt(map['id']),
      name: parseString(map['name']),
      email: parseString(map['email']),
      overallRating: parseDouble(map['overallRating']).toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'overallRating': overallRating,
    };
  }

  @override
  String toString() {
    return 'AssignedUserModel(id: $id, name: $name, email: $email)';
  }
}

class OrderReviewModel {
  final int id;
  final double rating;
  final String comment;

  OrderReviewModel({
    required this.id,
    required this.rating,
    required this.comment,
  });

  factory OrderReviewModel.fromMap(Map<String, dynamic> map) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) {
        final cleaned = value.replaceAll('"', '').trim();
        return double.tryParse(cleaned) ?? 0.0;
      }
      return 0.0;
    }

    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toInt();
      if (value is String) {
        final cleaned = value.replaceAll('"', '').trim();
        return int.tryParse(cleaned) ?? 0;
      }
      return 0;
    }

    String parseString(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      return value.toString();
    }

    return OrderReviewModel(
      id: parseInt(map['id']),
      rating: parseDouble(map['rating']),
      comment: parseString(map['comment']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rating': rating,
      'comment': comment,
    };
  }

  @override
  String toString() {
    return 'OrderReviewModel(id: $id, rating: $rating, comment: $comment)';
  }
}
