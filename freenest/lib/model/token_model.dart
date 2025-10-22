import 'dart:convert';

class TokenModel {
  
  String? accessToken;
  String? tokenType;
  int? expiresIn;
  String? scope;
  TokenModel({
    this.accessToken,
    this.tokenType,
    this.expiresIn,
    this.scope,
  });

  TokenModel copyWith({
    String? accessToken,
    String? tokenType,
    int? expiresIn,
    String? scope,
  }) {
    return TokenModel(
      accessToken: accessToken ?? this.accessToken,
      tokenType: tokenType ?? this.tokenType,
      expiresIn: expiresIn ?? this.expiresIn,
      scope: scope ?? this.scope
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    if (accessToken != null) {
      result.addAll({'access_token': accessToken});
    }
    if (tokenType != null) {
      result.addAll({'token_type': tokenType});
    }
    if (expiresIn != null) {
      result.addAll({'expires_in': expiresIn});
    }
    if (scope != null) {
      result.addAll({'scope': scope});
    }

    return result;
  }

  factory TokenModel.fromMap(Map<String, dynamic> map) {
    return TokenModel(
      accessToken: map['access_token'],
      tokenType: map['token_type'],
      expiresIn: map['expires_in'],
      scope: map['scope'],
    );
  }

  String toJson() => json.encode(toMap());

  factory TokenModel.fromJson(String source) =>
      TokenModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Token(accessToken: $accessToken, tokenType: $tokenType, expiresIn: $expiresIn, scope: $scope)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TokenModel &&
        other.accessToken == accessToken &&
        other.tokenType == tokenType &&
        other.expiresIn == expiresIn &&
        other.scope == scope;
  }

  @override
  int get hashCode {
    return accessToken.hashCode ^
        tokenType.hashCode ^
        expiresIn.hashCode ^
        scope.hashCode;
  }
}
