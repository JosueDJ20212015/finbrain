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

    final cardsSpent = <String, double>{};
    for (final card in cards) {
      final purchasesSnapshot =
          await _cardsRef(uid).doc(card.id).collection('purchases').get();
      final now = DateTime.now();
      final cycleStart = _billingCycleStart(card, now);

      double total = 0;
      for (final doc in purchasesSnapshot.docs) {
        final data = doc.data();
        final dateRaw = data['purchaseDate'];

        DateTime purchaseDate;
        if (dateRaw is Timestamp) {
          purchaseDate = dateRaw.toDate();
        } else if (dateRaw is DateTime) {
          purchaseDate = dateRaw;
        } else {
          purchaseDate = now;
        }

        final amount = (data['amount'] as num?)?.toDouble() ?? 0;
        if (!purchaseDate.isBefore(cycleStart)) {
          total += amount;
        }
      }

      cardsSpent[card.id] = total;
    }

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
      cardsSpent: cardsSpent,
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      currentBalance: currentBalance,
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

  DateTime _billingCycleStart(CreditCardModel card, DateTime now) {
    final thisMonthStatement =
        _safeDate(now.year, now.month, card.statementDay);
    final nowDate = DateTime(now.year, now.month, now.day);

    if (!thisMonthStatement.isBefore(nowDate)) {
      final prevMonth = now.month == 1 ? 12 : now.month - 1;
      final prevYear = now.month == 1 ? now.year - 1 : now.year;
      return _safeDate(prevYear, prevMonth, card.statementDay);
    }

    return thisMonthStatement;
  }

  static DateTime _safeDate(int year, int month, int day) {
    final maxDay = DateTime(year, month + 1, 0).day;
    final safeDay = day > maxDay ? maxDay : day;
    return DateTime(year, month, safeDay);
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
    required Map<String, double> cardsSpent,
    required double totalIncome,
    required double totalExpenses,
    required double currentBalance,
    required double totalBudget,
    required double spentAmount,
  }) {
    final alerts = <Map<String, dynamic>>[];
    final now = DateTime.now();

    String currency(double value) => 'L. ${value.toStringAsFixed(2)}';

    if (totalBudget > 0) {
      final ratio = spentAmount / totalBudget;

      if (spentAmount > totalBudget) {
        final excess = spentAmount - totalBudget;
        alerts.add({
          'id': 'budget_exceeded',
          'title': 'Presupuesto superado',
          'message':
              'Has excedido tu presupuesto en ${currency(excess)}. Gasto: ${currency(spentAmount)} / Límite: ${currency(totalBudget)}.',
          'level': 'danger',
          'type': 'budget',
          'cardId': null,
          'date': Timestamp.fromDate(now),
        });
      } else if (ratio >= 1.0) {
        alerts.add({
          'id': 'budget_100',
          'title': 'Presupuesto agotado',
          'message':
              'Has alcanzado el 100% de tu presupuesto (${currency(spentAmount)}).',
          'level': 'danger',
          'type': 'budget',
          'cardId': null,
          'date': Timestamp.fromDate(now),
        });
      } else if (ratio >= 0.90) {
        final remaining = totalBudget - spentAmount;
        alerts.add({
          'id': 'budget_90',
          'title': 'Presupuesto al 90%',
          'message':
              'Has consumido el 90% de tu presupuesto. Solo te quedan ${currency(remaining)}.',
          'level': 'warning',
          'type': 'budget',
          'cardId': null,
          'date': Timestamp.fromDate(now),
        });
      } else if (ratio >= 0.80) {
        final remaining = totalBudget - spentAmount;
        alerts.add({
          'id': 'budget_80',
          'title': 'Presupuesto al 80%',
          'message':
              'Has consumido el 80% de tu presupuesto. Disponible: ${currency(remaining)}.',
          'level': 'info',
          'type': 'budget',
          'cardId': null,
          'date': Timestamp.fromDate(now),
        });
      }
    }

    for (final card in cards) {
      final daysStatement = card.daysUntilStatement();
      final daysDue = card.daysUntilDue();
      final spent = cardsSpent[card.id] ?? 0;
      final name = '${card.bankName} ••${card.lastFourDigits}';

      if (daysStatement == 0) {
        alerts.add({
          'id': 'statement_today_${card.id}',
          'title': 'Corte hoy — $name',
          'message':
              'Hoy es la fecha de corte de $name. Monto acumulado en este ciclo: ${currency(spent)}.',
          'level': 'danger',
          'type': 'card_statement',
          'cardId': card.id,
          'date': Timestamp.fromDate(now),
        });
      } else if (daysStatement <= 3) {
        final dayLabel = daysStatement == 1 ? '1 día' : '$daysStatement días';
        alerts.add({
          'id': 'statement_${daysStatement}d_${card.id}',
          'title': 'Corte en $dayLabel — $name',
          'message':
              'Faltan $dayLabel para el corte de $name. Monto gastado en este ciclo: ${currency(spent)}.',
          'level': daysStatement == 1 ? 'warning' : 'info',
          'type': 'card_statement',
          'cardId': card.id,
          'date': Timestamp.fromDate(now),
        });
      }

      if (daysDue == 0) {
        alerts.add({
          'id': 'due_today_${card.id}',
          'title': 'Pago vence hoy — $name',
          'message':
              'Hoy vence el pago de $name. No olvides realizar tu pago para evitar cargos.',
          'level': 'danger',
          'type': 'card_due',
          'cardId': card.id,
          'date': Timestamp.fromDate(now),
        });
      } else if (daysDue <= 3) {
        final dayLabel = daysDue == 1 ? '1 día' : '$daysDue días';
        alerts.add({
          'id': 'due_${daysDue}d_${card.id}',
          'title': 'Pago en $dayLabel — $name',
          'message':
              'Faltan $dayLabel para el vencimiento de $name. Recuerda realizar tu pago a tiempo.',
          'level': daysDue == 1 ? 'warning' : 'info',
          'type': 'card_due',
          'cardId': card.id,
          'date': Timestamp.fromDate(now),
        });
      }
    }

    if (totalExpenses > totalIncome && totalIncome > 0) {
      alerts.add({
        'id': 'expenses_over_income',
        'title': 'Egresos mayores que ingresos',
        'message':
            'Tus egresos (${currency(totalExpenses)}) superan tus ingresos (${currency(totalIncome)}) este período.',
        'level': 'warning',
        'type': 'general',
        'cardId': null,
        'date': Timestamp.fromDate(now),
      });
    }

    if (currentBalance < 0) {
      alerts.add({
        'id': 'negative_balance',
        'title': 'Saldo negativo',
        'message':
            'Tu saldo actual es negativo: ${currency(currentBalance)}. Revisa tus egresos.',
        'level': 'danger',
        'type': 'general',
        'cardId': null,
        'date': Timestamp.fromDate(now),
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