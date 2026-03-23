import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final AuthService authService = AuthService();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isLoading = false;

  void togglePasswordVisibility(VoidCallback refreshUi) {
    obscurePassword = !obscurePassword;
    refreshUi();
  }

  void toggleConfirmPasswordVisibility(VoidCallback refreshUi) {
    obscureConfirmPassword = !obscureConfirmPassword;
    refreshUi();
  }

  Future<String?> onRegister({
    required BuildContext context,
    required VoidCallback refreshUi,
  }) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      return 'Completa todos los campos.';
    }

    if (password != confirmPassword) {
      return 'Las contraseñas no coinciden.';
    }

    if (password.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }

    try {
      isLoading = true;
      refreshUi();

      await authService.registerWithEmail(
        email: email,
        password: password,
      );

      if (context.mounted) {
        Navigator.pop(context);
      }

      return null;
    } catch (e) {
      return 'No se pudo crear la cuenta.';
    } finally {
      isLoading = false;
      refreshUi();
    }
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }
}