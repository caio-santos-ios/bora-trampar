// File generated for Bora Trampar Firebase options
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDL9-KO9WdK4fjTGEjOMwWBPxIWkjNePIw',
    appId: '1:20955964616:web:54cbb13692945c79f931fd',
    messagingSenderId: '20955964616',
    projectId: 'app-barber-90445',
    authDomain: 'app-barber-90445.firebaseapp.com',
    storageBucket: 'app-barber-90445.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAjdKEXnHct4OKPd6gzlz9IcrbzLH21xuM',
    appId: '1:20955964616:android:cbbdcf26a5a5784cf931fd',
    messagingSenderId: '20955964616',
    projectId: 'app-barber-90445',
    storageBucket: 'app-barber-90445.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD...',
    appId: '1:20955964616:ios:cbbdcf26a5a5784cf931fd',
    messagingSenderId: '20955964616',
    projectId: 'app-barber-90445',
    storageBucket: 'app-barber-90445.firebasestorage.app',
  );
}
