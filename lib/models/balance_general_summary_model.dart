class BalanceGeneralSummaryModel {
  final double currentBalance;
  final double totalIncome;
  final double totalExpenses;
  final double budgetTotal;
  final double budgetAvailable;
  final double totalCardDebt;
  final double totalCardLimit;

  const BalanceGeneralSummaryModel({
    required this.currentBalance,
    required this.totalIncome,
    required this.totalExpenses,
    required this.budgetTotal,
    required this.budgetAvailable,
    required this.totalCardDebt,
    required this.totalCardLimit,
  });

  double get netWorth {
    return currentBalance - totalCardDebt;
  }

  double get cardUsage {
    if (totalCardLimit <= 0) {
      return 0;
    }

    return (totalCardDebt / totalCardLimit).clamp(0, 1);
  }
}