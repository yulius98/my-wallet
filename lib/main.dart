import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_wallet/core/constants/app_constants.dart';
import 'package:my_wallet/core/theme/app_theme.dart';
import 'package:my_wallet/data/local/hive_boxes.dart';
import 'package:my_wallet/presentation/screens/auth/login_screen.dart';
import 'package:my_wallet/presentation/screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  debugPrint('🚀 App starting...');

  try {
    // Initialize Firebase and Hive in parallel
    debugPrint('⏳ Initializing Firebase and Hive...');
    await Future.wait([
      Firebase.initializeApp().then(
        (_) => debugPrint('✅ Firebase initialized'),
      ),
      initHiveBoxes(),
    ]);
    debugPrint('✅ All initializations completed');
  } catch (e) {
    debugPrint('❌ Initialization error: $e');
  }

  debugPrint('▶️ Running app...');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        AppConstants.loginRoute: (context) => const LoginScreen(),
      },
    );
  }
}
