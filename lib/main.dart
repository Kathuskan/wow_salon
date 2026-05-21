import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

// 1. This is the crucial part that was missing or skipped!
void main() async {
  // Ensure Flutter bindings are ready before interacting with native code
  WidgetsFlutterBinding.ensureInitialized();
  
  // Turn on Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const SalonApp());
}

class SalonApp extends StatelessWidget {
  const SalonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Salon App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      // 2. Now it is safe to check the auth state because Firebase is initialized
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // If the snapshot has user data, they are logged in.
          if (snapshot.hasData) {
            return DashboardScreen(); 
          }
          // Otherwise, they are not logged in.
          return const LoginScreen();
        },
      ),
    );
  }
}