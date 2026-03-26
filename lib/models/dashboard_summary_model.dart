import 'alert_item_model.dart';
import 'budget_summary_model.dart';
import 'category_expense_model.dart';

class DashboardSummaryModel {
  final String userName;
  final String? photoUrl;
  final double currentBalance;
  final double totalIncome;
  final double totalExpenses;
  final int cardsCount;
  final List<double> chartBars;
  final BudgetSummaryModel budgetSummary;
  final List<CategoryExpenseModel> categoryExpenses;
  final List<AlertItemModel> alerts;

  const DashboardSummaryModel({
    required this.userName,
    required this.photoUrl,
    required this.currentBalance,
    required this.totalIncome,
    required this.totalExpenses,
    required this.cardsCount,
    required this.chartBars,
    required this.budgetSummary,
    required this.categoryExpenses,
    required this.alerts,
  });

  factory DashboardSummaryModel.fromMap(Map<String, dynamic> map) {
    return DashboardSummaryModel(
      userName: map['userName'] as String? ?? 'Usuario',
      photoUrl: map['photoUrl'] as String?,
      currentBalance: (map['currentBalance'] as num?)?.toDouble() ?? 0,
      totalIncome: (map['totalIncome'] as num?)?.toDouble() ?? 0,
      totalExpenses: (map['totalExpenses'] as num?)?.toDouble() ?? 0,
      cardsCount: map['cardsCount'] as int? ?? 0,
      chartBars: (map['chartBars'] as List<dynamic>? ?? [])
          .map((value) => (value as num).toDouble())
          .toList(),
      budgetSummary: BudgetSummaryModel.fromMap(
        map['budgetSummary'] as Map<String, dynamic>? ?? {},
      ),
      categoryExpenses: (map['categoryExpenses'] as List<dynamic>? ?? [])
          .map(
            (item) => CategoryExpenseModel.fromMap(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      alerts: (map['alerts'] as List<dynamic>? ?? [])
          .map(
            (item) => AlertItemModel.fromMap(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'photoUrl': photoUrl,
      'currentBalance': currentBalance,
      'totalIncome': totalIncome,
      'totalExpenses': totalExpenses,
      'cardsCount': cardsCount,
      'chartBars': chartBars,
      'budgetSummary': budgetSummary.toMap(),
      'categoryExpenses': categoryExpenses.map((item) => item.toMap()).toList(),
      'alerts': alerts.map((item) => item.toMap()).toList(),
    };
  }
}