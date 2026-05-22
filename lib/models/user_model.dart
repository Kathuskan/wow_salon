// lib/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class SalonUser {
  final String uid;
  final String name;
  final String phone;
  final String address;
  final String gender;
  final String role; // Always 'Customer' for this flow
  final String pin;  // Encrypted or plain 6-digit pin for local testing

  SalonUser({
    required this.uid,
    required this.name,
    required this.phone,
    required this.address,
    required this.gender,
    this.role = 'Customer',
    required this.pin,
  });

  // Convert Firestore data snapshot back into a clean Dart Object
  factory SalonUser.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SalonUser(
      uid: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      gender: data['gender'] ?? '',
      role: data['role'] ?? 'Customer',
      pin: data['pin'] ?? '',
    );
  }

  // Convert our variables into a Map structure to push to Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
      'gender': gender,
      'role': role,
      'pin': pin, // In a production app, this would be encrypted!
    };
  }
}