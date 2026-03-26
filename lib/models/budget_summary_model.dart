class BudgetSummaryModel {
  final double totalBudget;
  final double spentAmount;
  final double availableAmount;

  const BudgetSummaryModel({
    required this.totalBudget,
    required this.spentAmount,
    required this.availableAmount,
  });

  double get progress {
    if (totalBudget <= 0) {
      return 0;
    }

    final value = spentAmount / totalBudget;
    return value.clamp(0, 1);
  }

  factory BudgetSummaryModel.fromMap(Map<String, dynamic> map) {
    return BudgetSummaryModel(
      totalBudget: (map['totalBudget'] as num?)?.toDouble() ?? 0,
      spentAmount: (map['spentAmount'] as num?)?.toDouble() ?? 0,
      availableAmount: (map['availableAmount'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalBudget': totalBudget,
      'spentAmount': spentAmount,
      'availableAmount': availableAmount,
    };
  }
}