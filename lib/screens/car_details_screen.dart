import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/car_model.dart';
import 'payment_screen.dart'; // <-- Import the new payment screen

class CarDetailsScreen extends StatefulWidget {
  final Car car;

  const CarDetailsScreen({Key? key, required this.car}) : super(key: key);

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isBooking = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<bool> _isCarAvailable(String carName, DateTime start, DateTime end) async {
    final query = await FirebaseFirestore.instance
        .collection('bookings')
        .where('carName', isEqualTo: carName)
        .get();

    for (var doc in query.docs) {
      final existingStart = (doc['startDate'] as Timestamp).toDate();
      final existingEnd = (doc['endDate'] as Timestamp).toDate();

      final overlap = start.isBefore(existingEnd) && end.isAfter(existingStart);
      if (overlap) return false;
    }
    return true;
  }

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
      });
    }
  }

  Future<void> _bookCarFlow() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select booking dates first!")),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in!")),
      );
      return;
    }

    setState(() {
      _isBooking = true;
    });

    try {
      final available = await _isCarAvailable(widget.car.name, _startDate!, _endDate!);
      if (!available) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ This car is already booked for selected dates.")),
        );
        setState(() => _isBooking = false);
        return;
      }

      // Navigate to PaymentScreen and await result
      final bool paymentSuccess = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentScreen(
            amount: (widget.car.price * _endDate!.difference(_startDate!).inDays).toDouble(),
            car: widget.car,
            startDate: _startDate!,
            endDate: _endDate!,
          ),
        ),
      );

      if (paymentSuccess) {
        // Payment successful, create booking
        final docRef = await FirebaseFirestore.instance.collection('bookings').add({
          'userId': user.uid,
          'carName': widget.car.name,
          'carModel': widget.car.model,
          'pricePerDay': widget.car.price,
          'startDate': _startDate,
          'endDate': _endDate,
          'createdAt': FieldValue.serverTimestamp(),
        });

        await docRef.update({'bookingId': docRef.id});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "✅ Booking confirmed from ${_startDate!.toLocal().toString().split(' ')[0]} to ${_endDate!.toLocal().toString().split(' ')[0]}",
            ),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Payment Failed. Booking not completed.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Booking failed: $e")),
      );
    } finally {
      setState(() {
        _isBooking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final car = widget.car;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(car.name),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              // Car Image
              Hero(
                tag: car.name,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  child: Image.asset(
                    'assets/car_image.png',
                    width: double.infinity,
                    height: 240,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Details Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(car.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text("Model: ${car.model}", style: const TextStyle(fontSize: 16, color: Colors.black54)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.currency_rupee, size: 20, color: Colors.green),
                            Text("${car.price}/day", style: const TextStyle(fontSize: 18, color: Colors.green)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text("Features", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        const Text(
                          "✔️ Automatic Transmission\n✔️ Air Conditioning\n✔️ Bluetooth Audio\n✔️ GPS Navigation\n✔️ Cruise Control",
                          style: TextStyle(fontSize: 15, height: 1.4),
                        ),
                        const SizedBox(height: 20),

                        ElevatedButton.icon(
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
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Book Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.directions_car),
                  label: _isBooking
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Book Now", style: TextStyle(fontSize: 18)),
                  onPressed: _isBooking ? null : _bookCarFlow,
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
