import 'package:push_handler/src/domain/push_data_models/message_data/message_data.dart';

class PushMessageDataService {
  const PushMessageDataService();

  MessageData? fromApiResponse(dynamic data) {
    if (data is! Map<String, dynamic>) {
      return null;
    }
    if (data['ok'] != true) {
      return null;
    }
    final payload = data['payload'];
    if (payload is! Map<String, dynamic>) {
      return null;
    }
    return MessageData.fromMap(payload);
  }
}
