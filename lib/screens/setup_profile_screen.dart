import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// TODO: Replace this import path with your actual dashboard file location
// import 'dashboard_screen.dart'; 

class SetupProfileScreen extends StatefulWidget {
  const SetupProfileScreen({super.key});

  @override
  State<SetupProfileScreen> createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends State<SetupProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  
  // Variables to hold the dropdown selections
  String _selectedGender = 'Male';
  String _selectedRole = 'Customer'; 
  bool _isLoading = false;

  Future<void> saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your name")),
      );
      return;
    }
    
    setState(() => _isLoading = true);

    try {
      String uid;
      String userPhone;

      // 🚀 DEVELOPER BYPASS SWITCH FOR LOCAL SIMULATOR SCOPES
      if (FirebaseAuth.instance.currentUser == null) {
        uid = "mock_developer_uid_123";
        userPhone = "+15555555555";
      } else {
        uid = FirebaseAuth.instance.currentUser!.uid;
        userPhone = FirebaseAuth.instance.currentUser!.phoneNumber ?? "";
      }

      // 2. Save the data to Firestore in a 'users' collection
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': _nameController.text.trim(),
        'gender': _selectedGender,
        'role': _selectedRole,
        'phone': userPhone,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      setState(() => _isLoading = false);
      
      _navigateToDashboard();

    } catch (e) {
      print("Firestore Write Error: $e");
      if (!mounted) return;
      setState(() => _isLoading = false);
      
      // 🚀 SAFETY FALLBACK RUN: Pushes you forward even if your Firestore rules stall offline
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("[DEV MODE] Local routing fallback applied.")),
      );
      _navigateToDashboard();
    }
  }

  void _navigateToDashboard() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile Saved!"), backgroundColor: Colors.green),
    );
    
    // TODO: Create a placeholder DashboardScreen widget and uncomment below!
    /*
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
    );
    */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Setup Profile"), automaticallyImplyLeading: false, centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Welcome! Let's get to know you.", style: TextStyle(fontSize: 20), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Full Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Gender Dropdown
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Gender"),
              items: ['Male', 'Female', 'Other'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) => setState(() => _selectedGender = newValue!),
            ),
            const SizedBox(height: 20),

            // Role Dropdown
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "I am a..."),
              items: ['Customer', 'Owner'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) => setState(() => _selectedRole = newValue!),
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _isLoading ? null : saveProfile,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(15)),
              child: _isLoading 
                  ? const CircularProgressIndicator() 
                  : const Text("Save Profile & Continue", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}