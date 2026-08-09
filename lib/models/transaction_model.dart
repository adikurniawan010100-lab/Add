class TransactionModel {
  final int? id;
  final String type;
  final double amount;
  final String category;
  final String description;
  final DateTime date;
  final String? note;

  TransactionModel({
    this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
    this.note,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) => TransactionModel(
        id: json['id'] as int?,
        type: json['type'] as String,
        amount: (json['amount'] as num).toDouble(),
        category: json['category'] as String,
        description: json['description'] as String,
        date: DateTime.parse(json['date'] as String),
        note: json['note'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'amount': amount,
        'category': category,
        'description': description,
        'date': date.toIso8601String(),
        'note': note,
      };
}
