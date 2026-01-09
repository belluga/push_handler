import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:push_handler/push_handler.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MessageData buildMessageData({
    required MessageLayoutType layoutType,
    int steps = 1,
    List<Map<String, dynamic>>? buttons,
  }) {
    return MessageData.fromMap({
      'title': 'Push title',
      'body': 'Push body',
      'layoutType': layoutType.name,
      'closeOnLastStepAction': true,
      'backgroundColor': '#FFFFFF',
      'onClickLayoutType': MessageLayoutType.fullScreen.name,
      'steps': List.generate(
        steps,
        (index) => {
          'slug': 'step_${index + 1}',
          'type': 'copy',
          'title': 'Step ${index + 1}',
          'body': 'Step body ${index + 1}',
        },
      ),
      'buttons': buttons ?? const [],
    });
  }

  Future<_PresenterHarness> pumpHarness(WidgetTester tester) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (ctx) {
              context = ctx;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    final actions = <Map<String, dynamic>>[];
    PushRouteRequest? resolvedRoute;
    final presenter = PushMessagePresenter(
      contextProvider: () => context,
      navigationResolver: (request) async {
        resolvedRoute = request;
      },
    );
    return _PresenterHarness(
      context: context,
      presenter: presenter,
      actions: actions,
      reportAction: ({
        required String action,
        required int stepIndex,
        required StepData step,
        String? buttonKey,
        ButtonData? button,
        String? deviceId,
      }) async {
        actions.add({
          'action': action,
          'step_index': stepIndex,
          'button_key': buttonKey,
          'step_slug': step.slug,
        });
      },
      resolvedRouteProvider: () => resolvedRoute,
    );
  }

  testWidgets('popup layout reports opened, step_viewed, dismissed', (tester) async {
    final harness = await pumpHarness(tester);
    final messageData = buildMessageData(
      layoutType: MessageLayoutType.popup,
    );

    final presentFuture = harness.presenter.present(
      messageData: messageData,
      reportAction: harness.reportAction,
    );
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);

    await tester.tap(find.text('Continuar').first);
    await tester.pump();
    if (find.byType(Dialog).evaluate().isNotEmpty) {
      Navigator.of(harness.context).pop();
      await tester.pumpAndSettle();
    }
    await presentFuture;

    final actions = harness.actions.map((item) => item['action']).toList();
    expect(actions, contains('opened'));
    expect(actions, contains('step_viewed'));
    expect(actions, contains('dismissed'));
  });

  testWidgets('fullScreen layout reports step_viewed and clicked', (tester) async {
    final harness = await pumpHarness(tester);
    final messageData = buildMessageData(
      layoutType: MessageLayoutType.fullScreen,
      steps: 2,
      buttons: [
        {
          'label': 'Go',
          'action': {
            'type': 'route',
            'route_key': 'detail',
            'path_parameters': {'id': '123'},
          },
          'color': '#000000',
        },
      ],
    );

    final presentFuture = harness.presenter.present(
      messageData: messageData,
      reportAction: harness.reportAction,
    );
    await tester.pumpAndSettle();

    expect(find.byType(PushScreenFull), findsOneWidget);
    await tester.tap(find.text('Continuar').first);
    await tester.pump();

    await tester.tap(find.text('Go'));
    await tester.pumpAndSettle();
    if (find.byType(PushScreenFull).evaluate().isNotEmpty) {
      Navigator.of(harness.context).pop();
      await tester.pumpAndSettle();
    }
    await presentFuture;

    final actions = harness.actions;
    expect(
      actions.any(
        (item) =>
            item['action'] == 'step_viewed' && item['step_index'] == 1,
      ),
      isTrue,
    );
    expect(
      actions.any(
        (item) =>
            item['action'] == 'clicked' &&
            item['step_index'] == 1 &&
            item['button_key'] == 'detail',
      ),
      isTrue,
    );
    expect(harness.resolvedRouteProvider()?.routeKey, 'detail');
  });

  testWidgets('bottomModal layout shows modal and dismisses', (tester) async {
    final harness = await pumpHarness(tester);
    final messageData = buildMessageData(
      layoutType: MessageLayoutType.bottomModal,
    );

    final presentFuture = harness.presenter.present(
      messageData: messageData,
      reportAction: harness.reportAction,
    );
    await tester.pumpAndSettle();

    expect(find.byType(PushModalBottomSheetContent), findsOneWidget);
    Navigator.of(harness.context).pop();
    await tester.pumpAndSettle();
    await presentFuture;

    final actions = harness.actions.map((item) => item['action']).toList();
    expect(actions, contains('opened'));
    expect(actions, contains('dismissed'));
  });

  testWidgets('snackBar layout shows snackbar and dismisses', (tester) async {
    final harness = await pumpHarness(tester);
    final messageData = buildMessageData(
      layoutType: MessageLayoutType.snackBar,
    );

    final presentFuture = harness.presenter.present(
      messageData: messageData,
      reportAction: harness.reportAction,
    );
    await tester.pumpAndSettle();

    expect(find.byType(PushSnackBarContent), findsOneWidget);
    ScaffoldMessenger.of(harness.context).hideCurrentSnackBar();
    await tester.pumpAndSettle();
    await presentFuture;

    final actions = harness.actions.map((item) => item['action']).toList();
    expect(actions, contains('opened'));
    expect(actions, contains('dismissed'));
  });

  testWidgets('actionButton layout expands to full screen on tap', (tester) async {
    final harness = await pumpHarness(tester);
    final messageData = buildMessageData(
      layoutType: MessageLayoutType.actionButton,
    );

    final presentFuture = harness.presenter.present(
      messageData: messageData,
      reportAction: harness.reportAction,
    );
    await tester.pumpAndSettle();

    expect(find.byType(PushSnackBarContent), findsOneWidget);
    final snackTapTarget = find.byWidgetPredicate(
      (widget) => widget is InkWell && widget.child is PushSnackBarContent,
    );
    await tester.tap(snackTapTarget);
    await tester.pumpAndSettle();

    expect(find.byType(PushScreenFull), findsOneWidget);
    Navigator.of(harness.context).pop();
    ScaffoldMessenger.of(harness.context).hideCurrentSnackBar();
    await tester.pumpAndSettle();
    await presentFuture;
  });
}

class _PresenterHarness {
  _PresenterHarness({
    required this.context,
    required this.presenter,
    required this.actions,
    required this.reportAction,
    required this.resolvedRouteProvider,
  });

  final BuildContext context;
  final PushMessagePresenter presenter;
  final List<Map<String, dynamic>> actions;
  final PushActionReporter reportAction;
  final PushRouteRequest? Function() resolvedRouteProvider;
}
