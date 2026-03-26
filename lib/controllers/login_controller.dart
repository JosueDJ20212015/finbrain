import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final AuthService authService = AuthService();

  bool obscurePassword = true;
  bool isLoading = false;

  void togglePasswordVisibility(VoidCallback refreshUi) {
    obscurePassword = !obscurePassword;
    refreshUi();
  }

  Future<String?> onEmailLogin({
    required BuildContext context,
    required VoidCallback refreshUi,
  }) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      return 'Completar correo y contraseña';
    }

    try {
      isLoading = true;
      refreshUi();

      await authService.signInWithEmail(
        email: email,
        password: password,
      );

      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          return 'El correo no es valido';
        case 'invalid-credential':
          return 'Correo o contraseña incorrectos';
        case 'user-not-found':
          return 'No existe una cuenta con ese correo';
        case 'wrong-password':
          return 'La contraseña es incorrecta';
        case 'user-disabled':
          return 'Esta cuenta fue deshabilitada';
        default:
          return 'No se pudo iniciar sesión';
      }
    } catch (_) {
      return 'No se pudo iniciar sesion';
    } finally {
      isLoading = false;
      refreshUi();
    }
  }

  Future<String?> onGoogleLogin({
    required BuildContext context,
    required VoidCallback refreshUi,
  }) async {
    try {
      isLoading = true;
      refreshUi();

      await authService.signInWithGoogle();

      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'google-sign-in-cancelled':
          return 'Se canceló el inicio de sesion con Google.';
        case 'account-exists-with-different-credential':
          return 'Ya existe una cuenta con ese correo';
        case 'invalid-credential':
          return 'La credencial de Google no es válida.';
        default:
          return 'No se pudo iniciar sesión con Google.';
      }
    } catch (_) {
      return 'No se pudo iniciar sesión con Google.';
    } finally {
      isLoading = false;
      refreshUi();
    }
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}