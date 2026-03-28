import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/card_purchase_model.dart';
import '../models/credit_card_model.dart';
import 'dashboard_service.dart';

class CreditCardService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final DashboardService dashboardService = DashboardService();

  String? get currentUid => auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> _cardsRef(String uid) {
    return firestore.collection('users').doc(uid).collection('cards');
  }

  CollectionReference<Map<String, dynamic>> _purchasesRef(
    String uid,
    String cardId,
  ) {
    return _cardsRef(uid).doc(cardId).collection('purchases');
  }

  Stream<List<CreditCardModel>> watchCards() {
    final uid = currentUid;
    if (uid == null) {
      return const Stream.empty();
    }

    return _cardsRef(uid)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return CreditCardModel.fromMap(doc.data(), id: doc.id);
      }).toList();
    });
  }

  Stream<List<CardPurchaseModel>> watchPurchases(String cardId) {
    final uid = currentUid;
    if (uid == null) {
      return const Stream.empty();
    }

    return _purchasesRef(uid, cardId)
        .orderBy('purchaseDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return CardPurchaseModel.fromMap(doc.data(), id: doc.id);
      }).toList();
    });
  }

  Future<void> createCard({
    required String bankName,
    required String cardName,
    required String holderName,
    required String brand,
    required String lastFourDigits,
    required double creditLimit,
    required int statementDay,
    required int dueDay,
  }) async {
    final uid = currentUid;
    if (uid == null) {
      throw Exception('No hay usuario autenticado.');
    }

    final now = DateTime.now();

    await _cardsRef(uid).add({
      'bankName': bankName,
      'cardName': cardName,
      'holderName': holderName,
      'brand': brand,
      'lastFourDigits': lastFourDigits,
      'creditLimit': creditLimit,
      'statementDay': statementDay,
      'dueDay': dueDay,
      'isActive': true,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    });

    await _syncDashboardCardsCount(uid);
    await dashboardService.syncDashboardSummary();
  }

  Future<void> updateCard({
    required String cardId,
    required String bankName,
    required String cardName,
    required String holderName,
    required String brand,
    required String lastFourDigits,
    required double creditLimit,
    required int statementDay,
    required int dueDay,
    required bool isActive,
  }) async {
    final uid = currentUid;
    if (uid == null) {
      throw Exception('No hay usuario autenticado.');
    }

    await _cardsRef(uid).doc(cardId).update({
      'bankName': bankName,
      'cardName': cardName,
      'holderName': holderName,
      'brand': brand,
      'lastFourDigits': lastFourDigits,
      'creditLimit': creditLimit,
      'statementDay': statementDay,
      'dueDay': dueDay,
      'isActive': isActive,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });

    await _syncDashboardCardsCount(uid);
    await dashboardService.syncDashboardSummary();
  }

  Future<void> deleteCard(String cardId) async {
    final uid = currentUid;
    if (uid == null) {
      throw Exception('No hay usuario autenticado.');
    }

    final purchasesSnapshot = await _purchasesRef(uid, cardId).get();

    for (final doc in purchasesSnapshot.docs) {
      await doc.reference.delete();
    }

    await _cardsRef(uid).doc(cardId).delete();
    await _syncDashboardCardsCount(uid);
    await dashboardService.syncDashboardSummary();
  }

  Future<void> createPurchase({
    required String cardId,
    required String title,
    required double amount,
    required DateTime purchaseDate,
    required int installments,
    required String notes,
  }) async {
    final uid = currentUid;
    if (uid == null) {
      throw Exception('No hay usuario autenticado.');
    }

    final now = DateTime.now();

    await _purchasesRef(uid, cardId).add({
      'title': title,
      'amount': amount,
      'purchaseDate': Timestamp.fromDate(purchaseDate),
      'installments': installments,
      'notes': notes,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    });

    await dashboardService.syncDashboardSummary();
  }

  Future<void> updatePurchase({
    required String cardId,
    required String purchaseId,
    required String title,
    required double amount,
    required DateTime purchaseDate,
    required int installments,
    required String notes,
  }) async {
    final uid = currentUid;
    if (uid == null) {
      throw Exception('No hay usuario autenticado.');
    }

    await _purchasesRef(uid, cardId).doc(purchaseId).update({
      'title': title,
      'amount': amount,
      'purchaseDate': Timestamp.fromDate(purchaseDate),
      'installments': installments,
      'notes': notes,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });

    await dashboardService.syncDashboardSummary();
  }

  Future<void> deletePurchase({
    required String cardId,
    required String purchaseId,
  }) async {
    final uid = currentUid;
    if (uid == null) {
      throw Exception('No hay usuario autenticado.');
    }

    await _purchasesRef(uid, cardId).doc(purchaseId).delete();
    await dashboardService.syncDashboardSummary();
  }

  Future<void> _syncDashboardCardsCount(String uid) async {
    final cardsSnapshot = await _cardsRef(uid).get();

    await firestore
        .collection('users')
        .doc(uid)
        .collection('meta')
        .doc('dashboard')
        .set({
      'cardsCount': cardsSnapshot.docs.length,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    }, SetOptions(merge: true));
  }
}