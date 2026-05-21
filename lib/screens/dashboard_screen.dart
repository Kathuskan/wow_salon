import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _userName = "User";
  String _userRole = "Customer";
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
          _userName = data['name'] ?? "User";
          _userRole = data['role'] ?? "Customer";
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
            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome back, $_userName!", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text("Account Mode: $_userRole", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            const SizedBox(height: 30),
            Expanded(
              child: _userRole == "Owner" ? _buildOwnerDashboard() : _buildCustomerDashboard(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOwnerDashboard() {
    return ListView(
      children: [
        _buildCard(Icons.calendar_month, "Manage Today's Slots", "Open, block, or clear active timing windows"),
        _buildCard(Icons.book_online, "Incoming Appointments", "Approve or cancel customer booking requests"),
      ],
    );
  }

  Widget _buildCustomerDashboard() {
    return ListView(
      children: [
        _buildCard(Icons.cut, "Book an Appointment", "Choose a stylist and schedule your next visit"),
        _buildCard(Icons.history, "My Appointments", "Check status entries of active or previous visits"),
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
      ),
    );
  }
}