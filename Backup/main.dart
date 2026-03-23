import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'finBrain',
      theme: ThemeData(useMaterial3: true, fontFamily: 'Inter'),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  late final AnimationController dotController;
  late final AnimationController glowController;

  late final Animation<double> dotScaleAnimation;
  late final Animation<double> glowAnimation;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;

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
    ).animate(CurvedAnimation(parent: dotController, curve: Curves.easeInOut));

    glowAnimation = Tween<double>(
      begin: 0.35,
      end: 0.9,
    ).animate(CurvedAnimation(parent: glowController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    dotController.dispose();
    glowController.dispose();
    super.dispose();
  }

  void onEmailLogin() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    debugPrint('Email: $email');
    debugPrint('Password: $password');

    // TODO:
    // Aqui luego conectas Firebase Auth o tu backend para login con email/password
  }

  void onGoogleLogin() {
    debugPrint('Login con Google');

    // TODO:
    // Aqui luego conectas Google Sign In + Firebase Auth o tu backend
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: AnimatedBuilder(
        animation: Listenable.merge([dotController, glowController]),
        builder: (context, child) {
          return Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF131A24),
                      Color(0xFF101722),
                      Color(0xFF0E141D),
                    ],
                  ),
                ),
              ),

              Align(
                alignment: Alignment.bottomCenter,
                child: CustomPaint(
                  size: Size(screenWidth, screenHeight * 0.28),
                  painter: BottomIslandPainter(
                    glowStrength: glowAnimation.value,
                  ),
                ),
              ),

              Positioned(
                right: 32,
                bottom: screenHeight * 0.23,
                child: Transform.scale(
                  scale: dotScaleAnimation.value,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF8FE9DD),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF2DD4BF,
                          ).withOpacity(0.25 + (0.35 * glowAnimation.value)),
                          blurRadius: 10 + (10 * glowAnimation.value),
                          spreadRadius: 1 + (2 * glowAnimation.value),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 24,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //const SizedBox(height: 18),
                          Text.rich(
                            const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'fin',
                                  style: TextStyle(fontWeight: FontWeight.w400),
                                ),
                                TextSpan(
                                  text: 'Brain',
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                            style: const TextStyle(
                              fontSize: 38,
                              color: Colors.white,
                              letterSpacing: -1.0,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            'Take control of your finances...',
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: Colors.white.withOpacity(0.68),
                            ),
                          ),

                          const SizedBox(height: 34),

                          buildTextField(
                            controller: emailController,
                            label: 'Email',
                            hintText: 'Enter your email...',
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.mail_outline_rounded,
                          ),
                          const SizedBox(height: 20),

                          buildTextField(
                            controller: passwordController,
                            label: 'Password',
                            hintText: 'Enter your password...',
                            obscureText: obscurePassword,
                            prefixIcon: Icons.lock_outline_rounded,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  obscurePassword = !obscurePassword;
                                });
                              },
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.white.withOpacity(0.65),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF8FE9DD),
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Forgot password?',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: ElevatedButton(
                              onPressed: onEmailLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF35D6C8),
                                foregroundColor: const Color(0xFF0B1418),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: const Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: Colors.white.withOpacity(0.12),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  'or continue with',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.55),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: Colors.white.withOpacity(0.12),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: OutlinedButton(
                              onPressed: onGoogleLogin,
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: Colors.white.withOpacity(0.12),
                                  width: 1.2,
                                ),
                                backgroundColor: const Color(
                                  0xFF131C27,
                                ).withOpacity(0.72),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'G',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF4285F4),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Continue with Google',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 26),

                          Center(
                            child: Text.rich(
                              TextSpan(
                                text: "Don't have an account? ",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.58),
                                  fontSize: 13,
                                ),
                                children: const [
                                  TextSpan(
                                    text: 'Create one',
                                    style: TextStyle(
                                      color: Color(0xFF8FE9DD),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
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

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      cursorColor: const Color(0xFF35D6C8),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: TextStyle(
          color: Colors.white.withOpacity(0.6),
          fontSize: 13,
        ),

        hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),

        prefixIcon: Icon(
          prefixIcon,
          color: Colors.white.withOpacity(0.7),
          size: 20,
        ),

        suffixIcon: suffixIcon,

        filled: true,
        fillColor: const Color(0xFF16202B),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF35D6C8), width: 1.4),
        ),
      ),
    );
  }
}

class BottomIslandPainter extends CustomPainter {
  final double glowStrength;

  BottomIslandPainter({required this.glowStrength});

  @override
  void paint(Canvas canvas, Size size) {
    final fillPath = Path();

    fillPath.moveTo(0, size.height * 0.55);

    fillPath.quadraticBezierTo(
      size.width * 0.12,
      size.height * 0.50,
      size.width * 0.22,
      size.height * 0.62,
    );

    fillPath.cubicTo(
      size.width * 0.38,
      size.height * 0.82,
      size.width * 0.45,
      size.height * 0.18,
      size.width * 0.72,
      size.height * 0.16,
    );

    fillPath.quadraticBezierTo(
      size.width * 0.90,
      size.height * 0.14,
      size.width,
      size.height * 0.14,
    );

    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF2BA99B), Color(0xFF1F7E78), Color(0xFF123C42)],
      ).createShader(rect);

    canvas.drawPath(fillPath, fillPaint);

    final strokePath = Path();

    strokePath.moveTo(0, size.height * 0.55);

    strokePath.quadraticBezierTo(
      size.width * 0.12,
      size.height * 0.50,
      size.width * 0.22,
      size.height * 0.62,
    );

    strokePath.cubicTo(
      size.width * 0.38,
      size.height * 0.82,
      size.width * 0.45,
      size.height * 0.18,
      size.width * 0.72,
      size.height * 0.16,
    );

    strokePath.quadraticBezierTo(
      size.width * 0.90,
      size.height * 0.14,
      size.width,
      size.height * 0.14,
    );

    final glowPaint = Paint()
      ..color = const Color(0xFF38E0D0).withOpacity(0.18 * glowStrength)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final strokePaint = Paint()
      ..color =
          Color.lerp(
            const Color(0xFF2CCFC0),
            const Color(0xFF7CF7EC),
            glowStrength,
          ) ??
          const Color(0xFF38E0D0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(strokePath, glowPaint);
    canvas.drawPath(strokePath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant BottomIslandPainter oldDelegate) {
    return oldDelegate.glowStrength != glowStrength;
  }
}
