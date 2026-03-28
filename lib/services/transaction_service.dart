import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/transaction_model.dart';
import 'dashboard_service.dart';

class TransactionService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final DashboardService dashboardService = DashboardService();

  String? get currentUid => auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> _transactionsRef(String uid) {
    return firestore.collection('users').doc(uid).collection('transactions');
  }

  Stream<List<TransactionModel>> watchTransactions() {
    final uid = currentUid;
    if (uid == null) {
      return const Stream.empty();
    }

    return _transactionsRef(uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TransactionModel.fromMap(doc.data(), id: doc.id);
      }).toList();
    });
  }

  Future<void> createTransaction({
    required String type,
    required String title,
    required String category,
    required String classification,
    required double amount,
    required DateTime date,
    required String notes,
    required bool isRecurring,
    required String recurrence,
  }) async {
    final uid = currentUid;
    if (uid == null) {
      throw Exception('No hay usuario autenticado.');
    }

    final now = DateTime.now();

    await _transactionsRef(uid).add({
      'type': type,
      'title': title,
      'category': category,
      'classification': classification,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'notes': notes,
      'isRecurring': isRecurring,
      'recurrence': recurrence,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    });

    await dashboardService.syncDashboardSummary();
  }

  Future<void> deleteTransaction(String transactionId) async {
    final uid = currentUid;
    if (uid == null) {
      throw Exception('No hay usuario autenticado.');
    }

    await _transactionsRef(uid).doc(transactionId).delete();
    await dashboardService.syncDashboardSummary();
  }

  Future<void> setBudget({
    required double totalBudget,
    required String period,
  }) async {
    final uid = currentUid;
    if (uid == null) {
      throw Exception('No hay usuario autenticado.');
    }

    final dashboardRef = firestore
        .collection('users')
        .doc(uid)
        .collection('meta')
        .doc('dashboard');

    await dashboardRef.set({
      'budgetSummary': {
        'totalBudget': totalBudget,
        'spentAmount': 0,
        'availableAmount': totalBudget,
        'period': period,
      },
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    }, SetOptions(merge: true));

    await dashboardService.syncDashboardSummary();
  }
}