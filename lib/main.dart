import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/landing_page.dart';
import 'screens/login_screen.dart';
import 'screens/customer_register_screen.dart';
import 'screens/customer_dashboard_screen.dart';
import 'screens/setup_profile_screen.dart';
import 'screens/dashboard_screen.dart'; // 🚀 Admin Dashboard

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
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      // 🚀 The app MUST boot directly to the guest storefront window
      home: const LandingPage(),
      
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const CustomerRegisterScreen(),
        '/customer_dashboard': (context) => const CustomerDashboardScreen(),
        '/admin_dashboard': (context) => const DashboardScreen(), // 🚀 Admin Control Panel
        '/profile_setup': (context) => const SetupProfileScreen(),
      },
    );
  }
}