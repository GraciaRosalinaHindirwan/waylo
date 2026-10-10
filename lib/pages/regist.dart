import 'package:flutter/material.dart';
import 'package:waylo/theme/appColors.dart';
import 'package:waylo/theme/app_text_styles.dart';
import 'package:waylo/components/button.dart';
import 'package:waylo/pages/login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _fullnameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _fullnameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() {
    if (!_formKey.currentState!.validate()) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Registration submitted')));

    // Hubungkan ke proses registrasi akun di sini.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  children: [
                    // Wave header
                    SizedBox(
                      width: double.infinity,
                      height: constraints.maxHeight * 0.315,
                      child: const CustomPaint(painter: RegisterWavePainter()),
                    ),

                    // Logo and title
                    Transform.translate(
                      offset: const Offset(0, -4),
                      child: Column(
                        children: [
                          Image.asset(
                            '../assets/img/logo.png',
                            width: 104,
                            height: 88,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: RichText(
                                text: TextSpan(
                                  style: AppTextStyles.heading2.copyWith(
                                    fontSize: 30,
                                    color: AppColors.textSecondary,
                                    shadows: [
                                      Shadow(
                                        color: AppColors.textPrimary
                                            .withOpacity(0.25),
                                        offset: const Offset(1, 2),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                  children: [
                                    const TextSpan(text: 'Be a Part of '),
                                    TextSpan(
                                      text: 'WAYLO',
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 54),

                    // Registration form
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 45),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildInput(
                              controller: _fullnameController,
                              hint: 'Fullname',
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your fullname';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            _buildInput(
                              controller: _usernameController,
                              hint: 'Username',
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your username';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            _buildInput(
                              controller: _passwordController,
                              hint: 'Password',
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a password';
                                }
                                if (value.length < 8) {
                                  return 'Password must be at least 8 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            _buildInput(
                              controller: _confirmPasswordController,
                              hint: 'Confirm Password',
                              obscureText: _obscureConfirmPassword,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 48),

                            CustomButton(
                              text: 'Register',
                              onPressed: _register,
                              height: 56,
                            ),

                            const SizedBox(height: 16),

                            Wrap(
                              alignment: WrapAlignment.center,
                              children: [
                                Text(
                                  'Already have account? ',
                                  style: AppTextStyles.body.copyWith(
                                    fontSize: 13,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const LoginPage(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Login here',
                                    style: AppTextStyles.body.copyWith(
                                      fontSize: 13,
                                      color: AppColors.accent,
                                      decoration: TextDecoration.underline,
                                      decorationColor: AppColors.accent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(9),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.23),
            offset: const Offset(0, -2),
            blurRadius: 3,
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        style: AppTextStyles.body.copyWith(
          fontSize: 12,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 17,
            vertical: 17,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(
              color: AppColors.primaryDark,
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}

// Wave khusus Register Page.
// Profilnya dibuat senada dengan Login Page.
class RegisterWavePainter extends CustomPainter {
  const RegisterWavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h * 0.61)
      ..cubicTo(w * 0.96, h * 0.76, w * 0.93, h * 0.64, w * 0.89, h * 0.72)
      ..cubicTo(w * 0.85, h * 0.82, w * 0.82, h * 0.84, w * 0.79, h * 0.69)
      ..cubicTo(w * 0.76, h * 0.56, w * 0.70, h * 0.60, w * 0.68, h * 0.74)
      ..cubicTo(w * 0.64, h * 0.99, w * 0.59, h * 0.95, w * 0.55, h * 0.76)
      ..cubicTo(w * 0.51, h * 0.57, w * 0.49, h * 0.44, w * 0.44, h * 0.44)
      ..cubicTo(w * 0.39, h * 0.44, w * 0.37, h * 0.62, w * 0.34, h * 0.57)
      ..cubicTo(w * 0.30, h * 0.49, w * 0.29, h * 0.65, w * 0.27, h * 0.77)
      ..cubicTo(w * 0.24, h * 0.94, w * 0.20, h * 0.94, w * 0.17, h * 0.78)
      ..cubicTo(w * 0.14, h * 0.59, w * 0.13, h * 0.39, w * 0.09, h * 0.38)
      ..cubicTo(w * 0.04, h * 0.36, w * 0.10, h * 0.58, 0, h * 0.61)
      ..close();

    canvas.drawShadow(path, AppColors.textPrimary.withOpacity(0.30), 5, false);

    canvas.drawPath(path, Paint()..color = AppColors.primary);
  }

  @override
  bool shouldRepaint(covariant RegisterWavePainter oldDelegate) => false;
}
