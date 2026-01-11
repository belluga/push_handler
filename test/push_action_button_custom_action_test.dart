import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:push_handler/push_handler.dart';
import 'package:push_handler/src/presentation/controller/push_widget_controller.dart';
import 'package:push_handler/src/presentation/widgets/push_action_button.dart';

MessageData _buildMessageData({required bool withGate}) {
  return MessageData.fromMap({
    'title': 'Title',
    'body': 'Body',
    'layoutType': 'fullScreen',
    'closeOnLastStepAction': false,
    'steps': [
      {
        'slug': 'step-1',
        'type': 'cta',
        'title': 'Step 1',
        'body': '',
        if (withGate) 'gate': {'type': 'custom_gate'},
        'buttons': [],
      },
      {
        'slug': 'step-2',
        'type': 'cta',
        'title': 'Step 2',
        'body': '',
        'buttons': [],
      },
    ],
    'buttons': [],
  });
}

class _TestPushWidgetController extends PushWidgetController {
  _TestPushWidgetController({required super.messageData});

  bool advanceInvoked = false;

  @override
  Future<void> advanceAfterGateAction() async {
    advanceInvoked = true;
  }
}

_TestPushWidgetController _buildController({bool withGate = false}) {
  return _TestPushWidgetController(
    messageData: _buildMessageData(withGate: withGate),
  );
}

ButtonData _buildButton({required bool continueAfterAction}) {
  return ButtonData.fromMap({
    'label': 'Custom',
    'continue_after_action': continueAfterAction,
    'action': {'type': 'custom', 'custom_action': 'perform_custom_action'},
  });
}

void main() {
  testWidgets('custom action does not auto-advance when flag is false',
      (tester) async {
    final controller = _buildController();
    final button = _buildButton(continueAfterAction: false);
    var invoked = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PushActionButton(
            buttonData: button,
            controller: controller,
            onCustomAction: (_, __) async {
              invoked = true;
            },
            closeOnTap: false,
          ),
        ),
      ),
    );

    expect(controller.currentIndexStreamValue.value, 0);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(invoked, isTrue);
    expect(controller.advanceInvoked, isFalse);
  });

  testWidgets('gated custom action rechecks gate even when flag is false',
      (tester) async {
    final controller = _buildController(withGate: true);
    final button = _buildButton(continueAfterAction: false);
    var invoked = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PushActionButton(
            buttonData: button,
            controller: controller,
            onCustomAction: (_, __) async {
              invoked = true;
            },
            closeOnTap: false,
          ),
        ),
      ),
    );

    expect(controller.currentIndexStreamValue.value, 0);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(invoked, isTrue);
    expect(controller.advanceInvoked, isTrue);
  });

  testWidgets('custom action auto-advances when flag is true', (tester) async {
    final controller = _buildController();
    final button = _buildButton(continueAfterAction: true);
    var invoked = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PushActionButton(
            buttonData: button,
            controller: controller,
            onCustomAction: (_, __) async {
              invoked = true;
            },
            closeOnTap: false,
          ),
        ),
      ),
    );

    expect(controller.currentIndexStreamValue.value, 0);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(invoked, isTrue);
    expect(controller.advanceInvoked, isTrue);
  });
}
