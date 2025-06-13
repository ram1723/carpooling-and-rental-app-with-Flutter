import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'car_pool_details_screen.dart';
import 'package:intl/intl.dart';

class CarPoolingScreen extends StatefulWidget {
  const CarPoolingScreen({Key? key}) : super(key: key);

  @override
  State<CarPoolingScreen> createState() => _CarPoolingScreenState();
}

class _CarPoolingScreenState extends State<CarPoolingScreen> {
  final TextEditingController fromSearchController = TextEditingController();
  final TextEditingController toSearchController = TextEditingController();
  String fromSearch = "";
  String toSearch = "";
  List<String> recentSearches = [];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  Future<void> _loadRecentSearches() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      recentSearches = prefs.getStringList('recentSearches') ?? [];
    });
  }

  Future<void> _applyFilter() async {
    setState(() {
      fromSearch = fromSearchController.text.trim().toLowerCase();
      toSearch = toSearchController.text.trim().toLowerCase();
    });

    final searchKey =
        "${fromSearchController.text.trim()} → ${toSearchController.text.trim()}";
    if (searchKey.trim().isNotEmpty && !recentSearches.contains(searchKey)) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      recentSearches.insert(0, searchKey);
      if (recentSearches.length > 5) {
        recentSearches = recentSearches.sublist(0, 5);
      }
      await prefs.setStringList('recentSearches', recentSearches);
      setState(() {});
    }
  }

  Future<void> _clearSearchHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('recentSearches');
    setState(() {
      recentSearches.clear();
    });
  }

  String formatDateTime(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Car Pooling"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: fromSearchController,
                        decoration: const InputDecoration(
                          labelText: "From",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: toSearchController,
                        decoration: const InputDecoration(
                          labelText: "To",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _applyFilter,
                      child: const Text("Search"),
                    ),
                  ],
                ),
                if (recentSearches.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Recent Searches",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: recentSearches.map((search) {
                      return ActionChip(
                        label: Text(search),
                        onPressed: () {
                          final parts = search.split("→");
                          if (parts.length == 2) {
                            fromSearchController.text = parts[0].trim();
                            toSearchController.text = parts[1].trim();
                            _applyFilter();
                          }
                        },
                      );
                    }).toList(),
                  ),
                  TextButton(
                    onPressed: _clearSearchHistory,
                    child: const Text("Clear Search History"),
                  ),
                ]
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('car_pools')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error fetching car pools.'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];

                final filteredDocs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>? ?? {};
                  final from = data['from']?.toString().toLowerCase() ?? '';
                  final to = data['to']?.toString().toLowerCase() ?? '';
                  final matchesFrom =
                      fromSearch.isEmpty || from.contains(fromSearch);
                  final matchesTo =
                      toSearch.isEmpty || to.contains(toSearch);
                  return matchesFrom && matchesTo;
                }).toList();

                if (filteredDocs.isEmpty) {
                  return const Center(child: Text("No car pools found."));
                }

                return ListView.builder(
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    final data = doc.data() as Map<String, dynamic>? ?? {};

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: ListTile(
                        leading: const Icon(Icons.directions_car),
                        title: Text(
                            "${data['from'] ?? 'Unknown'} → ${data['to'] ?? 'Unknown'}"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Driver: ${data['driverName'] ?? 'Unknown'}"),
                            Text(
                                "Date & Time: ${formatDateTime(data['dateTime'])}"),
                            Text("Price: ₹${data['pricePerSeat'] ?? '-'} per seat"),
                            Text("Seats Available: ${data['seatsAvailable'] ?? '-'}"),
                          ],
                        ),
                        isThreeLine: true,
                        trailing:
                        const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CarPoolDetailsScreen(
                                carpoolDetails: data,
                                carpoolId: doc.id,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/host-carpool');
        },
        icon: const Icon(Icons.add),
        label: const Text("Host a Carpool"),
      ),
    );
  }
}
