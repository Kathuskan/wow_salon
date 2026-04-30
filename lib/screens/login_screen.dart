import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'setup_profile_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers to read the text typed by the user
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  // Variables to manage the screen's state
  bool _isLoading = false;
  bool _isCodeSent = false;
  String _verificationId = '';

  // Instance of Firebase Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Function 1: Ask Firebase to send an SMS
  Future<void> sendOtp() async {
    setState(() => _isLoading = true);

    await _auth.verifyPhoneNumber(
      phoneNumber:
          '+1${_phoneController.text.trim()}', // Note: Hardcoded to +1 (US/Canada) for now. Change to your country code if needed!
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-resolution (sometimes works on Android without typing the code)
        await _auth.signInWithCredential(credential);
        print("Auto-logged in!");
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Verification failed')),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        // The SMS was sent! Save the ID and update the UI
        setState(() {
          _verificationId = verificationId;
          _isCodeSent = true;
          _isLoading = false;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  // Function 2: Verify the 6-digit code the user typed
  Future<void> verifyOtp() async {
    setState(() => _isLoading = true);

    try {
      // Create a credential from the ID we saved and the code they typed
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _otpController.text.trim(),
      );

      // Sign in to Firebase!
      await _auth.signInWithCredential(credential);

      setState(() => _isLoading = false);

      // Success Message
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Login Successful!")));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SetupProfileScreen()),
      );
      
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid OTP code. Try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Salon Login")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- STATE 1: ENTER PHONE NUMBER ---
            if (!_isCodeSent) ...[
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
                  prefixText: "+1 ", // Update country code here if needed
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

            // --- STATE 2: ENTER OTP CODE ---
            if (_isCodeSent) ...[
              const Text(
                "Enter the 6-digit code",
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
                onPressed: _isLoading ? null : verifyOtp,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Verify & Login"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
