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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyACrSn8GdldaEe7OU7qihi6fRPq1pb_oeY',
    appId: '1:227123976603:web:c69b7cec37bcf69d2e693e',
    messagingSenderId: '227123976603',
    projectId: 'kekomarz',
    authDomain: 'kekomarz.firebaseapp.com',
    storageBucket: 'kekomarz.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD4kw0S2-lDn7Qh3gwsYFY3hr2fwcvFSnY',
    appId: '1:227123976603:android:b3ab76814b8a8c582e693e',
    messagingSenderId: '227123976603',
    projectId: 'kekomarz',
    storageBucket: 'kekomarz.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDMv0Vw4GvcvOUB0s3Dc2ulYHpcvakXCYw',
    appId: '1:227123976603:ios:31d82720f45d907e2e693e',
    messagingSenderId: '227123976603',
    projectId: 'kekomarz',
    storageBucket: 'kekomarz.appspot.com',
    iosBundleId: 'com.example.kekomarz',
  );
}
