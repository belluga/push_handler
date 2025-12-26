import 'package:push_handler/push_handler.dart';

abstract class ChatRepositoryContract {
  
  List<MessageData>? _messagesCache;
  String? _userID;

  Future<List<MessageData>> getMessages(String userID) async {
    final List<MessageData> _list = await _getMessages(userID);

    return _list;
  }

  void clearChatMessagesCache() {
    _messagesCache = null;
  }

  bool _userIsTheSame(String userID) => _userID == userID;

  Future<List<MessageData>> _getMessages(String userID) async {
    if (_userIsTheSame(userID)) {
      List<MessageData>? _messages = _messagesCache;

      if (_messages != null) {
        return _messages;
      }
    }

    List<Map<String, dynamic>> messagesData = [];
    List<MessageData> messages = [];
    messagesData = await getChatMessagesData();

    for (Map<String, dynamic> element in messagesData) {
      messages.add(MessageData.fromMap(element));
    }

    _messagesCache = messages;

    _userID = userID;

    return Future.value(_messagesCache);
  }

  Future<List<Map<String, dynamic>>> getChatMessagesData();
}
