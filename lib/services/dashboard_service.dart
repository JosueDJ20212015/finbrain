import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/dashboard_summary_model.dart';

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

    await _dashboardRef(uid).update({
      'budgetSummary': {
        'totalBudget': totalBudget,
        'spentAmount': spentAmount,
        'availableAmount': availableAmount,
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
