import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NavigationControls extends StatefulWidget {
  const NavigationControls({super.key, required this.webViewController});

  final WebViewController webViewController;

  @override
  State<NavigationControls> createState() => _NavigationControlsState();
}

class _NavigationControlsState extends State<NavigationControls> {
    static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  int _counter= 0;

  void _increment(){
    setState(() {
      _counter++;
    });
    analytics.setAnalyticsCollectionEnabled(true);

    analytics.logEvent(name: 'incremet',
    parameters: <String,dynamic>{
      'value':_counter,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.arrow_back_ios,),
          onPressed: () async {
            if (await widget.webViewController.canGoBack()) {
              await widget.webViewController.goBack();
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No back history item')),
                );
              }
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: () async {
            if (await widget.webViewController.canGoForward()) {
              await widget.webViewController.goForward();
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No forward history item')),
                );
              }
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.replay),
          onPressed: () => widget.webViewController.reload(),
        ),
        TextButton(
    onPressed: () async {
            final currentUrl = await widget.webViewController.currentUrl();
            Share.share('Check out this link: $currentUrl');
          },
    child: Icon(Icons.share)
),
      ],
    );
  }
}