import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Handles clean calendar date conversions

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _announcementController = TextEditingController();
  bool _isLoading = false;
  
  // Track selected date filter - defaults to today
  String _selectedDateFilter = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    // 🚀 AUTOMATION TRIGGER: Automatically generate upcoming rolling calendar dates
    _autoGenerateUpcomingCalendarDates();
  }

  // CORE LOGIC ENGINE: GENERATE WORKDAYS FOR THE UPCOMING 7 DAYS
  Future<void> _autoGenerateUpcomingCalendarDates() async {
    List<String> pure1HourBlocks = [
      '09:00 AM - 10:00 AM',
      '10:00 AM - 11:00 AM',
      '11:00 AM - 12:00 PM',
      '02:00 PM - 03:00 PM',
      '03:00 PM - 04:00 PM',
      '04:00 PM - 05:00 PM',
    ];

    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      DateTime today = DateTime.now();

      // Loop through the next 7 calendar days dynamically
      for (int i = 0; i < 7; i++) {
        DateTime targetDate = today.add(Duration(days: i));
        String dayOfWeek = DateFormat('EEEE').format(targetDate); // e.g., "Monday"
        String dateString = DateFormat('yyyy-MM-dd').format(targetDate); // e.g., "2026-05-25"

        // 🚫 WEEKEND FILTER: Skip Saturdays and Sundays completely
        if (dayOfWeek == 'Saturday' || dayOfWeek == 'Sunday') continue;

        for (String slot in pure1HourBlocks) {
          // Unique key combining exact date format and time frame string
          String docId = "${dateString}_${slot.replaceAll(' ', '').replaceAll(':', '')}";
          DocumentReference docRef = FirebaseFirestore.instance.collection('slots').doc(docId);

          // Merge prevents overwriting active client records across app reboots
          batch.set(docRef, {
            'dateString': dateString,
            'dayOfWeek': dayOfWeek,
            'time': slot,
            'status': 'available',
            'bookedBy': 'none',
            'customRequestedService': ''
          }, SetOptions(merge: true));
        }
      }
      await batch.commit();
    } catch (e) {
      print("Dynamic Date Seeding Exception: $e");
    }
  }

  // PURGE VALVE: Flush and completely clean the slate
  Future<void> _hardResetAllDatabaseSlots() async {
    setState(() => _isLoading = true);
    try {
      var currentSlotsSnapshot = await FirebaseFirestore.instance.collection('slots').get();
      WriteBatch deleteBatch = FirebaseFirestore.instance.batch();
      
      for (var doc in currentSlotsSnapshot.docs) {
        deleteBatch.delete(doc.reference);
      }
      await deleteBatch.commit();

      await _autoGenerateUpcomingCalendarDates();
      _showSnackbar("All records flushed! Re-generated clean upcoming calendar dates.", Colors.green);
    } catch (e) {
      _showSnackbar("Reset Failure: $e", Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _terminateEntireDay(String targetDateString) async {
    setState(() => _isLoading = true);
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('slots')
          .where('dateString', isEqualTo: targetDateString)
          .get();
          
      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'status': 'terminated'});
      }
      await batch.commit();
      _showSnackbar("Terminated all operations for date: $targetDateString", Colors.orange);
    } catch (e) {
      _showSnackbar("Termination Error: $e", Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateSlotStatus(String slotId, String newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('slots').doc(slotId).update({
        'status': newStatus,
        if (newStatus == 'available') ...{
          'bookedBy': 'none',
          'customRequestedService': ''
        }
      });
      _showSnackbar("Slot updated to: $newStatus", Colors.blue);
    } catch (e) {
      _showSnackbar("Update Error: $e", Colors.red);
    }
  }

  Future<void> _postAnnouncement() async {
    if (_announcementController.text.trim().isEmpty) return;
    try {
      await FirebaseFirestore.instance.collection('announcements').doc('active_banner').set({
        'content': _announcementController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _announcementController.clear();
      FocusScope.of(context).unfocus();
      _showSnackbar("Announcement broadcasted live!", Colors.green);
    } catch (e) {
      _showSnackbar("Error posting announcement: $e", Colors.red);
    }
  }

  void _showSnackbar(String msg, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: bg));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Admin Operations Console"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ANNOUNCEMENT MODULE
                  Card(
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Broadcast Page Announcement", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _announcementController,
                            decoration: const InputDecoration(hintText: "Type operational updates...", border: OutlineInputBorder()),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: _postAnnouncement,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[700], foregroundColor: Colors.white),
                            child: const Text("Publish Live Banner"),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // TERMINATE CURRENT SELECTED DATE CONTROL
                  Card(
                    color: Colors.red[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Emergency Date Closure", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red[900])),
                          const SizedBox(height: 8),
                          Text("Click to close down all styling sessions for currently selected date ($_selectedDateFilter).", style: const TextStyle(fontSize: 12, color: Colors.black54)),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700], foregroundColor: Colors.white),
                            onPressed: () => _terminateEntireDay(_selectedDateFilter),
                            child: Text("Close Out $_selectedDateFilter"),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // LIVE GRID CALENDAR LEDGER HEADLINE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Live Schedule Requests Ledger", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      IconButton(
                        icon: const Icon(Icons.date_range, color: Colors.blue),
                        onPressed: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 30)),
                          );
                          if (picked != null) {
                            setState(() {
                              _selectedDateFilter = DateFormat('yyyy-MM-dd').format(picked);
                            });
                          }
                        },
                      )
                    ],
                  ),
                  Text("Viewing Agenda Date: $_selectedDateFilter", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),

                  // REAL-TIME LEDGER STREAM LIST
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('slots')
                        .where('dateString', isEqualTo: _selectedDateFilter)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Text("No operational slots open for this date (Salon closed/Weekend)."),
                          ),
                        );
                      }

                      var sortedDocs = snapshot.data!.docs;
                      sortedDocs.sort((a, b) => (a['time'] as String).compareTo(b['time'] as String));

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: sortedDocs.length,
                        itemBuilder: (context, index) {
                          var doc = sortedDocs[index];
                          var slot = doc.data() as Map<String, dynamic>;
                          String time = slot['time'] ?? '';
                          String status = slot['status'] ?? 'available';
                          String userRequirement = slot['customRequestedService'] ?? '';

                          Color indicatorColor = Colors.green;
                          if (status == 'pending') indicatorColor = Colors.amber;
                          if (status == 'approved') indicatorColor = Colors.red;
                          if (status == 'terminated') indicatorColor = Colors.grey;

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(backgroundColor: indicatorColor, radius: 8),
                              title: Text(time),
                              subtitle: Text(status == 'pending' ? "Wants: $userRequirement" : "Status: ${status.toUpperCase()}"),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (status == 'pending') ...[
                                    IconButton(
                                      icon: const Icon(Icons.check_circle, color: Colors.green),
                                      onPressed: () => _updateSlotStatus(doc.id, 'approved'),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.cancel, color: Colors.orange),
                                      onPressed: () => _updateSlotStatus(doc.id, 'available'),
                                    ),
                                  ],
                                  if (status != 'terminated')
                                    IconButton(
                                      icon: const Icon(Icons.block, color: Colors.red),
                                      onPressed: () => _updateSlotStatus(doc.id, 'terminated'),
                                    ),
                                  if (status == 'terminated')
                                    IconButton(
                                      icon: const Icon(Icons.refresh, color: Colors.blue),
                                      onPressed: () => _updateSlotStatus(doc.id, 'available'),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  OutlinedButton.icon(
                    onPressed: _hardResetAllDatabaseSlots,
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    label: const Text("TEMPORARY: Hard Purge & Reset Database Slots", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16), side: const BorderSide(color: Colors.red, width: 1.5)),
                  ),
                ],
              ),
            ),
    );
  }
}