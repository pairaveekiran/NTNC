import 'package:flutter/material.dart';
import 'package:ntnc/screen/login.dart';
import 'package:ntnc/screen/dashboard.dart';
import 'package:ntnc/services/storage_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthChecker(),
    );
  }
}

// Check authentication status on app start
class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Small delay to show splash-like behavior
    await Future.delayed(const Duration(milliseconds: 500));
    
    final isLoggedIn = await StorageService.isLoggedIn();
    final token = await StorageService.getToken();
    final email = await StorageService.getUserEmail();
    
    print('Auth Check:');
    print('- Platform: ${StorageService.getPlatform()}');
    print('- Is Logged In: $isLoggedIn');
    print('- Token exists: ${token != null}');
    print('- User email: $email');
    
    if (!mounted) return;
    
    // Navigate based on auth status
    if (isLoggedIn) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DashboardHome()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xff5BA84A),
              Color(0xff3F8A30),
              Color(0xff2D6B21),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.all(12),
                child: Image.asset(
                  'assets/images/ntnc.jpeg',
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'NTNC MIS',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}