# push_handler

Push UI handler for Firebase Messaging that renders rich in-app layouts
and routes actions based on the push payload.

## Features

- Parse push payloads into typed data models.
- Built-in layouts: popup, full screen, bottom sheet, action button, snackbar.
- Button routing: internal routes, internal routes with item argument, external URL.
- Stream-based message handling for custom UI wiring.

## Getting started

Add `push_handler` to your `pubspec.yaml` and follow the Firebase Messaging
setup for your platforms.

This package expects data in the Firebase message `data` payload using
the fields shown below.

## Usage

Create a top-level background handler and initialize the repository.

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:push_handler/push_handler.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background message if needed.
}

final pushRepository =
    PushHandlerRepositoryDefault(firebaseMessagingBackgroundHandler);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await pushRepository.init();

  runApp(MyApp(navigatorKey: pushRepository.globalNavigatorKey));
}

class MyApp extends StatelessWidget {
  const MyApp({required this.navigatorKey, super.key});

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: const Scaffold(body: Center(child: Text('App'))),
    );
  }
}
```

### Payload format (data)

Minimal example:

```json
{
  "title": "Welcome",
  "body": "Thanks for installing.",
  "layoutType": "MessageLayoutType.popup",
  "allowDismiss": true,
  "steps": [],
  "buttons": []
}
```

With buttons:

```json
{
  "title": "Check this out",
  "body": "Open the details page.",
  "layoutType": "MessageLayoutType.snackBar",
  "allowDismiss": true,
  "steps": [],
  "buttons": [
    {
      "label": "Open",
      "routeType": "ButtonRouteType.internalRoute",
      "routeInternal": "/details"
    },
    {
      "label": "Website",
      "routeType": "ButtonRouteType.externalURL",
      "routeExternal": "https://example.com"
    }
  ]
}
```

## Additional information

The package exposes `PushHandler` directly if you prefer manual wiring via
`messageStreamValue`, but the default repository already renders the built-in
layouts. Ensure your Firebase setup is complete on Android/iOS before use.
