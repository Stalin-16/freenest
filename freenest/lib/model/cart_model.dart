class CartItemModel {
  final String id;
  final String name;
  final int quantity;
  final double hourlyRate;
  final String imageUrl;
  final String? experience;
  final int? rating;
  final int? workOrderCount;

  CartItemModel(
      {required this.id,
      required this.name,
      required this.quantity,
      required this.hourlyRate,
      required this.imageUrl,
      this.experience,
      this.rating,
      this.workOrderCount});

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
      experience: profile['experienceRange']?.toString(),
      rating: profile['overallRating'] != null
          ? int.tryParse(profile['overallRating'].toString())
          : null,
      workOrderCount: profile['orderCount'] != null
          ? int.tryParse(profile['orderCount'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'hourlyRate': hourlyRate,
      'imageUrl': imageUrl,
      'experience': experience,
      'rating': rating,
      'workOrderCount': workOrderCount,
    };
  }

  @override
  String toString() =>
      'CartItemModel(name: $name, qty: $quantity, price: $hourlyRate, id: $id, imageUrl: $imageUrl, experience: $experience, rating: $rating, workOrderCount: $workOrderCount)';
}
