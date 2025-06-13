import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CarPoolDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> carpoolDetails;
  final String carpoolId;

  const CarPoolDetailsScreen({
    Key? key,
    required this.carpoolDetails,
    required this.carpoolId,
  }) : super(key: key);

  Future<void> _bookCarpool(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must be logged in to book a carpool")),
      );
      return;
    }

    try {
      // Check if the user has already sent a booking request
      final existingRequest = await FirebaseFirestore.instance
          .collection('carpool_requests')
          .where('carpoolId', isEqualTo: carpoolId)
          .where('passengerId', isEqualTo: user.uid)
          .get();

      if (existingRequest.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You've already sent a booking request!")),
        );
        return;
      }

      // ✅ FIX: Use 'hostId' instead of 'driverId'
      final hostId = carpoolDetails['hostId'];

      if (hostId == null || hostId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Driver ID is missing. Cannot send booking request.")),
        );
        return;
      }

      // Create a new booking request
      final bookingRequestRef =
      await FirebaseFirestore.instance.collection('carpool_requests').add({
        'carpoolId': carpoolId,
        'passengerId': user.uid,
        'hostId': hostId,
        'status': 'pending',
        'timestamp': Timestamp.now(),
      });

      // Optionally update the carpool document with the request ID
      await FirebaseFirestore.instance.collection('car_pools').doc(carpoolId).update({
        'bookingRequests': FieldValue.arrayUnion([bookingRequestRef.id])
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking request sent successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send request: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final driverName = carpoolDetails['driverName'] ?? 'Unknown';
    final from = carpoolDetails['from'] ?? 'N/A';
    final to = carpoolDetails['to'] ?? 'N/A';
    final dateTime = carpoolDetails['departureTime'] ?? 'N/A'; // Fixed key
    final seatsAvailable = carpoolDetails['seatsAvailable']?.toString() ?? '0';
    final pricePerSeat = carpoolDetails['pricePerSeat']?.toString() ?? '0';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Carpool Details"),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/car_image.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Driver: $driverName",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.location_on, color: Colors.green),
                    title: const Text("Pickup"),
                    subtitle: Text(from),
                  ),
                  ListTile(
                    leading: const Icon(Icons.flag, color: Colors.red),
                    title: const Text("Destination"),
                    subtitle: Text(to),
                  ),
                  ListTile(
                    leading: const Icon(Icons.event, color: Colors.blue),
                    title: const Text("Date & Time"),
                    subtitle: Text(dateTime),
                  ),
                  ListTile(
                    leading: const Icon(Icons.event_seat, color: Colors.purple),
                    title: const Text("Seats Available"),
                    subtitle: Text(seatsAvailable),
                  ),
                  ListTile(
                    leading: const Icon(Icons.attach_money, color: Colors.orange),
                    title: const Text("Price per Seat"),
                    subtitle: Text("₹$pricePerSeat"),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => _bookCarpool(context),
                      icon: const Icon(Icons.send),
                      label: const Text("Book Now"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey[800],
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        textStyle:
                        const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
