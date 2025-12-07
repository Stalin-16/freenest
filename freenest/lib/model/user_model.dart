import 'dart:convert';

class UserModel {
  int? id;
  String? name;
  String? lastName;
  String? userName;
  String? email;
  String? emailVerifiedAt;
  String? password;
  bool? isGuest;
  UserModel({
    this.id,
    this.name,
    this.lastName,
    this.userName,
    this.email,
    this.emailVerifiedAt,
    this.password,
    this.isGuest,
  });

  UserModel copyWith({
    int? id,
    String? name,
    String? lastName,
    String? userName,
    String? email,
    String? emailVerifiedAt,
    String? password,
    bool? isGuest,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      password: password ?? this.password,
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
      'emailVerifiedAt': emailVerifiedAt,
      'password': password,
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
      emailVerifiedAt: map['emailVerifiedAt'] != null
          ? map['emailVerifiedAt'] as String
          : null,
      password: map['password'] != null ? map['password'] as String : null,
      isGuest: map['isGuest'] != null ? map['isGuest'] as bool : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, lastName: $lastName, userName: $userName, email: $email, emailVerifiedAt: $emailVerifiedAt, password: $password) isGuest: $isGuest)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.lastName == lastName &&
        other.userName == userName &&
        other.email == email &&
        other.emailVerifiedAt == emailVerifiedAt &&
        other.password == password &&
        other.isGuest == isGuest;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        lastName.hashCode ^
        userName.hashCode ^
        email.hashCode ^
        emailVerifiedAt.hashCode ^
        password.hashCode ^
        isGuest.hashCode;
  }
}
