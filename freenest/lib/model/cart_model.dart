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

    // Handle hourlyRate with explicit type checking
    dynamic priceValue = map['price_per_unit'];
    double hourlyRate = 0.0;

    if (priceValue != null) {
      if (priceValue is int) {
        hourlyRate = priceValue.toDouble();
      } else if (priceValue is double) {
        hourlyRate = priceValue;
      } else if (priceValue is String) {
        hourlyRate = double.tryParse(priceValue) ?? 0.0;
      } else {
        hourlyRate = 0.0;
      }
    }

    return CartItemModel(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? profile['serviceTitle'] ?? '',
      quantity: map['quantity'] is int ? map['quantity'] as int : 1,
      hourlyRate: hourlyRate,
      imageUrl: map['imageUrl'] ?? profile['profileImage'] ?? '',
      experience: profile['experienceRange']?.toString(),
      rating: profile['overallRating'] is int
          ? profile['overallRating'] as int
          : int.tryParse(profile['overallRating'].toString()),
      workOrderCount: profile['orderCount'] is int
          ? profile['orderCount'] as int
          : int.tryParse(profile['orderCount'].toString()),
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
