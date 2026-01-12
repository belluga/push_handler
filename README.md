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
  "closeBehavior": "after_action",
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
  "closeBehavior": "after_action",
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

Notes:
- Each step must provide at least one of `title`, `body`, or `image`.
- HTML is auto-detected in `steps[].body` and stripped to a safe subset before storage:
  `p`, `br`, `strong`, `em`, `u`, `span` (style: `color`, `font-size`, `font-weight`),
  `ul`, `ol`, `li`, `img` (`src`, `width`, `height`, `alt`).

```json
{
  "title": "Welcome",
  "body": "Start onboarding",
  "layoutType": "MessageLayoutType.fullScreen",
  "closeBehavior": "close_button",
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

### Flow responsibilities (plugin vs app)

**Plugin responsibilities**
- Parse and validate payloads into step models.
- Render built-in layouts and CTA/step UI.
- Invoke callbacks to let the app resolve gates, options, and custom actions.
- Emit telemetry events.
- **Never** persist answers.

**App responsibilities**
- Provide options via callbacks (remote or local).
- Provide gate evaluation based on your app state.
- Persist answers (if desired) inside your own controllers or repositories.
- Implement custom actions (e.g., open external selectors).

### Callbacks & contracts

```dart
final pushRepository = PushHandlerRepositoryDefault(
  transportConfig: transportConfig,
  contextProvider: () => navigatorKey.currentContext,
  navigationResolver: resolvePushRoute,
  onBackgroundMessage: firebaseMessagingBackgroundHandler,
  gatekeeper: (step) async {
    // Gate checks are app-owned. Return true to advance.
    return true;
  },
  optionsBuilder: (source) async {
    // Return OptionItem list for dynamic selectors/questions.
    return [];
  },
  onStepSubmit: (answer, step) async {
    // Persist or forward answers here. Plugin does not store them.
  },
  stepValidator: (step, value) {
    // Return an error string to disable CTA for text questions.
    return null;
  },
  onCustomAction: (button, step) async {
    // Execute custom actions (e.g., open external selector).
  },
  onPushEvent: (event) {},
);
```

Notes:
- `gatekeeper` is called before advancing gated steps and after custom actions
  on gated steps.
- `stepValidator` is used by text questions: return a non-null string to disable CTA.
- `onStepSubmit` is called for question/selector submits (inline and text). For
  external selectors, call your app logic inside `onCustomAction` and update your
  app state so `gatekeeper` can pass.

### Selectors & gates

**Inline selectors**
- `selection_ui: inline` renders the options list/tags/grid inside the step.
- `selection_mode: single` enables CTA when one option is selected.
- `selection_mode: multi` enables CTA only when `min_selected` is met.

**External selectors**
- `selection_ui: external` does not render inline options.
- Provide a button with `action.type=custom` to open your selector UI.
- After selection, update your app state and let `gatekeeper` re-check the gate.

**Gate behavior**
- Gates are defined in the payload, but evaluation is app-owned (via `gatekeeper`).
- For gated steps, custom actions always re-check the gate and advance when it passes.

### Close behavior

`closeBehavior` is required at the message level and controls how the last step
is closed:

- `after_action`: last-step actions close the UI after completion.
- `close_button`: last-step actions keep the UI open; a close (X) appears in the top bar.

### Option pre-selection

`OptionItem.isSelected` can be set by your `optionsBuilder` to preselect items.
This works for inline selectors and for external selectors that need to present
already selected items in your custom UI.

```dart
optionsBuilder: (source) async {
  final options = await repository.fetchOptions(source);
  final selectedIds = await repository.fetchSelectedIds(source);
  return options
      .map((option) => option.copyWith(isSelected: selectedIds.contains(option.value)))
      .toList();
},
```

### Persistence guidance

The plugin never persists answers. If you need persistence, wire it into your
own app services:

```dart
final answersByKey = <String, AnswerPayload>{};

