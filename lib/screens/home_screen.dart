import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'CarRentalScreen.dart';
import 'carpooling_screen.dart';
import 'my_bookings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  final List<Widget> _screens = [
    CarRentalScreen(),
    CarPoolingScreen(),
  ];


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Car Rental & Pooling"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_selectedIndex == 1) // Only show for Car Pooling tab
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.directions_car_filled),
                label: const Text("My Hosted Rides"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/my-rides');
                },
              ),
            ),
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blueAccent,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.car_rental),
            label: 'Car Rentals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Car Pooling',
          ),
        ],
      ),
      floatingActionButton: user != null // Show FAB only if user is logged in
          ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MyBookingsScreen()),
          );
        },
        child: const Icon(Icons.book_online),
        backgroundColor: Colors.blueAccent,
      )
          : null,

    );
  }
}
