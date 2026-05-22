import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerRegisterScreen extends StatefulWidget {
  const CustomerRegisterScreen({super.key});

  @override
  State<CustomerRegisterScreen> createState() => _CustomerRegisterScreenState();
}

class _CustomerRegisterScreenState extends State<CustomerRegisterScreen> {
  int _currentStep = 0; // 0 = Profile Details, 1 = 6-Digit PIN assignment
  bool _isLoading = false;

  // Form Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _pinController = TextEditingController();

  String _selectedGender = 'Male';

  void _nextStep() {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty || _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all registration fields")),
      );
      return;
    }
    setState(() => _currentStep = 1); // Move forward into the secure PIN layout view
  }

  Future<void> _completeRegistration() async {
    String cleanPin = _pinController.text.trim();
    if (cleanPin.length != 6 || int.tryParse(cleanPin) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Your passcode must be exactly 6 numerical digits")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create a unique mock user ID linked directly to their phone number for easy local testing
      String mockUid = "customer_${_phoneController.text.trim()}";

      // Save our organized data map to the 'users' directory collection folder
      await FirebaseFirestore.instance.collection('users').doc(mockUid).set({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'gender': _selectedGender,
        'role': 'Customer',
        'pin': cleanPin,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account Registered Successfully!"), backgroundColor: Colors.green),
      );

      // Route cleanly into the customer experience workspace dashboard
      Navigator.pushReplacementNamed(context, '/customer_dashboard');
    } catch (e) {
      setState(() => _isLoading = false);
      print("Database Write Registration Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_currentStep == 0 ? "Create Account" : "Secure Your Account")),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : _currentStep == 0 ? _buildDetailsForm() : _buildPinForm(),
      ),
    );
  }

  // Layout Panel 1: Profile Details Gathering
  Widget _buildDetailsForm() {
    return ListView(
      children: [
        const Text("Join Wow Salon", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        const Text("Enter your credentials to book dynamic styling slots.", style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 25),
        TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Full Name", border: OutlineInputBorder())),
        const SizedBox(height: 20),
        TextField(controller: _phoneController, decoration: const InputDecoration(labelText: "Phone Number", border: OutlineInputBorder()), keyboardType: TextInputType.phone),
        const SizedBox(height: 20),
        TextField(controller: _addressController, decoration: const InputDecoration(labelText: "Residential Address", border: OutlineInputBorder())),
        const SizedBox(height: 20),
        DropdownButtonFormField<String>(
          value: _selectedGender,
          decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Gender Identity"),
          items: ['Male', 'Female', 'Other'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
          onChanged: (val) => setState(() => _selectedGender = val!),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: _nextStep,
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(15)),
          child: const Text("Continue to PIN Setup", style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  // Layout Panel 2: Secure Access 6-Digit PIN configuration setup
  Widget _buildPinForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.lock_outline, size: 70, color: Colors.blueAccent),
        const SizedBox(height: 20),
        const Text("Set your Security PIN", textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        const Text("You will use this 6-digit code along with your phone number to sign in next time.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 30),
        TextField(
          controller: _pinController,
          decoration: const InputDecoration(labelText: "6-Digit Access PIN", border: OutlineInputBorder(), counterText: ""),
          maxLength: 6,
          obscureText: true,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, letterSpacing: 10, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: _completeRegistration,
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(15), backgroundColor: Colors.green, foregroundColor: Colors.white),
          child: const Text("Complete & Launch App", style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
}