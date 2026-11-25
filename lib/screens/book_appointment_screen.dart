import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookAppointmentScreen extends StatelessWidget {
  const BookAppointmentScreen({super.key});

  // Action logic to claim an open slot in the database
  Future<void> _bookSlot(BuildContext context, String slotId, String time) async {
    try {
      await FirebaseFirestore.instance.collection('slots').doc(slotId).update({
        'isBooked': true,
        'bookedBy': "mock_developer_uid_123", // Linked to the active session id
      });

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Successfully reserved your appointment for $time!"), backgroundColor: Colors.green),
      );
      Navigator.pop(context); // Slide back to dashboard hub
    } catch (e) {
      print("Booking submission error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Available Slots"), centerTitle: true),
      body: StreamBuilder<QuerySnapshot>(
        // 🚀 Real-time database query filtering for unbooked sessions
        stream: FirebaseFirestore.instance
            .collection('slots')
            .where('isBooked', isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(25.0),
                child: Text(
                  "No open time slots available at the moment. Check back soon!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            );
          }

          final documents = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final doc = documents[index];
              final data = doc.data() as Map<String, dynamic>;
              final String time = data['time'] ?? '';
              final String service = data['serviceName'] ?? 'General Styling';
              final double price = (data['price'] ?? 0.0).toDouble();

              return Card(
                margin: const EdgeInsets.only(bottom: 15),
                elevation: 2,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(15),
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.star, color: Colors.white),
                  ),
                  title: Text(service, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Text("$time\n\$${price.toStringAsFixed(2)}", style: const TextStyle(height: 1.5)),
                  trailing: ElevatedButton(
                    onPressed: () => _bookSlot(context, doc.id, time),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    child: const Text("Book"),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}