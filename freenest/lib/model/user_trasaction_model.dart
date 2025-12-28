class TransactionModel {
  final String id;
  final String description;
  final DateTime date;
  final double amount;
  final String status;
  final bool isCredit; // true for credit, false for debit

  TransactionModel({
    required this.id,
    required this.description,
    required this.date,
    required this.amount,
    this.status = '',
    required this.isCredit,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    // Safely extract values with type conversion
    final dynamicId = json['id'];
    final id = (dynamicId is String)
        ? dynamicId
        : (dynamicId is num)
            ? dynamicId.toString()
            : '0';

    final dynamicDate = json['created_at'];
    DateTime date;
    try {
      final dateString = (dynamicDate is String) ? dynamicDate : '';
      date = DateTime.parse(dateString);
    } catch (e) {
      date = DateTime.now();
    }

    final dynamicActivity = json['activity_type'];
    final activityType =
        (dynamicActivity is String) ? dynamicActivity.toLowerCase() : '';
    final isCredit = activityType == 'credit';

    final dynamicAmount = json['amount'];
    double amount = 0.0;
    if (dynamicAmount is num) {
      amount = dynamicAmount.toDouble();
    } else if (dynamicAmount is String) {
      amount = double.tryParse(dynamicAmount) ?? 0.0;
    }

    final dynamicDescription = json['description'];
    final description =
        (dynamicDescription is String) ? dynamicDescription : '';

    final dynamicStatus = json['status'];
    final status = (dynamicStatus is String) ? dynamicStatus : '';
    return TransactionModel(
        id: id,
        description: description,
        date: date,
        amount: amount,
        isCredit: isCredit,
        status: status);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'date': date.toIso8601String(),
        'amount': amount,
        'isCredit': isCredit,
        'status': status
      };

  String get formattedDate {
    return '${date.day}/${date.month}/${date.year}';
  }

  String get formattedTime {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
