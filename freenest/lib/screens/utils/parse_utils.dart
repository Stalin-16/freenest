class ParserUtils {
  static double parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) {
      return value.toDouble();
    } else if (value is String) {
      return double.tryParse(value) ?? 0.0;
    } else {
      print("⚠️ Unexpected type for double: ${value.runtimeType}");
      return 0.0;
    }
  }

  static int parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) {
      return value.toInt();
    } else if (value is String) {
      return int.tryParse(value) ?? 0;
    } else {
      print("⚠️ Unexpected type for int: ${value.runtimeType}");
      return 0;
    }
  }

  static int? parseIntNullable(dynamic value) {
    if (value == null) return null;
    return parseInt(value);
  }

  static double? parseDoubleNullable(dynamic value) {
    if (value == null) return null;
    return parseDouble(value);
  }
}
