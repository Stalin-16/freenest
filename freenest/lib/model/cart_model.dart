class CartItemModel {
  final String id;
  final String name;
  final int quantity;
  final double hourlyRate;
  final String imageUrl;

  CartItemModel({
    required this.id,
    required this.name,
    required this.quantity,
    required this.hourlyRate,
    required this.imageUrl,
  });

factory CartItemModel.fromMap(Map<String, dynamic> map) {
  final profile = map['profile'] ?? {};

  double parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  return CartItemModel(
    id: map['id']?.toString() ?? '',
    name: map['name'] ?? profile['serviceTitle'] ?? '',
    quantity: map['quantity'] ?? 1,
    hourlyRate: parseDouble(map['price_per_unit']),
    imageUrl: map['imageUrl'] ?? profile['profileImage'] ?? '',
  );
}




  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'hourlyRate': hourlyRate,
      'imageUrl': imageUrl,
    };
  }

  @override
  String toString() => 'CartItemModel(name: $name, qty: $quantity)';
}
