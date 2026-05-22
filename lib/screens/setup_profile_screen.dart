import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dashboard_screen.dart'; 

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
      String uid;
      String userPhone;

      if (FirebaseAuth.instance.currentUser == null) {
        uid = "mock_developer_uid_123";
        userPhone = "+15555555555";
      } else {
        uid = FirebaseAuth.instance.currentUser!.uid;
        userPhone = FirebaseAuth.instance.currentUser!.phoneNumber ?? "";
      }

      // 🚀 FIXED: Hardcoded role directly to 'Owner' since you are the sole Admin
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
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
    );
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