import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/category_expense_model.dart';
import '../models/credit_card_model.dart';
import '../models/dashboard_summary_model.dart';
import '../models/transaction_model.dart';

class DashboardService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  String? get currentUid => auth.currentUser?.uid;

  DocumentReference<Map<String, dynamic>> _dashboardRef(String uid) {
    return firestore
        .collection('users')
        .doc(uid)
        .collection('meta')
        .doc('dashboard');
  }

  CollectionReference<Map<String, dynamic>> _transactionsRef(String uid) {
    return firestore.collection('users').doc(uid).collection('transactions');
  }

  CollectionReference<Map<String, dynamic>> _cardsRef(String uid) {
    return firestore.collection('users').doc(uid).collection('cards');
  }

  Stream<DashboardSummaryModel> watchDashboard() {
    final uid = currentUid;

    if (uid == null) {
      return const Stream.empty();
    }

    return _dashboardRef(uid).snapshots().map((snapshot) {
      final data = snapshot.data() ?? {};
      return DashboardSummaryModel.fromMap(data);
    });
  }

  Future<DashboardSummaryModel?> getDashboard() async {
    final uid = currentUid;

    if (uid == null) {
      return null;
    }

    final snapshot = await _dashboardRef(uid).get();
    final data = snapshot.data();

    if (data == null) {
      return null;
    }

    return DashboardSummaryModel.fromMap(data);
  }

  Future<void> syncDashboardSummary() async {
    final uid = currentUid;
    if (uid == null) {
      return;
    }

    final userSnapshot = await firestore.collection('users').doc(uid).get();
    final dashboardSnapshot = await _dashboardRef(uid).get();
    final dashboardData = dashboardSnapshot.data() ?? {};

    final transactionsSnapshot = await _transactionsRef(uid).get();
    final transactions = transactionsSnapshot.docs.map((doc) {
      return TransactionModel.fromMap(doc.data(), id: doc.id);
    }).toList();

    final cardsSnapshot = await _cardsRef(uid).get();
    final cards = cardsSnapshot.docs.map((doc) {
      return CreditCardModel.fromMap(doc.data(), id: doc.id);
    }).toList();

    final totalIncome = transactions
        .where((item) => item.isIncome)
        .fold<double>(0, (sum, item) => sum + item.amount);

    final totalExpenses = transactions
        .where((item) => item.isExpense)
        .fold<double>(0, (sum, item) => sum + item.amount);

    final currentBalance = totalIncome - totalExpenses;

    final budgetMap =
        dashboardData['budgetSummary'] as Map<String, dynamic>? ?? {};
    final totalBudget = (budgetMap['totalBudget'] as num?)?.toDouble() ?? 0;
    final budgetPeriod = budgetMap['period'] as String? ?? 'monthly';

    final spentAmount = _calculateBudgetSpent(
      transactions: transactions,
      period: budgetPeriod,
    );

    final availableAmount = totalBudget > 0 ? totalBudget - spentAmount : 0;

    final categoryExpenses = _buildCategoryExpenses(transactions);
    final chartBars = _buildChartBars(transactions);
    final alerts = _buildAlerts(
      cards: cards,
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      totalBudget: totalBudget,
      spentAmount: spentAmount,
    );

    await _dashboardRef(uid).set({
      'userName': userSnapshot.data()?['displayName'] ?? 'Usuario',
      'photoUrl': userSnapshot.data()?['photoUrl'],
      'currentBalance': currentBalance,
      'totalIncome': totalIncome,
      'totalExpenses': totalExpenses,
      'cardsCount': cards.length,
      'chartBars': chartBars,
      'budgetSummary': {
        'totalBudget': totalBudget,
        'spentAmount': spentAmount,
        'availableAmount': availableAmount < 0 ? 0 : availableAmount,
        'period': budgetPeriod,
      },
      'categoryExpenses': categoryExpenses.map((item) => item.toMap()).toList(),
      'alerts': alerts,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    }, SetOptions(merge: true));
  }

  double _calculateBudgetSpent({
    required List<TransactionModel> transactions,
    required String period,
  }) {
    final now = DateTime.now();

    bool isInsideRange(DateTime date) {
      if (period == 'weekly') {
        final weekStart = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: now.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 7));
        return !date.isBefore(weekStart) && date.isBefore(weekEnd);
      }

      final monthStart = DateTime(now.year, now.month, 1);
      final nextMonthStart = now.month == 12
          ? DateTime(now.year + 1, 1, 1)
          : DateTime(now.year, now.month + 1, 1);

      return !date.isBefore(monthStart) && date.isBefore(nextMonthStart);
    }

    return transactions
        .where((item) => item.isExpense && isInsideRange(item.date))
        .fold<double>(0, (sum, item) => sum + item.amount);
  }

  List<CategoryExpenseModel> _buildCategoryExpenses(
    List<TransactionModel> transactions,
  ) {
    final categoryTotals = <String, double>{};

    for (final item in transactions.where((item) => item.isExpense)) {
      final current = categoryTotals[item.category] ?? 0;
      categoryTotals[item.category] = current + item.amount;
    }

    final palette = <int>[
      0xFFF2C94C,
      0xFFF261B4,
      0xFF35D6C8,
      0xFF4D8DFF,
      0xFFB46CFF,
      0xFFF5A623,
    ];

    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return List.generate(sortedEntries.length, (index) {
      final entry = sortedEntries[index];
      return CategoryExpenseModel(
        id: entry.key.toLowerCase().replaceAll(' ', '_'),
        name: entry.key,
        amount: entry.value,
        colorValue: palette[index % palette.length],
      );
    });
  }

  List<double> _buildChartBars(List<TransactionModel> transactions) {
    final now = DateTime.now();
    final values = <double>[];

    for (var offset = 4; offset >= 0; offset--) {
      final date = DateTime(now.year, now.month - offset, 1);

      final income = transactions
          .where(
            (item) =>
                item.isIncome &&
                item.date.year == date.year &&
                item.date.month == date.month,
          )
          .fold<double>(0, (sum, item) => sum + item.amount);

      final expenses = transactions
          .where(
            (item) =>
                item.isExpense &&
                item.date.year == date.year &&
                item.date.month == date.month,
          )
          .fold<double>(0, (sum, item) => sum + item.amount);

      final total = income + expenses;
      if (total <= 0) {
        values.add(0.18);
      } else {
        values.add((income / total).clamp(0.12, 1.0));
      }
    }

    return values;
  }

  List<Map<String, dynamic>> _buildAlerts({
    required List<CreditCardModel> cards,
    required double totalIncome,
    required double totalExpenses,
    required double totalBudget,
    required double spentAmount,
  }) {
    final alerts = <Map<String, dynamic>>[];

    for (final card in cards) {
      if (card.shouldWarnStatementSoon) {
        alerts.add({
          'id': 'statement_${card.id}',
          'title': 'Corte de tarjeta',
          'message':
              'La tarjeta ${card.bankName} cierra en ${card.daysUntilStatement()} día(s).',
          'level': 'warning',
        });
      }

      if (card.shouldWarnDueSoon) {
        alerts.add({
          'id': 'due_${card.id}',
          'title': 'Pago de tarjeta',
          'message':
              'La tarjeta ${card.bankName} vence en ${card.daysUntilDue()} día(s).',
          'level': 'warning',
        });
      }
    }

    if (totalExpenses > totalIncome && totalIncome > 0) {
      alerts.add({
        'id': 'expenses_over_income',
        'title': 'Egresos mayores que ingresos',
        'message': 'Tus egresos actuales están superando tus ingresos.',
        'level': 'warning',
      });
    }

    if (totalBudget > 0 && spentAmount >= totalBudget) {
      alerts.add({
        'id': 'budget_exceeded',
        'title': 'Presupuesto agotado',
        'message': 'Ya alcanzaste o superaste tu presupuesto configurado.',
        'level': 'warning',
      });
    } else if (totalBudget > 0 && spentAmount >= (totalBudget * 0.8)) {
      alerts.add({
        'id': 'budget_80',
        'title': 'Presupuesto en 80%',
        'message': 'Ya consumiste más del 80% de tu presupuesto.',
        'level': 'info',
      });
    }

    return alerts;
  }

  Future<void> updateBalance({
    required double currentBalance,
    required double totalIncome,
    required double totalExpenses,
  }) async {
    final uid = currentUid;

    if (uid == null) {
      return;
    }

    await _dashboardRef(uid).update({
      'currentBalance': currentBalance,
      'totalIncome': totalIncome,
      'totalExpenses': totalExpenses,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> updateBudget({
    required double totalBudget,
    required double spentAmount,
    required double availableAmount,
  }) async {
    final uid = currentUid;

    if (uid == null) {
      return;
    }

    final snapshot = await _dashboardRef(uid).get();
    final currentPeriod = (snapshot.data()?['budgetSummary']
            as Map<String, dynamic>?)?['period'] as String? ??
        'monthly';

    await _dashboardRef(uid).update({
      'budgetSummary': {
        'totalBudget': totalBudget,
        'spentAmount': spentAmount,
        'availableAmount': availableAmount,
        'period': currentPeriod,
      },
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> updateCardsCount(int cardsCount) async {
    final uid = currentUid;

    if (uid == null) {
      return;
    }

    await _dashboardRef(uid).update({
      'cardsCount': cardsCount,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> replaceCategoryExpenses(
    List<Map<String, dynamic>> categories,
  ) async {
    final uid = currentUid;

    if (uid == null) {
      return;
    }

    await _dashboardRef(uid).update({
      'categoryExpenses': categories,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> replaceAlerts(List<Map<String, dynamic>> alerts) async {
    final uid = currentUid;

    if (uid == null) {
      return;
    }

    await _dashboardRef(uid).update({
      'alerts': alerts,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }
}