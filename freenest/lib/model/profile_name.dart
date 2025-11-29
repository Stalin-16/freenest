class ProfileList {
  final int id;
  final String serviceTitle;
  final String experience;
  final double rating;
  final int workOrders;
  final String profileImage;
  final double price;

  ProfileList(
      {required this.id,
      required this.serviceTitle,
      required this.profileImage,
      this.experience = '',
      this.rating = 0.0,
      this.workOrders = 0,
      this.price = 0.0});

  factory ProfileList.fromMap(Map<String, dynamic> map) {
    return ProfileList(
      id: map['id'],
      serviceTitle: map['serviceTitle'] ?? '',
      profileImage: map['profileImage'],
      experience: map['experience'] ?? '',
      rating: map['rating']?.toDouble() ?? 0.0,
      workOrders: map['workOrders'] ?? 0,
      price: map['price']?.toDouble() ?? 0.0,
    );
  }
}
