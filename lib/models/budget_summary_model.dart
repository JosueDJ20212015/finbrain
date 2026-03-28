class BudgetSummaryModel {
  final double totalBudget;
  final double spentAmount;
  final double availableAmount;
  final String period;

  const BudgetSummaryModel({
    required this.totalBudget,
    required this.spentAmount,
    required this.availableAmount,
    required this.period,
  });

  double get progress {
    if (totalBudget <= 0) {
      return 0;
    }

    final value = spentAmount / totalBudget;
    return value.clamp(0, 1);
  }

  String get periodLabel {
    switch (period) {
      case 'weekly':
        return 'Semanal';
      case 'monthly':
        return 'Mensual';
      default:
        return 'Mensual';
    }
  }

  factory BudgetSummaryModel.fromMap(Map<String, dynamic> map) {
    return BudgetSummaryModel(
      totalBudget: (map['totalBudget'] as num?)?.toDouble() ?? 0,
      spentAmount: (map['spentAmount'] as num?)?.toDouble() ?? 0,
      availableAmount: (map['availableAmount'] as num?)?.toDouble() ?? 0,
      period: map['period'] as String? ?? 'monthly',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalBudget': totalBudget,
      'spentAmount': spentAmount,
      'availableAmount': availableAmount,
      'period': period,
    };
  }

  BudgetSummaryModel copyWith({
    double? totalBudget,
    double? spentAmount,
    double? availableAmount,
    String? period,
  }) {
    return BudgetSummaryModel(
      totalBudget: totalBudget ?? this.totalBudget,
      spentAmount: spentAmount ?? this.spentAmount,
      availableAmount: availableAmount ?? this.availableAmount,
      period: period ?? this.period,
    );
  }
}