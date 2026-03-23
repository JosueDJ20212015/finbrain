import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/auth_service.dart';
import 'views/home_view.dart';
import 'views/login_view.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'finBrain',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      home: StreamBuilder<User?>(
        stream: authService.authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Color(0xFF101722),
              body: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF35D6C8),
                ),
              ),
            );
          }

          if (snapshot.hasData) {
            return HomeView();
          }

          return const LoginView();
        },
      ),
    );
  }
}