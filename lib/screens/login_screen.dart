import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'setup_profile_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _isLoading = false;
  bool _isCodeSent = false;
  bool _isPinStep = false;
  String _verificationId = '';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- HELPER TO CHECK IF USERS ARE USING THE TEST SYSTEM ---
  bool get _isMockUser =>
      _phoneController.text.trim() == "5555555555" ||
      _phoneController.text.trim() == "5551234567" ||
      _verificationId == "mock_simulator_id";

  // Step 1: Send OTP (or trigger mock code state)
  // Step 1: Advance to OTP layout without touching Firebase libraries
  Future<void> sendOtp() async {
    setState(() => _isLoading = true);

    // Simulate a brief network delay
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _isCodeSent = true;
      _verificationId = "mock_simulator_id";
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("[LOCAL DEV] Simulated code sent! Enter: 123456"),
        backgroundColor: Colors.blue,
      ),
    );
  }

  // Step 2: Advance to PIN layout safely
  Future<void> verifyOtpAndShowPin() async {
    String cleanOtp = _otpController.text.trim();

    if (cleanOtp != "123456") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid developer code. Use 123456.")),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      _isPinStep = true;
      _isLoading = false;
    });
  }

  // Step 3: Jump right into your profile configuration space
  Future<void> handlePin() async {
    String cleanPin = _pinController.text.trim();

    if (cleanPin.length != 4) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("PIN must be 4 digits")));
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() => _isLoading = false);

    _navigateToProfile();
  }

  void _navigateToProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Login Successful!"),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SetupProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Salon Login"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- STEP 1: ENTER PHONE NUMBER ---
            if (!_isCodeSent && !_isPinStep) ...[
              const Text(
                "Enter your phone number",
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: "Phone Number (e.g. 5551234567)",
                  border: OutlineInputBorder(),
                  prefixText: "+94 ",
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : sendOtp,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Send Code"),
              ),
            ],

            // --- STEP 2: ENTER OTP ---
            if (_isCodeSent && !_isPinStep) ...[
              const Text(
                "Enter the 6-digit code sent to you",
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  hintText: "123456",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : verifyOtpAndShowPin,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Verify Code"),
              ),
            ],

            // --- STEP 3: ENTER 4-DIGIT PIN ---
            if (_isPinStep) ...[
              const Text(
                "Enter your 4-digit PIN",
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 5),
              const Text(
                "New users choose a PIN. Returning users enter your saved PIN.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: "••••",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : handlePin,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Continue"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
