import 'package:flutter/material.dart';
import 'package:myapp/utils/app_snackbar.dart';
import '../controllers/register_controller.dart';
import '../widgets/animated_login_background.dart';
import '../widgets/custom_text_field.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView>
    with TickerProviderStateMixin {
  late final AnimationController dotController;
  late final AnimationController glowController;

  late final Animation<double> dotScaleAnimation;
  late final Animation<double> glowAnimation;

  final registerController = RegisterController();

  @override
  void initState() {
    super.initState();

    dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    dotScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.18,
    ).animate(
      CurvedAnimation(
        parent: dotController,
        curve: Curves.easeInOut,
      ),
    );

    glowAnimation = Tween<double>(
      begin: 0.35,
      end: 0.9,
    ).animate(
      CurvedAnimation(
        parent: glowController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    registerController.dispose();
    dotController.dispose();
    glowController.dispose();
    super.dispose();
  }

  Future<void> handleRegister() async {
    final message = await registerController.onRegister(
      context: context,
      refreshUi: () {
        setState(() {});
      },
    );

    if (!mounted || message == null) {
      return;
    }

    AppSnackbar.error(context, message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: AnimatedBuilder(
        animation: Listenable.merge([dotController, glowController]),
        builder: (context, child) {
          return Stack(
            children: [
              AnimatedLoginBackground(
                glowStrength: glowAnimation.value,
                dotScale: dotScaleAnimation.value,
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      28,
                      8,
                      28,
                      MediaQuery.of(context).viewInsets.bottom + 24,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Create your account below.',
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: Colors.white.withOpacity(0.68),
                            ),
                          ),
                          const SizedBox(height: 34),
                          CustomTextField(
                            controller: registerController.emailController,
                            label: 'Email Address',
                            hintText: 'Enter your email...',
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.mail_outline_rounded,
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            controller: registerController.passwordController,
                            label: 'Password',
                            hintText: 'Create your password...',
                            obscureText: registerController.obscurePassword,
                            prefixIcon: Icons.lock_outline_rounded,
                            suffixIcon: IconButton(
                              onPressed: () {
                                registerController.togglePasswordVisibility(() {
                                  setState(() {});
                                });
                              },
                              icon: Icon(
                                registerController.obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.white.withOpacity(0.65),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            controller:
                                registerController.confirmPasswordController,
                            label: 'Confirm Password',
                            hintText: 'Confirm your password...',
                            obscureText:
                                registerController.obscureConfirmPassword,
                            prefixIcon: Icons.lock_outline_rounded,
                            suffixIcon: IconButton(
                              onPressed: () {
                                registerController
                                    .toggleConfirmPasswordVisibility(() {
                                  setState(() {});
                                });
                              },
                              icon: Icon(
                                registerController.obscureConfirmPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.white.withOpacity(0.65),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: ElevatedButton(
                              onPressed: registerController.isLoading
                                  ? null
                                  : handleRegister,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF35D6C8),
                                foregroundColor: const Color(0xFF0B1418),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: registerController.isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.4,
                                        color: Color(0xFF0B1418),
                                      ),
                                    )
                                  : const Text(
                                      'Create Account',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already have an account? ',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.58),
                                    fontSize: 13,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFF8FE9DD),
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(0, 0),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'Sign in',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}