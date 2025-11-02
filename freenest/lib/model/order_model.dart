class OrderModel {
  final int id;
  final int userId;
  final int totalItems;
  final double totalPrice;
  final String status;
  final DateTime createdAt;
  final List<OrderItemModel> orderItems;

  OrderModel({
    required this.id,
    required this.userId,
    required this.totalItems,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    required this.orderItems,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] ?? 0,
      userId: map['user_id'] ?? 0,
      totalItems: map['total_items'] ?? 0,
      totalPrice: (map['total_price'] ?? 0).toDouble(),
      status: map['status'] ?? '',
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toString()),
      orderItems: (map['OrderItems'] as List<dynamic>? ?? [])
          .map((e) => OrderItemModel.fromMap(e))
          .toList(),
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
    final cart = map['CartDetail'];
    final profile = cart?['profile'];

    return OrderItemModel(
      id: map['id'] ?? 0,
      productName: profile?['serviceTitle'] ?? map['product_name'] ?? 'Unknown',
      quantity: cart?['quantity'] ?? map['quantity'] ?? 0,
      price: double.tryParse(cart?['price_per_unit']?.toString() ?? '0') ?? 0,
      totalPrice: double.tryParse(cart?['total_price']?.toString() ?? '0') ?? 0,
    );
  }
}
