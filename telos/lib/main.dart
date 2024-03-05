import 'dart:ui';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:telos/webview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

  final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
  bool isMaintenanceMode = remoteConfig.getBool('isMaintenanceMode');

Future<void> fetchRemoteConfig() async {
  try {
    await remoteConfig.fetchAndActivate();
    print("Remote Config activated");
  } catch (e) {
    print("Error fetching remote config: $e");
  }
}

void checkMaintenanceMode() {
  
  print('Maintenance Mode: $isMaintenanceMode');
  
  if (isMaintenanceMode) {
    print("on isMaintenanceMode");
  } else {
    print('off isMaintenanceMode');
  }
}

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await fetchRemoteConfig();
  checkMaintenanceMode();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
   // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

  FirebaseMessaging.instance.subscribeToTopic("app");

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WebViewExample(),
    ),
    
  );
}