import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class HomeView extends StatelessWidget {
  HomeView({super.key});

  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF101722),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101722),
        elevation: 0,
        title: const Text(
          'finBrain',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await authService.signOut();
            },
            child: const Text(
              'Salir',
              style: TextStyle(
                color: Color(0xFF8FE9DD),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Bienvenido${user?.email != null ? '\n${user!.email}' : ''}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}