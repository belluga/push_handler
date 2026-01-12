import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:push_handler/push_handler.dart';
import 'package:push_handler/src/presentation/controller/push_widget_controller.dart';

MessageData _buildMessageData() {
  return MessageData.fromMap({
    'title': 'Title',
    'body': 'Body',
    'layoutType': 'fullScreen',
    'closeBehavior': 'after_action',
    'steps': [
      {
        'slug': 'step-one',
        'type': 'selector',
        'title': 'Choose items',
        'config': {
          'selection_ui': 'inline',
          'min_selected': 3,
        },
        'gate': {
          'type': 'custom_gate',
        },
        'buttons': [
          {
            'label': 'Continuar',
            'continue_after_action': false,
            'action': {
              'type': 'custom',
              'custom_action': 'perform_custom_action'
            }
          }
        ],
      },
      {
        'slug': 'next',
        'type': 'copy',
        'title': 'Next',
        'body': 'Next step',
        'buttons': [],
      },
    ],
    'buttons': [],
  });
}

void main() {
  test('inline selector does not auto-skip gated selection', () async {
    final messageData = _buildMessageData();
    final controller = PushWidgetController(
      messageData: messageData,
      gatekeeper: (_) async => false,
    );
    controller.tabController = TabController(length: 2, vsync: const TestVSync());

    final initialIndex = await controller.findInitialRenderableIndex();
    expect(initialIndex, 0);

    await controller.refreshGate();

    expect(controller.currentIndexStreamValue.value, 0);
    expect(controller.tabController.index, 0);
    expect(controller.canAdvanceStreamValue.value, isTrue);
  });
}
