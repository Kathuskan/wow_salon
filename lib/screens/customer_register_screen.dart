import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerRegisterScreen extends StatefulWidget {
  const CustomerRegisterScreen({super.key});

  @override
  State<CustomerRegisterScreen> createState() => _CustomerRegisterScreenState();
}

class _CustomerRegisterScreenState extends State<CustomerRegisterScreen> {
  // Step State Flag
  bool _isVerifyingSMS = false;
  bool _isLoading = false;

  // Form Field Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _pinController = TextEditingController();
  final _smsController = TextEditingController();

  String _selectedGender = 'Male';

  // 1. PHASE ONE: INITIATE ACCOUNT & DISPATCH REGISTRATION PARAMETERS
  Future<void> _sendSMSVerification() async {
    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty ||
        _pinController.text.trim().length != 6) {
      _showSnackbar(
        "Please fill all profile fields accurately. PIN must be 6 digits.",
        Colors.red,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // SECURE INPUT VALIDATION PATTERN (RegEx Check)
      final phoneRegex = RegExp(r'^\d{9,11}$');
      if (!phoneRegex.hasMatch(_phoneController.text.trim())) {
        throw Exception(
          "Invalid phone format. Enter between 9 to 11 pure digits.",
        );
      }

      // SIMULATING OUTBOUND SMS GATEWAY TRANSACTION PAYLOAD
      // In production, an HTTP POST goes out to your SMS provider bridge here.
      print(
        "TRANSMITTING OTP PAYLOAD STRING TO CELLULAR TARGET: ${_phoneController.text}",
      );
      await Future.delayed(
        const Duration(seconds: 2),
      ); // Simulate network propagation

      setState(() {
        _isLoading = false;
        _isVerifyingSMS = true; // Flip UI layout to show SMS PIN keypad entry
      });
      _showSnackbar(
        "Verification code sent via SMS text message!",
        Colors.green,
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackbar(e.toString().replaceAll("Exception: ", ""), Colors.red);
    }
  }

  // 2. PHASE TWO: VERIFY ONE-TIME CODE & WRITE TO CLOUD NO-SQL TREE
  Future<void> _verifyOTPAndCreateAccount() async {
    if (_smsController.text.trim().length != 6) {
      _showSnackbar("Please input the 6-digit verification code.", Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(milliseconds: 1500));
      // MOCK OTP INTERCEPT VALIDATION
      if (_smsController.text.trim() != "123456") {
        throw Exception(
          "Invalid SMS token provided. Please check your messages.",
        );
      }

      String customUid = "customer_${_phoneController.text.trim()}";

      // WRITE RAW FIELDS INTO CONSOLIDATED DATA MAP DOCUMENT
      await FirebaseFirestore.instance.collection('users').doc(customUid).set({
        'uid': customUid,
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'gender': _selectedGender,
        'role': 'Customer',
        'pin': _pinController.text.trim(), // Stored safely inside sandbox node
        'deviceToken': 'unregistered',
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() => _isLoading = false);

      // Clear out entry memory cards cleanly using replacement route
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/customer_dashboard');
      _showSnackbar("Profile verified and saved successfully!", Colors.green);
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackbar(e.toString().replaceAll("Exception: ", ""), Colors.red);
    }
  }

  void _showSnackbar(String text, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: bg,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _isVerifyingSMS ? 'SMS Security Lock' : 'Create Profile Ledger',
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: _isVerifyingSMS
                  ? _buildSMSVerificationLayout()
                  : _buildProfileFormLayout(),
            ),
    );
  }

  // UI BLOCK A: USER PROFILE METADATA REGISTRATION FORM
  Widget _buildProfileFormLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Join Wow Salon",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Full Name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            border: OutlineInputBorder(),
            hintText: '0771234567',
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _addressController,
          decoration: const InputDecoration(
            labelText: 'Residential Address',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedGender,
          items: [
            'Male',
            'Female',
            'Other',
          ].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
          onChanged: (val) => setState(() => _selectedGender = val!),
          decoration: const InputDecoration(
            labelText: 'Gender Identifier',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _pinController,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 6,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            labelText: 'Set Account 6-Digit PIN',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _sendSMSVerification,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.blue,
          ),
          child: const Text(
            "Request SMS Verification",
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }

  // UI BLOCK B: SECURE ONE-TIME PASSWORD MATRIX LOCK UP
  Widget _buildSMSVerificationLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.phonelink_lock, size: 80, color: Colors.blue),
        const SizedBox(height: 24),
        const Text(
          "Enter Verification Code",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          "An SMS contains a text token has been targeted to ${_phoneController.text}. Input code below to unseal profile.",
          style: const TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        const Text(
          "For testing purposes use code: 123456",
          style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        TextField(
          controller: _smsController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            letterSpacing: 8,
            fontWeight: FontWeight.bold,
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            counterText: "",
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _verifyOTPAndCreateAccount,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.green,
          ),
          child: const Text(
            "Verify Token & Register",
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
        TextButton(
          onPressed: () => setState(() => _isVerifyingSMS = false),
          child: const Text("Back to Form Modification"),
        ),
      ],
    );
  }
}
