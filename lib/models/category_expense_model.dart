class CategoryExpenseModel {
  final String id;
  final String name;
  final double amount;
  final int colorValue;

  const CategoryExpenseModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.colorValue,
  });

  factory CategoryExpenseModel.fromMap(Map<String, dynamic> map) {
    return CategoryExpenseModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      colorValue: map['colorValue'] as int? ?? 0xFF35D6C8,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'colorValue': colorValue,
    };
  }
}