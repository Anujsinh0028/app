// ignore_for_file: unused_field, unnecessary_null_comparison
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:telos/controller/webview_controller.dart';
import 'package:telos/service/messeging_service.dart';
import 'package:uni_links/uni_links.dart';
import 'package:webview_flutter/webview_flutter.dart';
// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class WebViewExample extends StatefulWidget {
  const WebViewExample({super.key});

  @override
  State<WebViewExample> createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {

  final messageservice = MessagingService();
   static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  
 
 
  late final WebViewController _controller;
  // final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;

Future<String?> initUniLinks() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      final initialLink = await getInitialLink();
      // Parse the link and warn the user, if it is not correct,
      // but keep in mind it could be `null`.
      return initialLink;
    } on PlatformException {
      return null;
      // Handle exception by warning the user their action did not succeed
      // return?
    }
  }

  

// Future<void> fetchRemoteConfig() async {
//   try {
//     await remoteConfig.fetchAndActivate();
//     print("Remote Config activated");
//   } catch (e) {
//     print("Error fetching remote config: $e");
//   }
// }

// void checkMaintenanceMode() {
//   bool isMaintenanceMode = remoteConfig.getBool('isMaintenanceMode');
//   print('Maintenance Mode: $isMaintenanceMode');

//   if (isMaintenanceMode) {
//     print("on isMaintenanceMode");
//   } else {
//     print('off isMaintenanceMode');
//   }
// }

  @override
  void initState() {
    super.initState();
    
    messageservice.init(context);
    // #docregion platform_features
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      )
      ..loadRequest(Uri.parse('https://www.telosfashion.com'));
/////////////////////////////////////////////////////////////////////////////////////////
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    _controller = controller;
    initUniLinks().then((value) {
      print("DEEP LINK:::${value}");
      if(value!=null){

        _controller.loadRequest(Uri.parse(value));
      }
    }
    );

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationClick(context, message);
    });


  }
  void _handleNotificationClick(BuildContext context, RemoteMessage message) {
    final notificationData = message.data;

    if (notificationData.containsKey('deeplink')) {
      final deeplink = notificationData['deeplink'];
      print("DEEP LINK:::${deeplink}");
      if(deeplink!=null){

        _controller.loadRequest(Uri.parse(deeplink));
      }
    }
  }
  //   // Subscribe to onMessageReceived stream to handle push notifications
  //   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //     print("onMessage: $message");
  //     // Handle the push notification message
  //     handlePushNotification(message.data);
  //   });
  // }

  // // ... (other methods)

  void handlePushNotification(Map<String, dynamic> message) {
    // Handle deep link from the push notification payload
    String deepLink = message['deepLink'];
    if (deepLink != null && deepLink.isNotEmpty) {
      // Load the deep link into the WebView
      _controller.loadRequest(Uri.parse(deepLink));
      print("Received deep link: $deepLink");
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // appBar: AppBar(
        //   actions: <Widget>[
        //     NavigationControls(webViewController: _controller),
        //   ],
        // ),
        body: WebViewWidget(controller: _controller),
        bottomNavigationBar: NavigationControls(webViewController: _controller),
      ),
    );
  }
}