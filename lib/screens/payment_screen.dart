import 'dart:io';

import 'package:flutter/material.dart';
import 'package:upi_india/upi_india.dart';
import '../models/car_model.dart';

class PaymentScreen extends StatefulWidget {
  final double amount;
  final Car car;
  final DateTime startDate;
  final DateTime endDate;

  const PaymentScreen({
    Key? key,
    required this.amount,
    required this.car,
    required this.startDate,
    required this.endDate,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late Future<List<UpiApp>> _appsFuture;
  String _transactionStatus = "";

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      _appsFuture = UpiIndia().getAllUpiApps(mandatoryTransactionId: false);
    }
  }

  Future<void> _initiateTransaction(UpiApp app) async {
    UpiResponse response = await UpiIndia().startTransaction(
      app: app,
      receiverUpiId: "yourupiid@bank", // <-- Replace with valid UPI ID
      receiverName: "Car Rental App",
      transactionRefId: "TXN_${DateTime.now().millisecondsSinceEpoch}",
      transactionNote: "Booking for ${widget.car.name}",
      amount: widget.amount,
    );

    setState(() {
      _transactionStatus = response.status ?? 'Unknown';
    });

    if (response.status == UpiPaymentStatus.SUCCESS) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Payment Successful")),
      );
      Navigator.pop(context, true); // Indicate success
    } else if (response.status == UpiPaymentStatus.FAILURE) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Payment Failed")),
      );
    } else if (response.status == UpiPaymentStatus.SUBMITTED) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ℹ️ Payment Submitted")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Payment status unknown or cancelled")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Payment"),
        backgroundColor: Colors.black87,
      ),
      body: Platform.isAndroid
          ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text("Total Payable: ₹${widget.amount.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 30),
            const Text("Choose a UPI app", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            FutureBuilder<List<UpiApp>>(
              future: _appsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text("No UPI apps found.");
                } else {
                  final apps = snapshot.data!;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: apps.map((app) {
                      return GestureDetector(
                        onTap: () => _initiateTransaction(app),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.memory(app.icon, width: 60),
                            const SizedBox(height: 4),
                            Text(app.name, style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                }
              },
            ),
            const SizedBox(height: 30),
            if (_transactionStatus.isNotEmpty)
              Text("Status: $_transactionStatus",
                  style: const TextStyle(fontSize: 16, color: Colors.green)),
          ],
        ),
      )
          : const Center(
        child: Text(
          "UPI payments are only supported on Android devices.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
