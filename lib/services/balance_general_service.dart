import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/balance_general_summary_model.dart';

class BalanceGeneralService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  String? get currentUid => auth.currentUser?.uid;

  Future<BalanceGeneralSummaryModel> getSummary() async {
    final uid = currentUid;
    if (uid == null) {
      throw Exception('No hay usuario autenticado.');
    }

    final dashboardSnapshot = await firestore
        .collection('users')
        .doc(uid)
        .collection('meta')
        .doc('dashboard')
        .get();

    final dashboardData = dashboardSnapshot.data() ?? {};
    final budgetMap =
        dashboardData['budgetSummary'] as Map<String, dynamic>? ?? {};

    final currentBalance =
        (dashboardData['currentBalance'] as num?)?.toDouble() ?? 0;
    final totalIncome = (dashboardData['totalIncome'] as num?)?.toDouble() ?? 0;
    final totalExpenses =
        (dashboardData['totalExpenses'] as num?)?.toDouble() ?? 0;
    final budgetTotal = (budgetMap['totalBudget'] as num?)?.toDouble() ?? 0;
    final budgetAvailable =
        (budgetMap['availableAmount'] as num?)?.toDouble() ?? 0;

    final cardsSnapshot =
        await firestore.collection('users').doc(uid).collection('cards').get();

    double totalCardDebt = 0;
    double totalCardLimit = 0;

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

    return BalanceGeneralSummaryModel(
      currentBalance: currentBalance,
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      budgetTotal: budgetTotal,
      budgetAvailable: budgetAvailable,
      totalCardDebt: totalCardDebt,
      totalCardLimit: totalCardLimit,
    );
  }
}