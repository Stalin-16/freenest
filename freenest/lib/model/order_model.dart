import 'package:freenest/model/review_model.dart';

class OrderModel {
  final int id;
  final int userId;
  final int totalItems;
  final double totalPrice;
  final String status;
  final DateTime createdAt;
  final List<OrderItemModel> orderItems;
  final ReviewModel? review;

  OrderModel(
      {required this.id,
      required this.userId,
      required this.totalItems,
      required this.totalPrice,
      required this.status,
      required this.createdAt,
      required this.orderItems,
      this.review});

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return OrderModel(
      id: map['id'] ?? 0,
      userId: map['user_id'] ?? 0,
      totalItems: map['total_items'] ?? 0,
      totalPrice: parseDouble(map['total_price']),
      status: map['status'] ?? '',
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      orderItems: (map['OrderItems'] as List<dynamic>? ?? [])
          .map((e) => OrderItemModel.fromMap(e))
          .toList(),
      review: map['review'] != null ? ReviewModel.fromMap(map['review']) : null,
    );
  }

  /// ✅ Add this
  OrderModel copyWith({
    int? id,
    int? userId,
    int? totalItems,
    double? totalPrice,
    String? status,
    DateTime? createdAt,
    List<OrderItemModel>? orderItems,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      totalItems: totalItems ?? this.totalItems,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      orderItems: orderItems ?? this.orderItems,
      review: review,
    );
  }
}

class OrderItemModel {
  final int id;
  final String productName;
  final int quantity;
  final double price;
  final double totalPrice;

  OrderItemModel({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.totalPrice,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    final cart = map['CartDetail'];
    final profile = cart?['profile'];

    return OrderItemModel(
      id: map['id'] ?? 0,
      productName: profile?['serviceTitle'] ?? map['product_name'] ?? 'Unknown',
      quantity: cart?['quantity'] ?? map['quantity'] ?? 0,
      price: parseDouble(cart?['price_per_unit'] ?? map['price']),
      totalPrice: parseDouble(cart?['total_price'] ?? map['total_price']),
    );
  }
}
