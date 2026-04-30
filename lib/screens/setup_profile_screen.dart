import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    if (_nameController.text.isEmpty) return;
    
    setState(() => _isLoading = true);

    try {
      // 1. Get the current logged-in user's ID
      String uid = FirebaseAuth.instance.currentUser!.uid;

      // 2. Save the data to Firestore in a 'users' collection
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': _nameController.text.trim(),
        'gender': _selectedGender,
        'role': _selectedRole,
        'phone': FirebaseAuth.instance.currentUser!.phoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() => _isLoading = false);
      
      // Success! 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile Saved!")),
      );
      
      // TODO: Navigate to the Home / Dashboard Screen

    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving profile: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Setup Profile"), automaticallyImplyLeading: false),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Welcome! Let's get to know you.", style: TextStyle(fontSize: 20)),
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