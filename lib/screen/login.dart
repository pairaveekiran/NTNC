import 'package:flutter/material.dart';
import 'package:ntnc/screen/dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          /// Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/bg4.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          /// Dark Overlay
          Container(
            color: Colors.black.withOpacity(0.35),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  /// Top Logo
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.asset(
                        "assets/images/ntnc.jpeg",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// Title
                  const Text(
                    "NATIONAL TRUST FOR",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const Text(
                    "NATIONAL CONSERVATION",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Conserving Nature. Preserving Life",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// Login Card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Username Label
                        const Row(
                          children: [
                            Icon(
                              Icons.account_circle,
                              color: Color(0xff1E6A34),
                              size: 30,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Username",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        /// Email Field
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: "Enter email",
                            prefixIcon: const Icon(Icons.mail_outline),
                            filled: true,
                            fillColor: const Color(0xffF4F4F4),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 18),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        /// Password Label
                        const Row(
                          children: [
                            Icon(
                              Icons.lock_person,
                              color: Color(0xff1E6A34),
                              size: 30,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Password",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        /// Password Field
                        TextField(
                          controller: passwordController,
                          obscureText: obscurePassword,
                          decoration: InputDecoration(
                            hintText: "Enter password",
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  obscurePassword = !obscurePassword;
                                });
                              },
                            ),
                            filled: true,
                            fillColor: const Color(0xffF4F4F4),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 18),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// Login Button
                        Center(
                          child: SizedBox(
                            width: 220,
                            height: 58,
                            child: ElevatedButton(
                              onPressed: () {
                                String email =
                                    emailController.text.trim();
                                String password =
                                    passwordController.text.trim();

                                if (email.isEmpty || password.isEmpty) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text("Please fill all fields"),
                                    ),
                                  );
                                  return;
                                }
                                Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DashboardHome(),
          ),
        );

                                // ScaffoldMessenger.of(context)
                                //     .showSnackBar(
                                //   const SnackBar(
                                //     content: Text("Login Clicked"),
                                //   ),
                                // );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xff165E2D),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(30),
                                ),
                                elevation: 5,
                              ),
                              child: const Text(
                                "Login",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),
                         /// Divider With Leaf
                         LayoutBuilder(
  builder: (context, constraints) {
    return Row(
      children: [
        const Expanded(
          child: Divider(thickness: 1),
        ),
        const SizedBox(width: 8),
        SizedBox(
          height: 24,
          width: 24,
          child: Image.asset("assets/images/leaves.png"),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Divider(thickness: 1),
        ),
      ],
    );
  },
),



                          const SizedBox(height: 8),

                        /// Forgot Password
                        Center(
                          child: TextButton(
                            onPressed: () {},
                            child: const Text(
                              "Forget password?",
                              style: TextStyle(
                                color: Color(0xff31A651),
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        /// Sign Up Container
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xffF5F5F5),
                            borderRadius:
                                BorderRadius.circular(25),
                          ),
                          child: const Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Not a Member?",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                "Sign up now >",
                                style: TextStyle(
                                  color: Color(0xff31A651),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// Bottom Logo
                  Column(
  children: [
    Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          "assets/images/techlogo.png",
          height: 25,
          width: 25,
          fit: BoxFit.cover,
        ),
      ),
    ),
    const SizedBox(height: 10),
    const Text(
      "Powered By: Websoft Technology",
      style: TextStyle(
        color: Colors.white,
        fontSize: 14,
      ),
    ),
    const SizedBox(height: 20),
  ],
)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}