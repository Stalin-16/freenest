class ProfileList {
  final int id;
  final String serviceTitle;
  final String? profileImage;

  ProfileList({required this.id, required this.serviceTitle, this.profileImage});

  factory ProfileList.fromMap(Map<String, dynamic> map) {
    return ProfileList(
      id: map['id'],
      serviceTitle: map['serviceTitle'] ?? '',
      profileImage: map['profileImage'],
    );
  }
}
