import 'dart:convert';

class UserModel {
  int? id;
  String? name;
  String? lastName;
  String? userName;
  String? email;
  int? phoneNo;
  bool? isGuest;
  UserModel({
    this.id,
    this.name,
    this.lastName,
    this.userName,
    this.phoneNo,
    this.email,
    this.isGuest,
  });

  UserModel copyWith({
    int? id,
    String? name,
    String? lastName,
    String? userName,
    String? email,
    String? emailVerifiedAt,
    int? phoneNo,
    String? password,
    bool? isGuest,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      phoneNo: phoneNo ?? this.phoneNo,
      isGuest: isGuest ?? this.isGuest,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'lastName': lastName,
      'userName': userName,
      'email': email,
      'phoneNo': phoneNo,
      'isGuest': isGuest,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] != null ? map['id'] as int : null,
      name: map['name'] != null ? map['name'] as String : null,
      lastName: map['lastName'] != null ? map['lastName'] as String : null,
      userName: map['userName'] != null ? map['userName'] as String : null,
      email: map['email'] != null ? map['email'] as String : null,
      phoneNo: map['phoneNo'] != null ? map['phoneNo'] as int : 0,
      isGuest: map['isGuest'] != null ? map['isGuest'] as bool : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, lastName: $lastName, userName: $userName, email: $email, isGuest: $isGuest)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.lastName == lastName &&
        other.userName == userName &&
        other.email == email &&
        other.phoneNo == phoneNo &&
        other.isGuest == isGuest;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        lastName.hashCode ^
        userName.hashCode ^
        email.hashCode ^
        phoneNo.hashCode ^
        isGuest.hashCode;
  }
}
