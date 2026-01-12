import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:push_handler/push_handler.dart';
import 'package:push_handler/src/presentation/controller/push_widget_controller.dart';
import 'package:push_handler/src/presentation/widgets/push_step_selector_content.dart';

MessageData _buildMessageData(StepData step) {
  return MessageData.fromMap({
    'title': 'Title',
    'body': 'Body',
    'layoutType': 'fullScreen',
    'closeBehavior': 'after_action',
    'steps': [
      {
        'slug': step.slug,
        'type': step.type,
        'title': step.title.value,
        'body': step.body.value,
        'config': step.config?.raw,
        'buttons': [],
      }
    ],
    'buttons': [],
  });
}

PushWidgetController _buildController(StepData step) {
  final messageData = _buildMessageData(step);
  final controller = PushWidgetController(messageData: messageData);
  controller.tabController = TabController(length: 1, vsync: const TestVSync());
  return controller;
}

void main() {
  testWidgets('inline selector enables submit after min selection',
      (tester) async {
    final step = StepData.fromMap({
      'slug': 'select-tags',
      'type': 'selector',
      'title': 'Pick tags',
      'config': {
        'selection_ui': 'inline',
        'selection_mode': 'multi',
        'layout': 'tags',
        'min_selected': 2,
        'max_selected': 0,
        'options': [
          {'id': 'a', 'label': 'Option A'},
          {'id': 'b', 'label': 'Option B'},
          {'id': 'c', 'label': 'Option C'},
        ],
      },
      'buttons': [],
    });

    final controller = _buildController(step);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Material(
            child: PushStepSelectorContent(
              stepData: step,
              controller: controller,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(controller.canSubmitStreamValue.value, isFalse);

    await tester.tap(find.text('Option A'));
    await tester.pumpAndSettle();
    expect(controller.canSubmitStreamValue.value, isFalse);

    await tester.tap(find.text('Option B'));
    await tester.pumpAndSettle();
    expect(controller.canSubmitStreamValue.value, isTrue);
  });

  testWidgets('inline selector single selection replaces previous choice',
      (tester) async {
    final step = StepData.fromMap({
      'slug': 'select-single',
      'type': 'selector',
      'title': 'Pick one',
      'config': {
        'selection_ui': 'inline',
        'selection_mode': 'single',
        'layout': 'list',
        'options': [
          {'id': 'a', 'label': 'Option A'},
          {'id': 'b', 'label': 'Option B'},
        ],
      },
      'buttons': [],
    });

    final controller = _buildController(step);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Material(
            child: PushStepSelectorContent(
              stepData: step,
              controller: controller,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(controller.canSubmitStreamValue.value, isFalse);

    await tester.tap(find.text('Option A'));
    await tester.pumpAndSettle();

    var firstTile = tester.widget<CheckboxListTile>(
      find.widgetWithText(CheckboxListTile, 'Option A'),
    );
    var secondTile = tester.widget<CheckboxListTile>(
      find.widgetWithText(CheckboxListTile, 'Option B'),
    );
    expect(firstTile.value, isTrue);
    expect(secondTile.value, isFalse);
    expect(controller.canSubmitStreamValue.value, isTrue);

    await tester.tap(find.text('Option B'));
    await tester.pumpAndSettle();

    firstTile = tester.widget<CheckboxListTile>(
      find.widgetWithText(CheckboxListTile, 'Option A'),
    );
    secondTile = tester.widget<CheckboxListTile>(
      find.widgetWithText(CheckboxListTile, 'Option B'),
    );
    expect(firstTile.value, isFalse);
    expect(secondTile.value, isTrue);
    expect(controller.canSubmitStreamValue.value, isTrue);
  });

  testWidgets('external selector does not render inline options',
      (tester) async {
    final step = StepData.fromMap({
      'slug': 'select-external',
      'type': 'selector',
      'title': 'Pick external',
      'config': {
        'selection_ui': 'external',
        'selection_mode': 'single',
        'layout': 'tags',
        'options': [
          {'id': 'a', 'label': 'Option A'},
          {'id': 'b', 'label': 'Option B'},
        ],
      },
      'buttons': [],
    });

    final controller = _buildController(step);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Material(
            child: PushStepSelectorContent(
              stepData: step,
              controller: controller,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Option A'), findsNothing);
    expect(find.text('Option B'), findsNothing);
  });

  testWidgets('inline selector honors pre-selected options', (tester) async {
    final step = StepData.fromMap({
      'slug': 'select-pre',
      'type': 'selector',
      'title': 'Pick pre',
      'config': {
        'selection_ui': 'inline',
        'selection_mode': 'single',
        'layout': 'list',
        'options': [
          {'id': 'a', 'label': 'Option A'},
          {'id': 'b', 'label': 'Option B', 'is_selected': true},
        ],
      },
      'buttons': [],
    });

    final controller = _buildController(step);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Material(
            child: PushStepSelectorContent(
              stepData: step,
              controller: controller,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final firstTile = tester.widget<CheckboxListTile>(
      find.widgetWithText(CheckboxListTile, 'Option A'),
    );
    final secondTile = tester.widget<CheckboxListTile>(
      find.widgetWithText(CheckboxListTile, 'Option B'),
    );

    expect(firstTile.value, isFalse);
    expect(secondTile.value, isTrue);
    expect(controller.canSubmitStreamValue.value, isTrue);
  });
}
