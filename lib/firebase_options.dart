import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' as io;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    if (io.Platform.isAndroid) {
      return android;
    }
    if (io.Platform.isIOS) {
      return ios;
    }
    if (io.Platform.isMacOS) {
      return macos;
    }
    if (io.Platform.isWindows) {
      return windows;
    }
    if (io.Platform.isLinux) {
      return linux;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA7NGRKA-3v6YYfCVcao2KcSnnZqC9YhoI',
    appId: '1:1067526580765:web:a3b61a654dfdf285eef4f4',
    messagingSenderId: '1067526580765',
    projectId: 'sleepnotfound404-46ce5',
    authDomain: 'sleepnotfound404-46ce5.firebaseapp.com',
    storageBucket: 'sleepnotfound404-46ce5.firebasestorage.app',
    measurementId: 'G-903E0ZYTDD',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAPPgpEP5S4Tond4T-5rhHSdHxtl-bI704',
    appId: '1:1067526580765:android:43747810c1becbbaeef4f4',
    messagingSenderId: '1067526580765',
    projectId: 'sleepnotfound404-46ce5',
    storageBucket: 'sleepnotfound404-46ce5.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBM8n5PJ_BuFLbSwSO2tHu7DB8t2YBSLb0',
    appId: '1:1067526580765:ios:08cccfbd81f5b5a0eef4f4',
    messagingSenderId: '1067526580765',
    projectId: 'sleepnotfound404-46ce5',
    storageBucket: 'sleepnotfound404-46ce5.firebasestorage.app',
    iosClientId: '1067526580765-180lcqi47nferv1jg2uvlk989r7hsev8.apps.googleusercontent.com',
    iosBundleId: 'com.example.sleepnotfound404',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBM8n5PJ_BuFLbSwSO2tHu7DB8t2YBSLb0',
    appId: '1:1067526580765:ios:08cccfbd81f5b5a0eef4f4',
    messagingSenderId: '1067526580765',
    projectId: 'sleepnotfound404-46ce5',
    storageBucket: 'sleepnotfound404-46ce5.firebasestorage.app',
    iosClientId: '1067526580765-180lcqi47nferv1jg2uvlk989r7hsev8.apps.googleusercontent.com',
    iosBundleId: 'com.example.sleepnotfound404',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA7NGRKA-3v6YYfCVcao2KcSnnZqC9YhoI',
    appId: '1:1067526580765:web:1e84cd04eb5b4f95eef4f4',
    messagingSenderId: '1067526580765',
    projectId: 'sleepnotfound404-46ce5',
    authDomain: 'sleepnotfound404-46ce5.firebaseapp.com',
    storageBucket: 'sleepnotfound404-46ce5.firebasestorage.app',
    measurementId: 'G-1RZT1ECF7C',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyD_uZ5GiImGwscC0Ow7PD7HqWTfpwn4-ks',
    appId: '1:1067526580765:web:1e84cd04eb5b4f95eef4f4',
    messagingSenderId: '1067526580765',
    projectId: 'sleepnotfound404-46ce5',
  );
}