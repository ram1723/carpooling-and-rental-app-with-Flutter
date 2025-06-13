import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DriverApprovalPage extends StatefulWidget {
  const DriverApprovalPage({Key? key}) : super(key: key);

  @override
  State<DriverApprovalPage> createState() => _DriverApprovalPageState();
}

class _DriverApprovalPageState extends State<DriverApprovalPage> {
  final currentUser = FirebaseAuth.instance.currentUser;

  String? carpoolId;
  bool _snackbarShown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && carpoolId == null) {
      setState(() {
        carpoolId = args as String;
      });
    }
  }

  Stream<QuerySnapshot> _getCarpoolRequestsStream(String carpoolId) {
    return FirebaseFirestore.instance
        .collection('carpool_requests')
        .where('hostId', isEqualTo: currentUser?.uid)
        .where('carpoolId', isEqualTo: carpoolId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<String> _getPassengerName(String passengerId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(passengerId)
          .get();
      return userDoc.exists ? userDoc['name'] ?? 'Unknown' : 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  Future<String> _getCarpoolInfo(String carpoolId) async {
    try {
      final carpoolDoc = await FirebaseFirestore.instance
          .collection('car_pools')
          .doc(carpoolId)
          .get();
      if (!carpoolDoc.exists) return 'Unknown Ride';
      final data = carpoolDoc.data()!;
      return '${data['from']} → ${data['to']} on ${data['departureTime']}';
    } catch (e) {
      return 'Unknown Ride';
    }
  }

  void _updateStatus(String requestId, String newStatus) async {
    await FirebaseFirestore.instance
        .collection('carpool_requests')
        .doc(requestId)
        .update({'status': newStatus});
  }

  Widget _buildRequestCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final status = data['status'] ?? 'pending';

    return FutureBuilder<List<String>>(
      future: Future.wait([
        _getPassengerName(data['passengerId']),
        _getCarpoolInfo(data['carpoolId']),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const ListTile(
            title: Text('Error loading request'),
            subtitle: Text('Please try again later.'),
          );
        }

        final passengerName = snapshot.data![0];
        final carpoolInfo = snapshot.data![1];

        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            leading: const Icon(Icons.person),
            title: Text(passengerName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(carpoolInfo),
                const SizedBox(height: 4),
                Text("Status: ${status.toUpperCase()}"),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (status == 'pending') ...[
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    onPressed: () => _updateStatus(doc.id, 'approved'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: () => _updateStatus(doc.id, 'rejected'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (carpoolId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Approval Requests')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getCarpoolRequestsStream(carpoolId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading requests.'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            if (!_snackbarShown) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No booking requests found for this ride.'),
                    duration: Duration(seconds: 3),
                  ),
                );
              });
              _snackbarShown = true;
            }
            return const Center(child: Text('No booking requests.'));
          }

          final docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) => _buildRequestCard(docs[index]),
          );
        },
      ),
    );
  }
}
