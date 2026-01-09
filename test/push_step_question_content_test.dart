import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:push_handler/push_handler.dart';
import 'package:push_handler/src/presentation/controller/push_widget_controller.dart';
import 'package:push_handler/src/presentation/widgets/push_step_question_content.dart';

MessageData _buildMessageData(StepData step) {
  return MessageData.fromMap({
    'title': 'Title',
    'body': 'Body',
    'layoutType': 'fullScreen',
    'closeOnLastStepAction': true,
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
  testWidgets('single select replaces previous choice', (tester) async {
    final step = StepData.fromMap({
      'slug': 'choose-one',
      'type': 'question',
      'title': 'Pick one',
      'config': {
        'question_type': 'single_select',
        'layout': 'list',
        'min_selected': 1,
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
            child: PushStepQuestionContent(
              stepData: step,
              controller: controller,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

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
  });

  testWidgets('min selection gates submit', (tester) async {
    final step = StepData.fromMap({
      'slug': 'choose-two',
      'type': 'question',
      'title': 'Pick two',
      'config': {
        'question_type': 'multi_select',
        'layout': 'tags',
        'min_selected': 2,
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
            child: PushStepQuestionContent(
              stepData: step,
              controller: controller,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    var continueButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Continuar'),
    );
    expect(continueButton.onPressed, isNull);

    await tester.tap(find.text('Option A'));
    await tester.pumpAndSettle();
    continueButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Continuar'),
    );
    expect(continueButton.onPressed, isNull);

    await tester.tap(find.text('Option B'));
    await tester.pumpAndSettle();
    continueButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Continuar'),
    );
    expect(continueButton.onPressed, isNotNull);
  });
}