Future<void> onStepSubmit(AnswerPayload answer, StepData step) async {
  final key = step.onSubmit?.storeKey ?? step.config?.storeKey;
  if (key != null && key.isNotEmpty) {
    answersByKey[key] = answer;
  }
  await repository.saveAnswer(answer);
}

Future<bool> gatekeeper(StepData step) async {
  if (step.gate?.type == 'selection_min') {
    final key = step.onSubmit?.storeKey ?? step.config?.storeKey;
    final stored = key == null ? null : answersByKey[key];
    final value = stored?.value;
    final count = value is List ? value.length : value == null ? 0 : 1;
    final minSelected = step.config?.minSelected ?? 1;
    return count >= minSelected;
  }
  return true;
}
```

### Payload checklist

- Every step has a unique `slug`.
- `closeBehavior` is required (`after_action` or `close_button`).
- Use `store_key` on steps that need answer persistence or gate evaluation.
- For selectors, set `selection_ui` and (optionally) `selection_mode`.
- For gated steps, set `gate.type` and provide `onFail.toast` if needed.
- For external selectors, provide a custom action button.

### Reference payload (full example)

```json
{
  "title": "Onboarding",
  "body": "Complete the steps below.",
  "layoutType": "MessageLayoutType.fullScreen",
  "closeBehavior": "after_action",
  "steps": [
    {
      "slug": "permissions",
      "type": "cta",
      "title": "Enable notifications",
      "body": "Allow alerts for updates.",
      "dismissible": false,
      "gate": {
        "type": "notifications_permission",
        "onFail": { "toast": "Enable notifications to continue." }
      },
      "buttons": [
        {
          "label": "Enable",
          "continue_after_action": true,
          "action": { "type": "custom", "custom_action": "request_notifications" },
          "show_loading": true
        }
      ]
    },
    {
      "slug": "short_answer",
      "type": "question",
      "title": "Tell us more",
      "body": "Add a short note.",
      "dismissible": true,
      "config": {
        "question_type": "text",
        "validator": { "name": "required_text", "params": { "min_len": 1 } },
        "store_key": "answers.short_note"
      },
      "onSubmit": { "action": "save_response", "store_key": "answers.short_note" }
    },
    {
      "slug": "inline_selector",
      "type": "selector",
      "title": "Pick at least 2",
      "body": "Select your preferred categories.",
      "dismissible": true,
      "config": {
        "selection_ui": "inline",
        "selection_mode": "multi",
        "min_selected": 2,
        "max_selected": 5,
        "layout": "tags",
        "store_key": "answers.categories",
        "option_source": { "type": "method", "name": "getCategories" }
      }
    },
    {
      "slug": "external_selector",
      "type": "selector",
      "title": "Pick from a full list",
      "body": "Open the selector to choose items.",
      "dismissible": true,
      "config": {
        "selection_ui": "external",
        "selection_mode": "multi",
        "min_selected": 3,
        "max_selected": 8,
        "layout": "list",
        "store_key": "answers.items",
        "option_source": { "type": "method", "name": "getItems" }
      },
      "gate": {
        "type": "selection_min",
        "min_selected": 3,
        "onFail": { "toast": "Select at least 3 items." }
      },
      "buttons": [
        {
          "label": "Open selector",
          "action": { "type": "custom", "custom_action": "open_items_selector" },
          "show_loading": true
        }
      ]
    },
    {
      "slug": "finish",
      "type": "cta",
      "title": "All set",
      "body": "Continue to the app.",
      "dismissible": false,
      "buttons": [
        {
          "label": "Continue",
          "action": { "type": "route", "route_key": "home" },
          "show_loading": false
        }
      ]
    }
  ],
  "buttons": []
}
```

### Callback flow (runtime sequence)

```
Push delivered
  -> Repository parses payload
  -> Step UI renders
  -> User interacts
     - text input -> stepValidator
     - inline selection -> onStepSubmit
     - external selection -> onCustomAction (app opens selector)
  -> App updates state (optional persistence)
  -> gatekeeper called (if gate exists)
  -> advance or block + toast
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
