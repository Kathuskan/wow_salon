import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Image & Branding Banner
            Container(
              height: 350,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent, Colors.lightBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.content_cut, size: 80, color: Colors.white),
                  SizedBox(height: 15),
                  Text(
                    "WOW SALON",
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2),
                  ),
                  SizedBox(height: 5),
                  Text("Premium Styling & Grooming Experience", style: TextStyle(color: Colors.white70, fontSize: 16)),
                ],
              ),
            ),

            // Salon Details Section
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("About Our Salon", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(
                    "Welcome to Wow Salon. We provide top-tier haircuts, professional coloring, and luxury spa treatments tailored to your lifestyle. Our master stylists are dedicated to making you look and feel exceptional.",
                    style: TextStyle(color: Colors.grey[700], fontSize: 15, height: 1.5),
                  ),
                  const SizedBox(height: 25),
                  
                  // Operational Hours Card
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          _buildInfoRow(Icons.access_time, "Hours", "Open Daily: 9:00 AM - 8:00 PM"),
                          const Divider(),
                          _buildInfoRow(Icons.location_on, "Location", "123 Premium Lane, Colombo, Sri Lanka"),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Call To Action Booking Button
                  ElevatedButton(
                    onPressed: () {
                      // Slide cleanly into the registration onboard view
                      Navigator.pushNamed(context, '/register');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_month),
                        SizedBox(width: 10),
                        Text("Book an Appointment Now", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueAccent),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text(value, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        )
      ],
    );
  }
}