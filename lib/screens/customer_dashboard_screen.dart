import 'package:flutter/material.dart';

class CustomerDashboardScreen extends StatelessWidget {
  const CustomerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wow Salon Client Hub"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Smoothly return them to the landing page window on logout
              Navigator.pushReplacementNamed(context, '/');
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome to Your Dashboard!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              "Select an action below to manage your salon appointments.",
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 35),

            // Customer Action Grid/List Options
            Expanded(
              child: ListView(
                children: [
                  _buildActionCard(
                    context,
                    Icons.cut,
                    Colors.blueAccent,
                    "Book New Appointment",
                    "Browse available times and reserve a stylist",
                  ),
                  _buildActionCard(
                    context,
                    Icons.history,
                    Colors.purpleAccent,
                    "My Active Bookings",
                    "Check the status or timing details of your visits",
                  ),
                  _buildActionCard(
                    context,
                    Icons.loyalty,
                    Colors.orangeAccent,
                    "Offers & Packages",
                    "View special discounts running this month",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, IconData icon, Color color, String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 13)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          // Booking loop logic will hook in here!
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("$title feature module coming soon!")),
          );
        },
      ),
    );
  }
}