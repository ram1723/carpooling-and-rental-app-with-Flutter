// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDuMncZtNbjoDTH-C8NqtNMwcFi0zW-3yk',
    appId: '1:851277436852:web:d82f074a6766704c7284e1',
    messagingSenderId: '851277436852',
    projectId: 'car-rental-and-pooling',
    authDomain: 'car-rental-and-pooling.firebaseapp.com',
    storageBucket: 'car-rental-and-pooling.firebasestorage.app',
    measurementId: 'G-8GT0SXXP3H',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAWpe5aSADRvQH2s4cxqWHIZGBR9iWEnho',
    appId: '1:851277436852:android:43feec83acdbc3357284e1',
    messagingSenderId: '851277436852',
    projectId: 'car-rental-and-pooling',
    storageBucket: 'car-rental-and-pooling.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB0krt9xVG34GD2FfzkFTdUx3cs3525YUk',
    appId: '1:851277436852:ios:301301e6b968fbd97284e1',
    messagingSenderId: '851277436852',
    projectId: 'car-rental-and-pooling',
    storageBucket: 'car-rental-and-pooling.firebasestorage.app',
    iosBundleId: 'com.example.carrental',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB0krt9xVG34GD2FfzkFTdUx3cs3525YUk',
    appId: '1:851277436852:ios:301301e6b968fbd97284e1',
    messagingSenderId: '851277436852',
    projectId: 'car-rental-and-pooling',
    storageBucket: 'car-rental-and-pooling.firebasestorage.app',
    iosBundleId: 'com.example.carrental',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDuMncZtNbjoDTH-C8NqtNMwcFi0zW-3yk',
    appId: '1:851277436852:web:76752ff2699e0d2d7284e1',
    messagingSenderId: '851277436852',
    projectId: 'car-rental-and-pooling',
    authDomain: 'car-rental-and-pooling.firebaseapp.com',
    storageBucket: 'car-rental-and-pooling.firebasestorage.app',
    measurementId: 'G-VZSMCDGJGY',
  );
}
