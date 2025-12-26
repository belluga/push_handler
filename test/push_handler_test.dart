import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:push_handler/push_handler.dart';

void main() {
  final Map<String, dynamic> fakePostData = {
    "pritority": "high",
    "title": "Meu título push",
    "body": "Teste com um body qualquer",
    "imageUrl":
        "https://www.opservices.com.br/wp-content/uploads/2019/06/Notifica%C3%A7%C3%A3o-push-99.png",
    "tokens": [
      "fktO8lj0Qly9wN5vDEkrDR:APA91bG82JQRft9IT1e0L3pXvp6beVTv7NBmAvn0pGtC_QDHn7zpGec_G3QMwdkGTsk1069ODTZlx6yGQ2y7h78anCuqpk5mfzjUEnYUgbOxJXl8FS_839JNdBkOOtrNpZFLj-P4uUZZ"
    ],
    "saveAsChatMessage": true,
    "data": {
      "type": "PushActionTypes.chat",
      "title": "Esse é o título",
      "body":
          "Ei! Que bom ter você aqui! Meu nome é Bela e vou te ajudar com o que precisar.",
      "layoutType": "MessageLayoutType.popup",
      "allowDismiss": false,
      "steps": [],
      "buttons": []
    }
  };

  RemoteMessage _fakeRemoteMessage = RemoteMessage.fromMap(fakePostData);

  test('test body', () {
    final pushDataMessage = MessageData.fromMap(_fakeRemoteMessage.data);
    expect(pushDataMessage.body,
        "Ei! Que bom ter você aqui! Meu nome é Bela e vou te ajudar com o que precisar.");
  });
}
