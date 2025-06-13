class Booking {
  final String id;
  final String userId; // You can link this with FirebaseAuth
  final String carId;
  final String carName;
  final DateTime bookingDate;

  Booking({
    required this.id,
    required this.userId,
    required this.carId,
    required this.carName,
    required this.bookingDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'carId': carId,
      'carName': carName,
      'bookingDate': bookingDate.toIso8601String(),
    };
  }

  static Booking fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'],
      userId: map['userId'],
      carId: map['carId'],
      carName: map['carName'],
      bookingDate: DateTime.parse(map['bookingDate']),
    );
  }
}
