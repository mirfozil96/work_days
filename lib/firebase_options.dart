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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAYL76BPRhNegY4IA78TFcSKEqPU_uSpFQ',
    appId: '1:568670279553:android:1386782ec93e57751c3a80',
    messagingSenderId: '568670279553',
    projectId: 'fir-bc6b6',
    storageBucket: 'fir-bc6b6.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBDXnNTv2dp-byYA6NkxXxTWazikqR25_I',
    appId: '1:568670279553:ios:0c032380a4fe80091c3a80',
    messagingSenderId: '568670279553',
    projectId: 'fir-bc6b6',
    storageBucket: 'fir-bc6b6.appspot.com',
    iosBundleId: 'com.firebase',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCwrqYraLKb4Z9NgPy-mQCt8czUM1s7n4U',
    appId: '1:568670279553:web:cf08e2ec28ae190e1c3a80',
    messagingSenderId: '568670279553',
    projectId: 'fir-bc6b6',
    authDomain: 'fir-bc6b6.firebaseapp.com',
    storageBucket: 'fir-bc6b6.appspot.com',
    measurementId: 'G-Q4Z42HQD89',
  );
}