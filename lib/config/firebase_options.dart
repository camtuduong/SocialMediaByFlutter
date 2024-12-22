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
    apiKey: 'AIzaSyBDvySQO-Y5Ps-mzhFhq1cDKsCFetUGyzM',
    appId: '1:458170948247:web:d2af16474b28dc15a5e7d2',
    messagingSenderId: '458170948247',
    projectId: 'socialapp-92590',
    authDomain: 'socialapp-92590.firebaseapp.com',
    storageBucket: 'socialapp-92590.firebasestorage.app',
    measurementId: 'G-5T742Z1JNW',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA-ewcDs6vpxI-5kDtzJaKbEEiMeSPL9GA',
    appId: '1:458170948247:android:c82671e466d70154a5e7d2',
    messagingSenderId: '458170948247',
    projectId: 'socialapp-92590',
    storageBucket: 'socialapp-92590.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAJK4TRpg5EWr4AGvWIOgWZ__4R31fCRFw',
    appId: '1:458170948247:ios:218f57241788096da5e7d2',
    messagingSenderId: '458170948247',
    projectId: 'socialapp-92590',
    storageBucket: 'socialapp-92590.firebasestorage.app',
    iosBundleId: 'com.example.socialmediaapp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAJK4TRpg5EWr4AGvWIOgWZ__4R31fCRFw',
    appId: '1:458170948247:ios:218f57241788096da5e7d2',
    messagingSenderId: '458170948247',
    projectId: 'socialapp-92590',
    storageBucket: 'socialapp-92590.firebasestorage.app',
    iosBundleId: 'com.example.socialmediaapp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBDvySQO-Y5Ps-mzhFhq1cDKsCFetUGyzM',
    appId: '1:458170948247:web:0e13cddc87eba674a5e7d2',
    messagingSenderId: '458170948247',
    projectId: 'socialapp-92590',
    authDomain: 'socialapp-92590.firebaseapp.com',
    storageBucket: 'socialapp-92590.firebasestorage.app',
    measurementId: 'G-6FRT13Q0ER',
  );
}