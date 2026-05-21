import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  String _userRole = 'Customer'; // Default fallback role
  bool _isLoadingRole = true;

  @override
  void Alignment() {
    super.initState();
    _fetchUserRole();
  }

  // Fetch the role ('Owner' or 'Customer') from Firestore
  Future<void> _fetchUserRole() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      
      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _userRole = data['role'] ?? 'Customer';
          _isLoadingRole = false;
        });
      } else {
        setState(() => _isLoadingRole = false);
      }
    } catch (e) {
      print("Error fetching user role: $e");
      setState(() => _isLoadingRole = false);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading spinner while we grab the role from the cloud database
    if (_isLoadingRole) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Define different tab options depending on the user role
    final List<Widget> customerTabs = [
      const Center(child: Text('Salon Details & Offers (Customer view)', style: TextStyle(fontSize: 18))),
      const Center(child: Text('Book & View My Slots (Customer view)', style: TextStyle(fontSize: 18))),
      const Center(child: Text('My Profile Settings', style: TextStyle(fontSize: 18))),
    ];

    final List<Widget> ownerTabs = [
      const Center(child: Text('Update Salon Shop Details (Owner view)', style: TextStyle(fontSize: 18))),
      const Center(child: Text('Manage Availability & Approvals (Owner view)', style: TextStyle(fontSize: 18))),
      const Center(child: Text('Owner Profile Settings', style: TextStyle(fontSize: 18))),
    ];

    // Pick the right set of tabs
    final currentTabs = _userRole == 'Owner' ? ownerTabs : customerTabs;

    return Scaffold(
      appBar: AppBar(
        title: Text(_userRole == 'Owner' ? "Wow Salon (Admin)" : "Wow Salon"),
        centerTitle: true,
      ),
      body: currentTabs.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: _userRole == 'Owner' ? Colors.deepPurple : Colors.blueAccent,
        onTap: _onItemTapped,
      ),
    );
  }
}