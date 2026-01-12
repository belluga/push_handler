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
  testWidgets('text validator disables submit on empty value', (tester) async {
    final step = StepData.fromMap({
      'slug': 'about-me',
      'type': 'question',
      'title': 'About you',
      'config': {
        'question_type': 'text',
        'validator': 'required_text',
      },
      'buttons': [],
    });

    final controller = _buildController(step);

    String? validator(StepData step, String? value) {
      if (value == null || value.trim().isEmpty) {
        return 'Required';
      }
      return null;
    }

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Material(
            child: PushStepQuestionContent(
              stepData: step,
              controller: controller,
              stepValidator: validator,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(controller.canSubmitStreamValue.value, isFalse);

    await tester.enterText(find.byType(TextField), 'Hello');
    await tester.pumpAndSettle();
    expect(controller.canSubmitStreamValue.value, isTrue);
  });
}
