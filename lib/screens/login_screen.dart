import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isVerifyingSMS = false;
  bool _isLoading = false;

  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  final _smsController = TextEditingController();

  // 1. INITIATE LOGIN HANDSHAKE & RUN DB LOOKUP ACCURACY CHECKS
  Future<void> _requestLoginSMSGate() async {
    String phone = _phoneController.text.trim();
    String pin = _pinController.text.trim();

    if (phone.isEmpty || pin.length != 6) {
      _showSnackbar("Please enter a valid phone number and your 6-digit security PIN.", Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Direct Lookup Check against explicit phone document naming convention
      String userDocPath = "customer_$phone";
      var userDoc = await FirebaseFirestore.instance.collection('users').doc(userDocPath).get();

      if (!userDoc.exists) {
        throw Exception("No profile registry matching this phone identifier found.");
      }

      var userData = userDoc.data() as Map<String, dynamic>;
      if (userData['pin'] != pin) {
        throw Exception("Security PIN verification failed. Access Denied.");
      }

      // CREDENTIALS VALIDATED MATCHED -> SEND SMS OUTBOUND CODE TOKEN
      print("TRANSMITTING LOGIN OTP CELLULAR PACKET TARGET: $phone");
      await Future.delayed(const Duration(milliseconds: 1500));

      setState(() {
        _isLoading = false;
        _isVerifyingSMS = true; // Swap display template fields gracefully
      });
      _showSnackbar("Login verification token dispatched via secure SMS text!", Colors.green);

    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackbar(e.toString().replaceAll("Exception: ", ""), Colors.red);
    }
  }

  // 2. VERIFY ONE-TIME SMS SECURITY PACKET TOKEN & SEAL PASS
  Future<void> _verifyLoginOTPSignature() async {
    if (_smsController.text.trim().length != 6) {
      _showSnackbar("Please input the 6-digit verification code.", Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(seconds: 1));

      // MOCK OTP TRANSACTION TRAP
      if (_smsController.text.trim() != "123456") {
        throw Exception("Invalid SMS verification token. Re-enter code parameters.");
      }

      setState(() => _isLoading = false);
      
      // Smash historical route cards cleanly and pass directly into Customer Dashboard view tree
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/customer_dashboard');
      _showSnackbar("Login verification complete. Welcome back!", Colors.green);

    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackbar(e.toString().replaceAll("Exception: ", ""), Colors.red);
    }
  }

  void _showSnackbar(String text, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), backgroundColor: bg));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_isVerifyingSMS ? 'SMS Authorization Lock' : 'Client Access Portal'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: _isVerifyingSMS ? _buildSMSLoginVerificationLayout() : _buildLoginFormLayout(),
            ),
    );
  }

  // PORTAL WINDOW TEMPLATE A: CARD PROFILE DISCOVERY INPUT LAYOUTS
  Widget _buildLoginFormLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        const Text("Sign In to Wow Salon", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        const SizedBox(height: 30),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(labelText: 'Registered Phone Number', border: OutlineInputBorder(), hintText: '0771234567'),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _pinController,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 6,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(labelText: '6-Digit Account Security PIN', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _requestLoginSMSGate,
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.black, foregroundColor: Colors.white),
          child: const Text("Verify Credentials & Request SMS", style: TextStyle(fontSize: 15)),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/register'),
          child: const Text("New customer? Create a profile here", style: TextStyle(color: Colors.blue)),
        )
      ],
    );
  }

  // PORTAL WINDOW TEMPLATE B: SMS SECURE SIGNATURE CHECKS
  Widget _buildSMSLoginVerificationLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.security, size: 80, color: Colors.black87),
        const SizedBox(height: 24),
        const Text("Enter Access Code", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        const SizedBox(height: 10),
        Text(
          "Type the 6-digit text token targeted to cellular string: ${_phoneController.text}",
          style: const TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        const Text("For testing purposes use code: 123456", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        const SizedBox(height: 30),
        TextField(
          controller: _smsController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(border: OutlineInputBorder(), counterText: ""),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _verifyLoginOTPSignature,
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.green, foregroundColor: Colors.white),
          child: const Text("Confirm & Open Hub Dashboard", style: TextStyle(fontSize: 15)),
        ),
        TextButton(
          onPressed: () => setState(() => _isVerifyingSMS = false),
          child: const Text("Back to Identification Modification"),
        )
      ],
    );
  }
}