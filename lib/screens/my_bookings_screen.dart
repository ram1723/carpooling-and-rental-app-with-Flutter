import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  Future<List<Map<String, dynamic>>> _fetchBookings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('userId', isEqualTo: user.uid)
          .orderBy('startDate', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['bookingId'] = doc.id; // ensure ID is included
        return data;
      }).toList();
    } catch (e) {
      print("Error fetching bookings: $e");
      return [];
    }
  }

  Future<void> _cancelBooking(String bookingId) async {
    try {
      await FirebaseFirestore.instance.collection('bookings').doc(bookingId).delete();
    } catch (e) {
      print("Error canceling booking: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Bookings"),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final bookings = snapshot.data ?? [];

          if (bookings.isEmpty) {
            return const Center(child: Text("No bookings yet!"));
          }

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              final bookingId = booking['bookingId'] ?? '';

              final startDate = booking['startDate'] != null
                  ? (booking['startDate'] as Timestamp).toDate()
                  : DateTime.now();
              final endDate = booking['endDate'] != null
                  ? (booking['endDate'] as Timestamp).toDate()
                  : DateTime.now();

              return Dismissible(
                key: Key(bookingId),
                direction: DismissDirection.endToStart,
                onDismissed: (_) async {
                  await _cancelBooking(bookingId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Booking for ${booking['carName']} cancelled.")),
                  );
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: Card(
                  margin: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const Icon(Icons.directions_car, color: Colors.black87),
                    title: Text("${booking['carName']} (${booking['carModel']})"),
                    subtitle: Text(
                      "📅 ${startDate.toLocal().toString().split(' ')[0]} → ${endDate.toLocal().toString().split(' ')[0]}\n₹ ${booking['pricePerDay']} per day",
                    ),
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
