# push_handler

Push UI handler for Firebase Messaging that renders rich in-app layouts
and routes actions based on the push payload.

## Features

- Parse push payloads into typed data models.
- Built-in layouts: popup, full screen, bottom sheet, action button, snackbar.
- Button routing: internal routes, internal routes with item argument, external URL.
- Stream-based message handling for custom UI wiring.
- Step-based onboarding with gates, per-step buttons, and dynamic selectors.
- Event emission for push telemetry (delivered/opened/step/button/submit).

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

### Presentation gate (optional)

By default, the repository auto-presents the push UI as soon as data is
available. If your app needs to wait for a bootstrap route stack, provide
`presentationGate` to delay UI until you are ready.

```dart
final gate = Completer<void>();

final pushRepository = PushHandlerRepositoryDefault(
  transportConfig: transportConfig,
  contextProvider: () => navigatorKey.currentContext,
  navigationResolver: resolvePushRoute,
  onBackgroundMessage: firebaseMessagingBackgroundHandler,
  presentationGate: () => gate.future,
);

// Call this after your init stack is rendered.
gate.complete();
```

### Background queue semantics

- Only the latest queued push is kept. New background deliveries replace
  previous queued items.
- When the app is opened via a push tap, the queue is cleared for that
  `push_message_id` to avoid replays on the next launch.

### Payload format (data)

Minimal example:

```json
{
  "title": "Welcome",
  "body": "Thanks for installing.",
  "layoutType": "MessageLayoutType.popup",
  "closeOnLastStepAction": true,
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
  "closeOnLastStepAction": true,
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

### Dynamic onboarding steps

Steps are slug-based and can include gates, per-step buttons, and question/selector
configs. Body supports Markdown or HTML (images included).

```json
{
  "title": "Welcome",
  "body": "Start onboarding",
  "layoutType": "MessageLayoutType.fullScreen",
  "closeOnLastStepAction": false,
  "steps": [
    {
      "slug": "notify",
      "type": "cta",
      "title": "Be notified",
      "body": "Allow notifications so we can alert you.",
      "dismissible": false,
      "gate": {
        "type": "notifications_permission",
        "onFail": {
          "toast": "Enable notifications to continue.",
          "fallback_step": "notify"
        }
      },
      "buttons": [
        {
          "label": "Enable",
          "continue_after_action": true,
          "action": {
            "type": "custom",
            "custom_action": "request_notifications"
          }
        }
      ]
    },
    {
      "slug": "prefs",
      "type": "question",
      "title": "What do you like?",
      "body": "Pick up to 3 categories.",
      "onSubmit": { "action": "save_response", "store_key": "preferences.tags" },
      "config": {
        "question_type": "multi_select",
        "layout": "tags",
        "min_selected": 1,
        "max_selected": 3,
        "option_source": {
          "type": "method",
          "name": "getTags",
          "params": { "include": ["beaches", "food", "culture"] },
          "cache_ttl_sec": 3600
        }
      }
    }
  ],
  "buttons": []
}
```

Custom actions default to replacing the continue behavior. Set
`continue_after_action: true` on a button to run the custom action and then
auto-advance (with gate recheck).

### Hooks for app integration

```dart
final pushRepository = PushHandlerRepositoryDefault(
  transportConfig: transportConfig,
  contextProvider: () => navigatorKey.currentContext,
  navigationResolver: resolvePushRoute,
  onBackgroundMessage: firebaseMessagingBackgroundHandler,
  gatekeeper: (step) async => true, // gate check per step
  optionsBuilder: (source) async => [], // dynamic options
  onStepSubmit: (answer, step) async {}, // persist answers
  onPushEvent: (event) {}, // telemetry bridge
);
```

### Debug injection

Use the debug hook to test the payload pipeline without FCM:

```dart
await pushRepository.debugInjectMessageId('push-message-id');
```

## Additional information

The package exposes `PushHandler` directly if you prefer manual wiring via
`messageStreamValue`, but the default repository already renders the built-in
layouts. Ensure your Firebase setup is complete on Android/iOS before use.
