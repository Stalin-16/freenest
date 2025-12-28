import 'package:freenest/screens/utils/parse_utils.dart';

class OrderModel {
  final int id;
  final int userId;
  final double baseAmount;
  final double gstAmount;
  final double totalAmount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderItem> orderItems;

  OrderModel({
    required this.id,
    required this.userId,
    required this.baseAmount,
    required this.gstAmount,
    required this.totalAmount,
    required this.createdAt,
    required this.updatedAt,
    required this.orderItems,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: ParserUtils.parseInt(map['id']),
      userId: ParserUtils.parseInt(map['user_id']),
      baseAmount: ParserUtils.parseDouble(map['base_amount']),
      gstAmount: ParserUtils.parseDouble(map['gst_amount']),
      totalAmount: ParserUtils.parseDouble(map['base_amount']) +
          ParserUtils.parseDouble(map['gst_amount']),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      orderItems: (map['OrderItems'] as List)
          .map((item) => OrderItem.fromMap(item))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'base_amount': baseAmount,
      'gst_amount': gstAmount,
      'total_amount': totalAmount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'OrderItems': orderItems.map((item) => item.toMap()).toList(),
    };
  }

  String get formattedDate {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${createdAt.day}-${months[createdAt.month - 1]}-${createdAt.year}';
  }

  String get formattedTime {
    final hour = createdAt.hour.toString().padLeft(2, '0');
    final minute = createdAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  String toString() {
    return 'Order(id: $id, total: $totalAmount, items: ${orderItems.length})';
  }
}

class OrderItem {
  final int id;
  final int profileId;
  final int? assignedTo;
  final int orderId;
  final int cartId;
  final int quantity;
  final double price;
  final double totalPrice;
  final int? reviewId;
  final String status;
  final DateTime createdAt;
  final Profile profile;
  final AssignedUser? assignedUser;
  final OrderReview? reviewDetails;

  OrderItem({
    required this.id,
    required this.profileId,
    this.assignedTo,
    required this.orderId,
    required this.cartId,
    required this.quantity,
    required this.price,
    required this.totalPrice,
    this.reviewId,
    required this.status,
    required this.createdAt,
    required this.profile,
    this.assignedUser,
    this.reviewDetails,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: ParserUtils.parseInt(map['id']),
      profileId: ParserUtils.parseInt(map['profile_id']),
      assignedTo: ParserUtils.parseIntNullable(map['assigned_to']),
      orderId: ParserUtils.parseInt(map['order_id']),
      cartId: ParserUtils.parseInt(map['cart_id']),
      quantity: ParserUtils.parseInt(map['quantity']),
      price: ParserUtils.parseDouble(map['price']),
      totalPrice: ParserUtils.parseDouble(map['total_price']),
      reviewId: ParserUtils.parseIntNullable(map['reviewId']),
      status: map['status'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      profile: Profile.fromMap(map['profile'] as Map<String, dynamic>),
      assignedUser: map['assignedUser'] != null
          ? AssignedUser.fromMap(map['assignedUser'] as Map<String, dynamic>)
          : null,
      reviewDetails: map['reviewDetails'] != null
          ? OrderReview.fromMap(map['reviewDetails'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profile_id': profileId,
      'assigned_to': assignedTo,
      'order_id': orderId,
      'cart_id': cartId,
      'quantity': quantity,
      'price': price,
      'total_price': totalPrice,
      'reviewId': reviewId,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'profile': profile.toMap(),
      'assignedUser': assignedUser?.toMap(),
      'reviewDetails': reviewDetails?.toMap(),
    };
  }

  bool get hasReview => reviewDetails != null || reviewId != null;

  @override
  String toString() {
    return 'OrderItem(id: $id, service: ${profile.serviceTitle}, status: $status)';
  }
}

class Profile {
  final int id;
  final String serviceTitle;
  final int hourlyRate;
  final int? serviceCategoryId;
  final String? profileImage;
  final String? tagline;
  final int experienceRange;
  final double? overallRating;

  Profile({
    required this.id,
    required this.serviceTitle,
    required this.hourlyRate,
    this.serviceCategoryId,
    this.profileImage,
    this.tagline,
    required this.experienceRange,
    this.overallRating,
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: ParserUtils.parseInt(map['id']),
      serviceTitle: map['serviceTitle'] as String,
      hourlyRate: ParserUtils.parseInt(map['hourlyRate']),
      serviceCategoryId: ParserUtils.parseIntNullable(map['serviceCategoryId']),
      profileImage: map['profileImage'] as String?,
      tagline: map['tagline'] as String?,
      experienceRange: ParserUtils.parseInt(map['experienceRange']),
      overallRating: ParserUtils.parseDoubleNullable(map['overallRating']),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'serviceTitle': serviceTitle,
      'hourlyRate': hourlyRate,
      'serviceCategoryId': serviceCategoryId,
      'profileImage': profileImage,
      'tagline': tagline,
      'experienceRange': experienceRange,
      'overallRating': overallRating,
    };
  }
}

class AssignedUser {
  final int id;
  final String name;
  final String email;
  final double overallRating;

  AssignedUser({
    required this.id,
    required this.name,
    required this.email,
    required this.overallRating,
  });

  factory AssignedUser.fromMap(Map<String, dynamic> map) {
    return AssignedUser(
      id: ParserUtils.parseInt(map['id']),
      name: map['name'] as String,
      email: map['email'] as String,
      overallRating: ParserUtils.parseDouble(map['overallRating']),
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
}

class OrderReview {
  final int id;
  final double rating;
  final String comment;

  OrderReview({
    required this.id,
    required this.rating,
    required this.comment,
  });

  factory OrderReview.fromMap(Map<String, dynamic> map) {
    return OrderReview(
      id: ParserUtils.parseInt(map['id']),
      rating: ParserUtils.parseDouble(map['rating']),
      comment: map['comment'] as String,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rating': rating,
      'comment': comment,
    };
  }
}
