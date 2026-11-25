import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({super.key});

  @override
  State<CustomerDashboardScreen> createState() => _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  bool _isProcessingBooking = false;

  // SYSTEM CORE METHOD: DISPATCH BOOKING REQUEST TO FIRESTORE PIPELINE
  Future<void> _requestAppointment(String slotId, String timeSlot) async {
    setState(() => _isProcessingBooking = true);

    try {
      // 🚀 STATE TRANSITION: Flip status to 'pending' to lock it from other users
      await FirebaseFirestore.instance.collection('slots').doc(slotId).update({
        'status': 'pending',
        'bookedBy': 'mock_customer_uid', // In prod, this passes the active user's UID
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // SIMULATING OMNI-CHANNEL NOTIFICATION ROUTINES
      // In production, your Cloud Functions pick up this Firestore write event delta 
      // and command Twilio/FCM to transmit the payload blocks simultaneously.
      print("SMS DISPATCHED: Booking request for $timeSlot submitted successfully!");
      print("PUSH NOTIFICATION ALERT: Admin notified of new pending request.");

      _showSnackbar("Request submitted! Awaiting Admin approval.", Colors.amber);
    } catch (e) {
      _showSnackbar("Booking Error: $e", Colors.red);
    } finally {
      setState(() => _isProcessingBooking = false);
    }
  }

  void _showSnackbar(String msg, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: bg),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Client Hub Dashboard"),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
            tooltip: 'Log Out',
          ),
        ],
      ),
      body: _isProcessingBooking
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // User Banner Status Greeting Card
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue[800],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hello, Kathus!",
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Tap an available green card below to reserve your styling chair instantly.",
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Text("Active Appointment Schedule Matrix", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                ),

                // REAL-TIME STREAM PIPELINE: RENDERING SCHEDULER ELEMENTS
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('slots').orderBy('time').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text("No time slots configured."));
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 1.3,
                        ),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var doc = snapshot.data!.docs[index];
                          var slot = doc.data() as Map<String, dynamic>;

                          String time = slot['time'] ?? '';
                          String service = slot['serviceName'] ?? '';
                          String status = slot['status'] ?? 'available';
                          double price = (slot['price'] ?? 0.0).toDouble();

                          // Evaluating State-Driven Colors dynamically
                          Color tileColor;
                          String labelText;
                          bool canTap = false;

                          if (status == 'pending') {
                            tileColor = const Color(0xFFFFC107); // 🟡 Yellow Pending
                            labelText = "PENDING APPROVAL";
                          } else if (status == 'approved') {
                            tileColor = const Color(0xFFF44336); // 🔴 Red Confirmed Booked
                            labelText = "CONFIRMED BOOKED";
                          } else {
                            tileColor = const Color(0xFF4CAF50); // 🟢 Green Available
                            labelText = "TAP TO BOOK";
                            canTap = true;
                          }

                          return InkWell(
                            onTap: canTap ? () => _requestAppointment(doc.id, time) : null,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: tileColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(time, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 2),
                                  Text(service, style: const TextStyle(color: Colors.white, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  const Spacer(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("\$$price", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                      Text(labelText, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}