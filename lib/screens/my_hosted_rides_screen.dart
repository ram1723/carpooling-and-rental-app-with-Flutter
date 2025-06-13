import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyHostedRidesScreen extends StatelessWidget {
  const MyHostedRidesScreen({Key? key}) : super(key: key);

  void _editRide(BuildContext context, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final seatsController = TextEditingController(text: data['seatsAvailable'].toString());
    final timeController = TextEditingController(text: data['departureTime']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Ride Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: seatsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Seats Available"),
            ),
            TextFormField(
              controller: timeController,
              decoration: const InputDecoration(labelText: "Departure Date & Time"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('car_pools')
                  .doc(doc.id)
                  .update({
                'seatsAvailable': int.tryParse(seatsController.text) ?? 0,
                'departureTime': timeController.text.trim(),
              });
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _deleteRide(BuildContext context, String docId) async {
    await FirebaseFirestore.instance.collection('car_pools').doc(docId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Ride deleted")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("My Hosted Rides")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('car_pools')
            .where('hostId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Error loading rides"));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text("You haven't hosted any rides yet."));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final carpoolId = docs[index].id;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text("${data['from']} → ${data['to']}"),
                        subtitle: Text(
                          "Date: ${data['departureTime']} • Seats: ${data['seatsAvailable']} • ₹${data['pricePerSeat']}",
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _editRide(context, docs[index]);
                            } else if (value == 'delete') {
                              _deleteRide(context, carpoolId);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'edit', child: Text("Edit")),
                            const PopupMenuItem(value: 'delete', child: Text("Delete")),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.assignment),
                          label: const Text("View Booking Requests"),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/booking-approvals',
                              arguments: carpoolId,
                            );
                          },
                        ),
                      ),
                    ],
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
