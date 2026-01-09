import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PushBackgroundDeliveryQueue {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _queueKey = 'push_handler.delivery_queue';

  Future<List<PushDeliveryQueueItem>> load() async {
    final raw = await _storage.read(key: _queueKey);
    if (raw == null || raw.isEmpty) return <PushDeliveryQueueItem>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <PushDeliveryQueueItem>[];
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(PushDeliveryQueueItem.fromMap)
          .toList();
    } catch (_) {
      return <PushDeliveryQueueItem>[];
    }
  }

  Future<void> save(List<PushDeliveryQueueItem> items) async {
    final encoded = jsonEncode(items.map((item) => item.toMap()).toList());
    await _storage.write(key: _queueKey, value: encoded);
  }

  Future<void> enqueue(PushDeliveryQueueItem item) async {
    await save([item]);
  }

  Future<void> removeByIds(List<String> ids) async {
    if (ids.isEmpty) return;
    final items = await load();
    final filtered = items.where((item) => !ids.contains(item.pushMessageId)).toList();
    await save(filtered);
  }
}

class PushDeliveryQueueItem {
  PushDeliveryQueueItem({
    required this.pushMessageId,
    required this.receivedAtIso,
    this.messageInstanceId,
    this.deliveryReported = false,
  });

  final String pushMessageId;
  final String receivedAtIso;
  final String? messageInstanceId;
  final bool deliveryReported;

  factory PushDeliveryQueueItem.fromMap(Map<String, dynamic> map) {
    return PushDeliveryQueueItem(
      pushMessageId: map['push_message_id']?.toString() ?? '',
      receivedAtIso: map['received_at']?.toString() ?? '',
      messageInstanceId: map['message_instance_id']?.toString(),
      deliveryReported: map['delivery_reported'] == true,
    );
  }

  Map<String, dynamic> toMap() => {
        'push_message_id': pushMessageId,
        'received_at': receivedAtIso,
        'message_instance_id': messageInstanceId,
        'delivery_reported': deliveryReported,
      };
}
