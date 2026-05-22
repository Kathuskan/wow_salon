import 'package:cloud_firestore/cloud_firestore.dart';

class SalonSlot {
  final String id;
  final String time;        // e.g., "10:00 AM"
  final String serviceName; // e.g., "Haircut & Styling"
  final double price;       // e.g., 25.0
  final bool isBooked;

  SalonSlot({
    required this.id,
    required this.time,
    required this.serviceName,
    required this.price,
    this.isBooked = false,
  });

  // Convert Firestore Document data back into this Dart object
  factory SalonSlot.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SalonSlot(
      id: doc.id,
      time: data['time'] ?? '',
      serviceName: data['serviceName'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      isBooked: data['isBooked'] ?? false,
    );
  }

  // Convert this Dart object into a Map to save to Firestore
  Map<String, dynamic> toMap() {
    return {
      'time': time,
      'serviceName': serviceName,
      'price': price,
      'isBooked': isBooked,
    };
  }
}