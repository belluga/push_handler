import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:push_handler/push_handler.dart';
import 'package:push_handler/src/presentation/push_screen_full/push_screen_full.dart';
import 'package:push_handler/src/presentation/push_widget.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

void main() {
  testWidgets('last step action does not navigate to previous step',
      (tester) async {
    final previous = UrlLauncherPlatform.instance;
    final launcher = _FakeUrlLauncher();
    UrlLauncherPlatform.instance = launcher;
    addTearDown(() {
      UrlLauncherPlatform.instance = previous;
    });

    final message = MessageData.fromMap({
      'title': 'Title',
      'body': 'Body',
      'layoutType': 'fullScreen',
      'closeBehavior': 'after_action',
      'steps': [
        {
          'slug': 'start',
          'type': 'cta',
          'title': 'Start',
          'body': 'Step 1',
          'dismissible': false,
          'buttons': [],
        },
        {
          'slug': 'finish',
          'type': 'cta',
          'title': 'Finish',
          'body': 'Final step',
          'dismissible': false,
          'buttons': [
            {
              'label': 'Saiba mais',
              'action': {
                'type': 'external',
                'url': 'https://example.com',
              },
            }
          ],
        },
      ],
      'buttons': [],
    });

    await tester.pumpWidget(
      MaterialApp(
        home: PushScreenFull(messageData: message),
      ),
    );
    await tester.pumpAndSettle();

    final state =
        tester.state(find.byType(PushScreenFull)) as PushWidgetState;
    state.controller.goToStepSlug('finish');
    await tester.pumpAndSettle();

    expect(state.controller.currentIndexStreamValue.value, 1);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(state.controller.currentIndexStreamValue.value, 1);
    expect(launcher.launchedUrl?.toString(), 'https://example.com');
  });
}

class _FakeUrlLauncher extends UrlLauncherPlatform {
  Uri? launchedUrl;

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    launchedUrl = Uri.parse(url);
    return true;
  }
}
