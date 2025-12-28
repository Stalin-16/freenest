import 'dart:convert';

class CommonResponseModel {
  int? status;
  dynamic data;
  String? message;
  String? devMessage;
  bool? error;
  final Map<String, dynamic>? pagination;
  CommonResponseModel({
    this.status,
    required this.data,
    this.message,
    this.devMessage,
    this.error,
    this.pagination,
  });

  CommonResponseModel copyWith({
    int? status,
    dynamic data,
    String? message,
    String? devMessage,
    bool? error,
  }) {
    return CommonResponseModel(
      status: status ?? this.status,
      data: data ?? this.data,
      message: message ?? this.message,
      devMessage: devMessage ?? this.devMessage,
      error: error ?? this.error,
      pagination: pagination ?? this.pagination,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'status': status,
      'data': data,
      'message': message,
      'devMessage': devMessage,
      'error': error,
      'pagination': pagination
    };
  }

  factory CommonResponseModel.fromMap(Map<String, dynamic> map) {
    return CommonResponseModel(
      status: map['status'] != null ? map['status'] as int : null,
      data: map['data'] as dynamic,
      message: map['message'] != null ? map['message'] as String : null,
      devMessage:
          map['devMessage'] != null ? map['devMessage'] as String : null,
      error: map['error'] != null ? map['error'] as bool : null,
      pagination: map['pagination'] as Map<String, dynamic>?,
    );
  }

  String toJson() => json.encode(toMap());

  factory CommonResponseModel.fromJson(String source) =>
      CommonResponseModel.fromMap(json.decode(source) as Map<String, dynamic>);

  List<dynamic> getDataList(Function(Map<String, dynamic>) fromMap) {
    return data != null
        ? data
            .map((item) {
              if (item is Map<String, dynamic>) {
                return fromMap(item);
              }
              return null;
            })
            .where((object) => object != null)
            // .map((object) => object as T)
            .toList()
        : [];
  }

  List<T> getDataListModel<T>(T Function(Map<String, dynamic>) fromMap) {
    return data != null
        ? data
            .map((item) {
              if (item is Map<String, dynamic>) {
                return fromMap(item);
              }
              return null;
            })
            .where((object) => object != null)
            .map((object) => object as T)
            .toList()
        : [];
  }

  T? getData<T>(T Function(Map<String, dynamic>) fromMap) {
    return data != null ? fromMap(data) : null;
  }

  @override
  String toString() {
    return 'CommonResponseModel(status: $status, data: $data, message: $message, devMessage: $devMessage, error: $error)';
  }

  @override
  bool operator ==(covariant CommonResponseModel other) {
    if (identical(this, other)) return true;

    return other.status == status &&
        other.data == data &&
        other.message == message &&
        other.devMessage == devMessage &&
        other.error == error &&
        other.pagination == pagination;
  }

  @override
  int get hashCode {
    return status.hashCode ^
        data.hashCode ^
        message.hashCode ^
        devMessage.hashCode ^
        error.hashCode ^
        pagination.hashCode;
  }
}
