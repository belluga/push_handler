import 'package:flutter_test/flutter_test.dart';
import 'package:push_handler/push_handler.dart';

void main() {
  final Map<String, dynamic> payload = {
    "title": "Esse é o título",
    "body":
        "Ei! Que bom ter você aqui! Meu nome é Bela e vou te ajudar com o que precisar.",
    "layoutType": "popup",
    "closeOnLastStepAction": true,
    "backgroundColor": "#FFFFFF",
    "onClickLayoutType": "popup",
    "image": {
      "path": "https://example.com/hero.png",
      "width": 100,
      "height": 100
    },
    "steps": [],
    "buttons": []
  };

  test('test body', () {
    final pushDataMessage = MessageData.fromMap(payload);
    expect(pushDataMessage.body.value,
        "Ei! Que bom ter você aqui! Meu nome é Bela e vou te ajudar com o que precisar.");
  });
}
