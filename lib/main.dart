import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/landing_page.dart';
import 'screens/customer_register_screen.dart';
import 'screens/customer_dashboard_screen.dart'; // 🚀 1. Add this import statement
import 'screens/setup_profile_screen.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: const LandingPage(),
      routes: {
        '/register': (context) => const CustomerRegisterScreen(),
        '/profile_setup': (context) => const SetupProfileScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        // 🚀 2. Active path mapped exactly to our navigation trigger!
        '/customer_dashboard': (context) => const CustomerDashboardScreen(), 
      },
    );
  }
}