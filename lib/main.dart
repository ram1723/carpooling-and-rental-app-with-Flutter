import 'package:carrental/screens/car_pool_details_screen.dart';
import 'package:carrental/screens/host_pool_screen.dart';
import 'package:carrental/services/auth_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Ensure this is imported
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_page.dart';
import 'screens/CarRentalScreen.dart';
import 'screens/carpooling_screen.dart';
import 'screens/car_pool_details_screen.dart';
import 'screens/my_hosted_rides_screen.dart';
import 'screens/driver_booking_approvals_screen.dart';
import 'screens/splash_Screen.dart';
// Firebase configuration (replace with your config from Firebase Console)
const firebaseConfig = FirebaseOptions(
  apiKey: "AIzaSyDuMncZtNbjoDTH-C8NqtNMwcFi0zW-3yk",
  authDomain: "car-rental-and-pooling.firebaseapp.com",
  projectId: "car-rental-and-pooling",
  storageBucket: "car-rental-and-pooling.firebasestorage.app",
  messagingSenderId: "851277436852",
  appId: "1:851277436852:web:d82f074a6766704c7284e1",
  measurementId: "G-8GT0SXXP3H",
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseConfig);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Rental App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/carRentals': (context) => CarRentalScreen(),  // ✅ fixed here
        '/carpool': (context) => CarPoolingScreen(),    // ✅ if not const constructor
        '/host-carpool': (context) => const HostPoolScreen(),
        '/my-rides': (context) => const MyHostedRidesScreen(),
        '/booking-approvals': (context) => const DriverApprovalPage(),
      },
    );
  }
}
