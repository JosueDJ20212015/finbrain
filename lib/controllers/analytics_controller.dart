import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../models/category_expense_model.dart';
import '../models/transaction_model.dart';

class AnalyticsController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  bool isLoading = true;
  String? errorMessage;

  double currentBalance = 0;
  double totalIncome = 0;
  double totalExpenses = 0;

  double budgetTotal = 0;
  double budgetSpent = 0;
  double budgetAvailable = 0;
  double budgetUsage = 0;

  double totalCardLimit = 0;
  double totalCardDebt = 0;
  double cardUsage = 0;

  List<double> monthlyNetValues = [];
  List<double> monthlyExpenseValues = [];
  List<String> monthLabels = [];

  List<CategoryExpenseModel> categoryExpenses = [];

  int financialScore = 0;
  String financialLabel = 'Sin datos';
  String financialMessage =
      'Registra más movimientos para evaluar tu salud financiera.';

  Future<void> loadAnalytics(VoidCallback refreshUi) async {
    final uid = auth.currentUser?.uid;
    if (uid == null) {
      isLoading = false;
      errorMessage = 'No hay usuario autenticado.';
      refreshUi();
      return;
    }

    isLoading = true;
    errorMessage = null;
    refreshUi();

    try {
      await initializeDateFormatting('es');

      final dashboardSnapshot = await firestore
          .collection('users')
          .doc(uid)
          .collection('meta')
          .doc('dashboard')
          .get();

      final dashboardData = dashboardSnapshot.data() ?? {};
      final budgetMap =
          dashboardData['budgetSummary'] as Map<String, dynamic>? ?? {};

      currentBalance =
          (dashboardData['currentBalance'] as num?)?.toDouble() ?? 0;
      totalIncome = (dashboardData['totalIncome'] as num?)?.toDouble() ?? 0;
      totalExpenses = (dashboardData['totalExpenses'] as num?)?.toDouble() ?? 0;

      budgetTotal = (budgetMap['totalBudget'] as num?)?.toDouble() ?? 0;
      budgetSpent = (budgetMap['spentAmount'] as num?)?.toDouble() ?? 0;
      budgetAvailable = (budgetMap['availableAmount'] as num?)?.toDouble() ?? 0;
      budgetUsage = budgetTotal > 0 ? (budgetSpent / budgetTotal) : 0;

      final rawCategoryExpenses =
          dashboardData['categoryExpenses'] as List<dynamic>? ?? [];

      categoryExpenses = rawCategoryExpenses
          .map((item) => CategoryExpenseModel.fromMap(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList();

      final transactionsSnapshot = await firestore
          .collection('users')
          .doc(uid)
          .collection('transactions')
          .orderBy('date', descending: false)
          .get();

      final transactions = transactionsSnapshot.docs.map((doc) {
        return TransactionModel.fromMap(doc.data(), id: doc.id);
      }).toList();

      final cardsSnapshot =
          await firestore.collection('users').doc(uid).collection('cards').get();

      totalCardLimit = 0;
      totalCardDebt = 0;

      for (final cardDoc in cardsSnapshot.docs) {
        final cardData = cardDoc.data();
        totalCardLimit += (cardData['creditLimit'] as num?)?.toDouble() ?? 0;

        final purchasesSnapshot =
            await cardDoc.reference.collection('purchases').get();

        for (final purchaseDoc in purchasesSnapshot.docs) {
          final purchaseData = purchaseDoc.data();
          totalCardDebt += (purchaseData['amount'] as num?)?.toDouble() ?? 0;
        }
      }

      cardUsage = totalCardLimit > 0 ? (totalCardDebt / totalCardLimit) : 0;

      _buildMonthlySeries(transactions);
      _calculateFinancialScore();

      isLoading = false;
      errorMessage = null;
      refreshUi();
    } catch (e) {
      isLoading = false;
      errorMessage = 'No se pudo cargar la pantalla analítica.\n$e';
      refreshUi();
    }
  }

  void _buildMonthlySeries(List<TransactionModel> transactions) {
    monthlyNetValues = [];
    monthlyExpenseValues = [];
    monthLabels = [];

    final now = DateTime.now();

    for (var offset = 5; offset >= 0; offset--) {
      final targetMonth = DateTime(now.year, now.month - offset, 1);
      final nextMonth = DateTime(targetMonth.year, targetMonth.month + 1, 1);

      final monthIncome = transactions
          .where(
            (item) =>
                item.type == 'income' &&
                !item.date.isBefore(targetMonth) &&
                item.date.isBefore(nextMonth),
          )
          .fold<double>(0, (sum, item) => sum + item.amount);

      final monthExpense = transactions
          .where(
            (item) =>
                item.type == 'expense' &&
                !item.date.isBefore(targetMonth) &&
                item.date.isBefore(nextMonth),
          )
          .fold<double>(0, (sum, item) => sum + item.amount);

      monthlyNetValues.add(monthIncome - monthExpense);
      monthlyExpenseValues.add(monthExpense);
      monthLabels.add(_formatMonthLabel(targetMonth));
    }
  }

  String _formatMonthLabel(DateTime date) {
    try {
      final label = DateFormat('MMM', 'es').format(date);
      if (label.isEmpty) {
        return '';
      }

      return label[0].toUpperCase() + label.substring(1);
    } catch (_) {
      const fallbackMonths = [
        'Ene',
        'Feb',
        'Mar',
        'Abr',
        'May',
        'Jun',
        'Jul',
        'Ago',
        'Sep',
        'Oct',
        'Nov',
        'Dic',
      ];

      return fallbackMonths[date.month - 1];
    }
  }

  void _calculateFinancialScore() {
    final savingsScore = _buildSavingsScore();
    final budgetScore = _buildBudgetScore();
    final debtScore = _buildDebtScore();

    financialScore =
        (savingsScore + budgetScore + debtScore).round().clamp(0, 100);

    if (financialScore >= 85) {
      financialLabel = 'Excelente';
      financialMessage =
          'Tu balance, uso del presupuesto y endeudamiento están en una zona muy saludable.';
    } else if (financialScore >= 70) {
      financialLabel = 'Saludable';
      financialMessage =
          'Tus finanzas van bien. Mantén controlados tus gastos y el uso del crédito.';
    } else if (financialScore >= 55) {
      financialLabel = 'En observación';
      financialMessage =
          'Hay señales que debes vigilar: presupuesto, gastos o deuda están presionando tu salud financiera.';
    } else {
      financialLabel = 'Riesgo';
      financialMessage =
          'Tu situación financiera necesita atención. Reduce gastos, ajusta presupuesto y revisa tu nivel de deuda.';
    }
  }

  double _buildSavingsScore() {
    if (totalIncome <= 0) {
      return totalExpenses > 0 ? 5 : 15;
    }

    final savingsRate = (totalIncome - totalExpenses) / totalIncome;

    if (savingsRate >= 0.40) return 40;
    if (savingsRate >= 0.25) return 34;
    if (savingsRate >= 0.10) return 28;
    if (savingsRate >= 0.00) return 22;
    if (savingsRate >= -0.20) return 12;
    return 4;
  }

  double _buildBudgetScore() {
    if (budgetTotal <= 0) {
      return 18;
    }

    if (budgetUsage <= 0.50) return 30;
    if (budgetUsage <= 0.75) return 24;
    if (budgetUsage <= 0.90) return 18;
    if (budgetUsage <= 1.00) return 12;
    if (budgetUsage <= 1.15) return 6;
    return 2;
  }

  double _buildDebtScore() {
    if (totalCardLimit <= 0) {
      return 30;
    }

    if (cardUsage <= 0.10) return 30;
    if (cardUsage <= 0.30) return 24;
    if (cardUsage <= 0.50) return 18;
    if (cardUsage <= 0.75) return 10;
    return 4;
  }
}