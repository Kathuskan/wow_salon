import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  String _activeDateString = DateFormat('yyyy-MM-dd').format(DateTime.now());
  List<DateTime> _upcomingWorkdays = [];

  @override
  void initState() {
    super.initState();
    _compileUpcomingWorkdaysList();
  }

  // Generate real calendar dates for selection bar, omitting weekends
  void _compileUpcomingWorkdaysList() {
    List<DateTime> list = [];
    DateTime target = DateTime.now();
    
    while (list.length < 5) {
      String dayName = DateFormat('EEEE').format(target);
      if (dayName != 'Saturday' && dayName != 'Sunday') {
        list.add(target);
      }
      target = target.add(const Duration(days: 1));
    }
    
    setState(() {
      _upcomingWorkdays = list;
      _activeDateString = DateFormat('yyyy-MM-dd').format(list[0]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('WOW SALON', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings, color: Colors.black),
            onPressed: () => Navigator.pushNamed(context, '/admin_dashboard'),
          ),
        ],
      ),
      body: Column(
        children: [
          // ANNOUNCEMENT STREAM BANNER
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('announcements').doc('active_banner').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || !snapshot.data!.exists) return const SizedBox.shrink();
              var data = snapshot.data!.data() as Map<String, dynamic>;
              String content = data['content'] ?? '';
              if (content.trim().isEmpty) return const SizedBox.shrink();

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                color: Colors.amber[50],
                child: Text(
                  content,
                  style: TextStyle(color: Colors.amber[900], fontWeight: FontWeight.w500, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),

          // 📆 REAL CALENDAR DATE SLIDING HORIZONTAL TABS
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: Colors.grey[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _upcomingWorkdays.map((date) {
                String dateString = DateFormat('yyyy-MM-dd').format(date);
                bool isSelected = _activeDateString == dateString;
                
                String dayAbbreviation = DateFormat('E').format(date); // e.g., "Mon"
                String dayNumber = DateFormat('d').format(date); // e.g., "25"

                return InkWell(
                  onTap: () => setState(() => _activeDateString = dateString),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.black : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(dayAbbreviation, style: TextStyle(color: isSelected ? Colors.white70 : Colors.black54, fontSize: 11)),
                        Text(dayNumber, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // LIVE STREAM APPOINTMENT CALENDAR GRID VIEW
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('slots')
                  .where('dateString', isEqualTo: _activeDateString)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                var visibleDocs = snapshot.data?.docs.where((doc) {
                      var data = doc.data() as Map<String, dynamic>;
                      return data['status'] != 'terminated';
                    }).toList() ?? [];

                visibleDocs.sort((a, b) => (a['time'] as String).compareTo(b['time'] as String));

                if (visibleDocs.isEmpty) {
                  return const Center(
                    child: Text("No appointments scheduled for this date.", style: TextStyle(color: Colors.black54)),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.8,
                  ),
                  itemCount: visibleDocs.length,
                  itemBuilder: (context, index) {
                    var doc = visibleDocs[index];
                    var slot = doc.data() as Map<String, dynamic>;

                    String time = slot['time'] ?? '';
                    String status = slot['status'] ?? 'available';

                    Color cellColor = const Color(0xFF4CAF50); // Available Green 🟢
                    bool canTap = true;

                    if (status == 'pending') {
                      cellColor = const Color(0xFFFFC107); // Pending Yellow 🟡
                      canTap = false;
                    } else if (status == 'approved') {
                      cellColor = const Color(0xFFF44336); // Confirmed Red 🔴
                      canTap = false;
                    }

                    String displayTime = time.split(' - ')[0];

                    return InkWell(
                      onTap: canTap ? () => Navigator.pushNamed(context, '/login') : null,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        decoration: BoxDecoration(color: cellColor, borderRadius: BorderRadius.circular(8)),
                        alignment: Alignment.center,
                        child: Text(displayTime, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
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