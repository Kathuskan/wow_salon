import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/setup_profile_screen.dart'; // 🚀 FIXED: Added the missing file import layer here
import 'screens/dashboard_screen.dart';
import 'screens/landing_page.dart';
import 'screens/customer_register_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with our cross-platform options
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const SalonApp());
}

class SalonApp extends StatelessWidget {
  const SalonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wow Salon',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),

      // 1. The app starts directly on the Admin Dashboard interface
      home: const LandingPage(),
      // 2. Wire up the navigation route path map for the logout fallback redirection
      routes: {
      '/register': (context) => const CustomerRegisterScreen(),
      '/profile_setup': (context) => const SetupProfileScreen(),
      '/dashboard': (context) => const DashboardScreen(),
      // We will create this customer panel view hub next!
      // '/customer_dashboard': (context) => const CustomerDashboardScreen(), 
    },
    );
  }
}
