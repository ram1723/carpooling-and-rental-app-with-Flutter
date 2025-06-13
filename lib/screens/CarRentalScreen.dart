import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'car_details_screen.dart';
import '../models/car_model.dart';

class CarRentalScreen extends StatefulWidget {
  @override
  _CarRentalScreenState createState() => _CarRentalScreenState();
}

class _CarRentalScreenState extends State<CarRentalScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  List<Car> availableCars = [];
  bool _isLoading = false;

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _isLoading = true;
      });
      await _fetchAvailableCars();
    }
  }

  Future<void> _fetchAvailableCars() async {
    if (_startDate == null || _endDate == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final carsQuerySnapshot = await FirebaseFirestore.instance
          .collection('cars')
          .get();

      List<Car> tempCars = [];
      for (var carDoc in carsQuerySnapshot.docs) {
        Car car = Car.fromFirestore(carDoc);

        final bookingsQuerySnapshot = await FirebaseFirestore.instance
            .collection('bookings')
            .where('carId', isEqualTo: car.carId)
            .get();

        bool isAvailable = true;
        for (var bookingDoc in bookingsQuerySnapshot.docs) {
          DateTime bookingStart = bookingDoc['startDate'].toDate();
          DateTime bookingEnd = bookingDoc['endDate'].toDate();

          if ((_startDate!.isBefore(bookingEnd) && _endDate!.isAfter(bookingStart)) ||
              (_startDate!.isAtSameMomentAs(bookingEnd) || _endDate!.isAtSameMomentAs(bookingStart))) {
            isAvailable = false;
            break;
          }
        }

        if (isAvailable) {
          tempCars.add(car);
        }
      }

      setState(() {
        availableCars = tempCars;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch available cars: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Rentals'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Date picker button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _selectDateRange,
              icon: const Icon(Icons.date_range),
              label: Text(
                _startDate == null
                    ? "Select Booking Dates"
                    : "📅 ${_startDate!.toLocal().toString().split(' ')[0]} → ${_endDate!.toLocal().toString().split(' ')[0]}",
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey[800],
                foregroundColor: Colors.white,
              ),
            ),
          ),
          if (_isLoading)
            const CircularProgressIndicator(),
          if (!_isLoading && availableCars.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: availableCars.length,
                itemBuilder: (context, index) {
                  final car = availableCars[index];
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    elevation: 6,
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'assets/car_image.png',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(car.name),
                      subtitle: Text("${car.model} - ₹${car.price}/day"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CarDetailsScreen(car: car),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          if (!_isLoading && availableCars.isEmpty)
            const Center(
              child: Text("No cars available for the selected dates"),
            ),
        ],
      ),
    );
  }
}
