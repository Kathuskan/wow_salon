import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/slot_model.dart';

class SalonService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🚀 Get a live stream of slots for today
  Stream<List<SalonSlot>> streamTodaySlots() {
    return _db.collection('slots')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SalonSlot.fromFirestore(doc))
            .toList());
  }

  // 🚀 Add a new time slot to the board
  Future<void> addNewSlot(String time, String service, double price) async {
    await _db.collection('slots').add({
      'time': time,
      'serviceName': service,
      'price': price,
      'isBooked': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 🚀 Delete a slot
  Future<void> deleteSlot(String slotId) async {
    await _db.collection('slots').doc(slotId).delete();
  }
}