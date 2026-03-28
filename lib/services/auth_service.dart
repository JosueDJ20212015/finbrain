import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/auth_user_model.dart';
import 'dashboard_service.dart';

class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final DashboardService dashboardService = DashboardService();

  User? get currentUser => auth.currentUser;

  Stream<User?> get authStateChanges => auth.authStateChanges();

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _ensureUserDocument(credential.user);
    await dashboardService.syncDashboardSummary();

    return credential;
  }

  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _ensureUserDocument(credential.user);
    await dashboardService.syncDashboardSummary();

    return credential;
  }

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignIn signIn = GoogleSignIn.instance;

    await signIn.initialize();

    final GoogleSignInAccount googleUser = await signIn.authenticate();
    final GoogleSignInAuthentication googleAuth = googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    final userCredential = await auth.signInWithCredential(credential);

    await _ensureUserDocument(userCredential.user);
    await dashboardService.syncDashboardSummary();

    return userCredential;
  }

  Future<void> signOut() async {
    await auth.signOut();

    try {
      await GoogleSignIn.instance.disconnect();
    } catch (_) {}
  }

  Future<void> _ensureUserDocument(User? user) async {
    if (user == null) {
      return;
    }

    final userDoc = firestore.collection('users').doc(user.uid);
    final snapshot = await userDoc.get();

    if (!snapshot.exists) {
      final newUser = AuthUserModel(
        uid: user.uid,
        email: user.email ?? '',
        displayName:
            user.displayName ?? (user.email?.split('@').first ?? 'Usuario'),
        photoUrl: user.photoURL,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await userDoc.set(newUser.toMap());
      await _createInitialDashboard(
        user.uid,
        newUser.displayName,
        user.photoURL,
      );
      return;
    }

    await userDoc.update({
      'email': user.email,
      'displayName':
          user.displayName ?? snapshot.data()?['displayName'] ?? 'Usuario',
      'photoUrl': user.photoURL ?? snapshot.data()?['photoUrl'],
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> _createInitialDashboard(
    String uid,
    String displayName,
    String? photoUrl,
  ) async {
    final dashboardDoc = firestore
        .collection('users')
        .doc(uid)
        .collection('meta')
        .doc('dashboard');

    await dashboardDoc.set({
      'userName': displayName,
      'photoUrl': photoUrl,
      'currentBalance': 0.0,
      'totalIncome': 0.0,
      'totalExpenses': 0.0,
      'cardsCount': 0,
      'chartBars': [0.18, 0.18, 0.18, 0.18, 0.18],
      'budgetSummary': {
        'totalBudget': 0.0,
        'spentAmount': 0.0,
        'availableAmount': 0.0,
        'period': 'monthly',
      },
      'categoryExpenses': [],
      'alerts': [],
      'createdAt': Timestamp.fromDate(DateTime.now()),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    }, SetOptions(merge: true));
  }
}