import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/auth_user_model.dart';

class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  User? get currentUser => auth.currentUser;

  Stream<User?> get authStateChanges => auth.authStateChanges();

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
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
      'currentBalance': 1250.0,
      'totalIncome': 2000.0,
      'totalExpenses': 750.0,
      'cardsCount': 2,
      'chartBars': [0.42, 0.64, 0.72, 0.76, 0.86],
      'budgetSummary': {
        'totalBudget': 800.0,
        'spentAmount': 520.0,
        'availableAmount': 280.0,
      },
      'categoryExpenses': [
        {
          'id': 'food',
          'name': 'Comida',
          'amount': 220.0,
          'colorValue': 0xFFF2C94C,
        },
        {
          'id': 'transport',
          'name': 'Transporte',
          'amount': 180.0,
          'colorValue': 0xFFF261B4,
        },
        {
          'id': 'shopping',
          'name': 'Compras',
          'amount': 140.0,
          'colorValue': 0xFF35D6C8,
        },
        {
          'id': 'services',
          'name': 'Servicios',
          'amount': 210.0,
          'colorValue': 0xFF4D8DFF,
        },
      ],
      'alerts': [
        {
          'id': 'a1',
          'title': 'Pago de tarjeta',
          'message': 'Tu pago vence en 2 días.',
          'level': 'warning',
        },
        {
          'id': 'a2',
          'title': 'Gastos altos',
          'message': 'Tus gastos ya superan el 35% del ingreso.',
          'level': 'warning',
        },
        {
          'id': 'a3',
          'title': 'Presupuesto activo',
          'message': 'Llevas el 65% de tu presupuesto mensual.',
          'level': 'info',
        },
      ],
      'createdAt': Timestamp.fromDate(DateTime.now()),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }
}
