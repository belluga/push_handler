import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:push_handler/push_handler.dart';
import 'package:push_handler/src/infrastructure/services/route_navigation.dart';
import 'package:push_handler/src/presentation/controller/push_widget_controller.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

void main() {
  testWidgets('external url uses url_launcher directly', (tester) async {
    final previous = UrlLauncherPlatform.instance;
    final launcher = _FakeUrlLauncher();
    UrlLauncherPlatform.instance = launcher;
    addTearDown(() {
      UrlLauncherPlatform.instance = previous;
    });

    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (ctx) {
            context = ctx;
            return const SizedBox();
          },
        ),
      ),
    );

    final message = MessageData.fromMap({
      'title': 't',
      'body': 'b',
      'layoutType': 'fullScreen',
      'closeBehavior': 'close_button',
      'steps': [],
      'buttons': [],
    });
    final controller = PushWidgetController(messageData: message);
    final button = ButtonData.fromMap({
      'label': 'Saiba mais',
      'action': {
        'type': 'external',
        'url': 'https://example.com',
      },
    });

    final navigation = ButtonRouteNavigation(
      buttonData: button,
      controller: controller,
      context: context,
      closeOnTap: false,
    );

    navigation.navigate();
    await tester.pump();

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
