import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:push_handler/push_handler.dart';
import 'package:push_handler/src/presentation/push_screen_full/push_screen_full.dart';

MessageData _buildMessage(String closeBehavior) {
  return MessageData.fromMap({
    'title': 'Title',
    'body': 'Body',
    'layoutType': 'fullScreen',
    'closeBehavior': closeBehavior,
    'steps': [
      {
        'slug': 'finish',
        'type': 'cta',
        'title': 'Finish',
        'body': 'Final step',
        'dismissible': false,
        'buttons': [],
      },
    ],
    'buttons': [],
  });
}

void main() {
  testWidgets('close button shows on last step when closeBehavior=close_button',
      (tester) async {
    final message = _buildMessage('close_button');

    await tester.pumpWidget(
      MaterialApp(
        home: PushScreenFull(messageData: message),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.close), findsOneWidget);
  });

  testWidgets('close button hides when closeBehavior=after_action',
      (tester) async {
    final message = _buildMessage('after_action');

    await tester.pumpWidget(
      MaterialApp(
        home: PushScreenFull(messageData: message),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.close), findsNothing);
  });
}
