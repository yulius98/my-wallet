import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_wallet/core/constants/app_constants.dart';
import 'package:my_wallet/presentation/screens/home_screen.dart';
import 'package:my_wallet/services/auth_service.dart';
import 'package:my_wallet/presentation/screens/auth/login_screen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
} 

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToAuth();
  }

  Future<void> _navigateToAuth() async {
    // Minimal delay for smooth transition (reduced from 1500 to 500ms)
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const AuthWrapper()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppConstants.backgroundPath),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                AppConstants.logoPath,
                height: 340,
                width: 340,),
              const Text(
                AppConstants.appName,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 40),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget untuk cek status login secara otomatis
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.authStateChanges,
      builder: (context, snapshot) {
        // While waiting for stream, check current user immediately
        if (snapshot.connectionState == ConnectionState.waiting) {
          final user = AuthService.currentUser;
          if (user != null) {
            return const HomeScreen();
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If user is logged in
        if (snapshot.hasData && snapshot.data != null) {
          return const HomeScreen();
        }

        // User is not logged in
        return const LoginScreen();
      },
    );
  }
}