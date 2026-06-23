import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ntnc/screen/dashboard.dart';
import 'package:ntnc/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool obscurePassword = true;
  bool isLoading = false;

  Widget leafDivider() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            const Expanded(
              child: Divider(thickness: 1, color: Color(0xffD9D9D9)),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 24,
              width: 24,
              child: Image.asset("assets/images/leaves.png"),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Divider(thickness: 1, color: Color(0xffD9D9D9)),
            ),
          ],
        );
      },
    );
  }

  Widget _glassTextField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    bool isPassword = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.4),
              width: 1.2,
            ),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: isPassword ? obscurePassword : false,
            keyboardType: keyboardType,
            validator: validator,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 15,
              ),
              prefixIcon: Icon(
                prefixIcon,
                color: const Color(0xff2D6B21),
                size: 22,
              ),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: const Color(0xff2D6B21),
                      ),
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    )
                  : null,
              filled: false,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final result = await _authService.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    setState(() => isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      // Token is already saved in AuthService, navigate to dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardHome()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade700,
          content: Text(
            result['message'],
            style: const TextStyle(color: Colors.white),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          titlePadding: const EdgeInsets.only(top: 28, left: 24, right: 24),
          contentPadding: const EdgeInsets.all(24),
          title: Column(
            children: [
              Container(
                height: 65,
                width: 65,
                decoration: const BoxDecoration(
                  color: Color(0xffE7F0E5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_reset_rounded,
                  color: Color(0xff2C631D),
                  size: 34,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Forgot Password",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff162912),
                ),
              ),
            ],
          ),
          content: const Text(
            "To reset your account password, please contact the NTNC Admin Office during official working hours.\n\nFor immediate account access support, reach out to your designated system administrator.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Color(0xff4A4A4A),
              height: 1.5,
            ),
          ),
          actions: [
            Center(
              child: SizedBox(
                width: 140,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2C631D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    "OK",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          /// Background Forest Image
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/bg1.png"),
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),

          /// Light Top Gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment(0, 0.45),
                colors: [
                  Color(0xffF8F6F1),
                  Color(0xffF8F6F1),
                  Colors.transparent,
                ],
                stops: [0, 0.32, 1],
              ),
            ),
          ),

          /// Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  /// NTNC Logo
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        "assets/images/ntnc.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  /// Organization Title
                  const Text(
                    "NATIONAL TRUST FOR",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Color(0xff162912),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Text(
                    "NATURE CONSERVATION",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xff2D6B21),
                    ),
                  ),

                  const SizedBox(height: 6),

                  /// Tagline
                  const Text(
                    "Conserving Nature. Preserving Life.",
                    style: TextStyle(
                      color: Color(0xff5A5F5A),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// Tagline Divider
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 80),
                    child: leafDivider(),
                  ),

                  const SizedBox(height: 22),

                  /// ✨ Glass Login Card
                  Form(
                    key: _formKey,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(36),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 22,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.30),
                              borderRadius: BorderRadius.circular(36),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.5),
                                width: 1.4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.10),
                                  blurRadius: 25,
                                  offset: const Offset(0, 10),
                                )
                              ],
                            ),
                            child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// Username Label
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor:
                                        const Color(0xffE7F0E5).withValues(alpha: 0.9),
                                    child: const Icon(
                                      Icons.person_rounded,
                                      color: Color(0xff1E6A34),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    "Username",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xff162912),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              /// ✨ Glass Email Field
                              _glassTextField(
                                controller: emailController,
                                hint: "Enter email",
                                prefixIcon: Icons.mail_outline_rounded,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Email is required';
                                  }
                                  if (!RegExp(r'^[\w-\.]+@[\w-]+\.[a-z]{2,}$').hasMatch(value)) {
                                    return 'Enter a valid email';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              /// Password Label
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor:
                                        const Color(0xffE7F0E5).withValues(alpha: 0.9),
                                    child: const Icon(
                                      Icons.lock_outline_rounded,
                                      color: Color(0xff1E6A34),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    "Password",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xff162912),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              /// ✨ Glass Password Field
                              _glassTextField(
                                controller: passwordController,
                                hint: "Enter password",
                                prefixIcon: Icons.lock_outline_rounded,
                                isPassword: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Password is required';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 22),

                              /// Full Width Login Button
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xff2C631D),
                                    disabledBackgroundColor: const Color(0xff2C631D).withValues(alpha: 0.6),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                    elevation: 3,
                                    shadowColor: const Color(0xff2C631D)
                                        .withValues(alpha: 0.4),
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : const Text(
                                          "Login",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              /// Divider after button
                              leafDivider(),

                              const SizedBox(height: 10),

                              /// Forgot Password Button
                              Center(
                                child: TextButton(
                                  onPressed: _showForgotPasswordDialog,
                                  child: const Text(
                                    "Forgot password?",
                                    style: TextStyle(
                                      color: Color(0xff2D6B21),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Center(
                    child: Text(
                      "Powered By:",
                      style: TextStyle(
                        color: Color(0xffffffff),
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),

                  const SizedBox(height: 3),

                  /// Powered By Websoft Logo


ClipRRect(
  borderRadius: BorderRadius.circular(50),
  child: BackdropFilter(
    filter: ImageFilter.blur(
      sigmaX: 10,
      sigmaY: 10,
    ),
    child: Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
  radius: 25,
  backgroundColor: Colors.transparent,
  child: ClipOval(
    child: Image.asset(
      "assets/images/techlogo.png",
      width: 45,
      height: 45,
      fit: BoxFit.cover,
    ),
  ),
),
          const SizedBox(width: 10),
          const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "web",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                TextSpan(
                  text: "soft",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff8BC340),
                  ),
                ),
                TextSpan(
                  text: "\nTECHNOLOGY NEPAL",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
),

                 SizedBox(height: 25),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}