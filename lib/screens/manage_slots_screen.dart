import 'package:flutter/material.dart';
import '../services/salon_service.dart';
import '../models/slot_model.dart';

class ManageSlotsScreen extends StatefulWidget {
  const ManageSlotsScreen({super.key});

  @override
  State<ManageSlotsScreen> createState() => _ManageSlotsScreenState();
}

class _ManageSlotsScreenState extends State<ManageSlotsScreen> {
  final SalonService _salonService = SalonService();
  final _timeController = TextEditingController();
  final _serviceController = TextEditingController();
  final _priceController = TextEditingController();

  void _showAddSlotDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Create Appointment Slot"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _timeController, decoration: const InputDecoration(labelText: "Time (e.g., 2:00 PM)")),
            TextField(controller: _serviceController, decoration: const InputDecoration(labelText: "Service Name")),
            TextField(controller: _priceController, decoration: const InputDecoration(labelText: "Price"), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (_timeController.text.isNotEmpty && _serviceController.text.isNotEmpty) {
                await _salonService.addNewSlot(
                  _timeController.text.trim(),
                  _serviceController.text.trim(),
                  double.tryParse(_priceController.text.trim()) ?? 0.0,
                );
                _timeController.clear();
                _serviceController.clear();
                _priceController.clear();
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text("Add Slot"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Today's Slots"), centerTitle: true),
      body: StreamBuilder<List<SalonSlot>>(
        stream: _salonService.streamTodaySlots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No operational time slots configured for today."));
          }

          final slots = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: slots.length,
            itemBuilder: (context, index) {
              final slot = slots[index];
              return Card(
                color: slot.isBooked ? Colors.green[50] : Colors.white,
                child: ListTile(
                  leading: const Icon(Icons.access_time, color: Colors.blue),
                  title: Text("${slot.time} - ${slot.serviceName}"),
                  subtitle: Text("\$${slot.price.toStringAsFixed(2)} | Status: ${slot.isBooked ? 'Booked' : 'Available'}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _salonService.deleteSlot(slot.id),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSlotDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}