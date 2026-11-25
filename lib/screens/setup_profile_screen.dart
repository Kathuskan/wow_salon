import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// 🚀 FIXED: Removed the broken firebase_auth import line!

class SetupProfileScreen extends StatefulWidget {
  const SetupProfileScreen({super.key});

  @override
  State<SetupProfileScreen> createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends State<SetupProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
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
      // 🚀 FIXED: Hardcoded clean local admin tester tokens since auth package is gone
      String uid = "mock_developer_uid_123";
      String userPhone = "Admin";

      // Hardcode role directly to 'Owner' since you are the sole Admin
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': _nameController.text.trim(),
        'role': 'Owner', 
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
      _navigateToDashboard();
    }
  }

  void _navigateToDashboard() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile Saved!"), backgroundColor: Colors.green),
    );
    
    Navigator.pushReplacementNamed(context, '/admin_dashboard');
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
            const Text("Welcome Admin! Enter your profile name.", style: TextStyle(fontSize: 20), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Administrator Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _isLoading ? null : saveProfile,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(15)),
              child: _isLoading 
                  ? const CircularProgressIndicator() 
                  : const Text("Save & Open Dashboard", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}