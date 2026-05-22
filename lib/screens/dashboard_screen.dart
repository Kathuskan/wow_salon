import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// 🚀 1. FIXED: Added the missing import layer for your new slot screen
import 'manage_slots_screen.dart'; 

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _userName = "Admin";
  String _userRole = "Owner";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      String uid = "mock_developer_uid_123";
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        setState(() {
          _userName = data['name'] ?? "Admin";
          _userRole = data['role'] ?? "Owner";
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Wow Salon Hub"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/profile_setup');
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome back, $_userName!", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text("Workspace: Administrator Panel", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            const SizedBox(height: 30),
            Expanded(
              child: _buildOwnerDashboard(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOwnerDashboard() {
    return ListView(
      children: [
        Card(
          margin: const EdgeInsets.only(bottom: 15),
          child: ListTile(
            leading: const Icon(Icons.calendar_month, color: Colors.blue, size: 30),
            title: const Text("Manage Today's Slots", style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text("Open, block, or clear active timing windows"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                // 🚀 2. FIXED: Removed 'const' from before ManageSlotsScreen()
                MaterialPageRoute(builder: (context) => const ManageSlotsScreen()), // Change this to:
                // MaterialPageRoute(builder: (context) => ManageSlotsScreen()),
              );
            },
          ),
        ),
        _buildCard(Icons.book_online, "Incoming Appointments", "Approve or cancel customer booking requests"),
      ],
    );
  }

  Widget _buildCard(IconData icon, String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue, size: 30),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Future actions for appointment management go here
        },
      ),
    );
  }
}