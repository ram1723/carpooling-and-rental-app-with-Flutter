import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class HostPoolScreen extends StatefulWidget {
  const HostPoolScreen({Key? key}) : super(key: key);

  @override
  State<HostPoolScreen> createState() => _HostPoolScreenState();
}

class _HostPoolScreenState extends State<HostPoolScreen> {
  final _formKey = GlobalKey<FormState>();
  final currentUser = FirebaseAuth.instance.currentUser;
  final TextEditingController driverController = TextEditingController();
  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();
  final TextEditingController dateTimeController = TextEditingController();
  final TextEditingController seatsController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController carModelController = TextEditingController();

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final poolData = {
        'hostId': FirebaseAuth.instance.currentUser?.uid,
        'driverName': driverController.text.trim(),
        'from': fromController.text.trim(),
        'to': toController.text.trim(),
        'departureTime': dateTimeController.text.trim(),
        'seatsAvailable': int.tryParse(seatsController.text.trim()) ?? 0,
        'pricePerSeat': int.tryParse(priceController.text.trim()) ?? 0,
        'carModel': carModelController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      };

      try {
        await FirebaseFirestore.instance.collection('car_pools').add(poolData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Car pool hosted successfully!")),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  @override
  void dispose() {
    driverController.dispose();
    fromController.dispose();
    toController.dispose();
    dateTimeController.dispose();
    seatsController.dispose();
    priceController.dispose();
    carModelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Host a Car Pool")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(driverController, "Driver Name"),
              _buildTextField(carModelController, "Car Model"),
              _buildTextField(fromController, "From Location"),
              _buildTextField(toController, "To Location"),
              _buildTextField(dateTimeController, "Departure Date & Time (e.g. 2025-04-14 09:30)"),
              _buildTextField(seatsController, "Seats Available", isNumber: true),
              _buildTextField(priceController, "Price Per Seat", isNumber: true),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text("Host Pool"),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: label,
        ),
        validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
      ),
    );
  }
}
