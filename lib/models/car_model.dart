import 'package:cloud_firestore/cloud_firestore.dart'; // Import the necessary package

class Car {
  final String carId;
  final String name;
  final String model;
  final int price;
  final String status;

  Car({
    required this.carId,
    required this.name,
    required this.model,
    required this.price,
    required this.status,
  });

  // From Firestore data
  factory Car.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Car(
      carId: doc.id, // Using the document ID as carId
      name: data['name'] ?? '',
      model: data['model'] ?? '',
      price: data['price']?.toInt() ?? 0,  // Ensuring price is an int
      status: data['status'] ?? 'Available', // Handling status field
    );
  }
}
