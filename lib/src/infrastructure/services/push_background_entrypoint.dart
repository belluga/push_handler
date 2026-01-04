import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:push_handler/push_handler.dart';

@pragma('vm:entry-point')
Future<void> pushHandlerBackgroundEntryPoint(RemoteMessage message) async {
  final receivedAt = DateTime.now().toUtc().toIso8601String();
  final pushMessageId = message.data['push_message_id']?.toString();
  if (pushMessageId == null || pushMessageId.isEmpty) return;

  final stored = await PushTransportStorage().load();
  final enableDebugLogs = stored?.enableDebugLogs ?? true;
  void log(String value) {
    if (enableDebugLogs) {
      debugPrint(value);
    }
  }

  log('[Push] Background entrypoint invoked.');
  if (stored != null) {
    final config = PushTransportConfig(
      baseUrl: stored.baseUrl,
      tokenProvider: () async => stored.authToken,
      deviceIdProvider: () async => stored.deviceId,
      enableDebugLogs: enableDebugLogs,
    );
    PushTransportRegistry.configure(config);
      try {
        final client = PushTransportClient(config);
        log('[Push] Background delivery attempt for $pushMessageId.');
        await client.reportAction(
          pushMessageId: pushMessageId,
          action: 'delivered',
          stepIndex: 0,
          deviceId: stored.deviceId,
          messageId: message.messageId,
          metadata: {
            'received_at': receivedAt,
          },
        );
        log('[Push] Background delivery reported for $pushMessageId.');
        return;
      } catch (_) {
        // Fall through to queue on failure.
        log('[Push] Background delivery failed; enqueueing.');
      }
  }

  await PushBackgroundDeliveryQueue().enqueue(
    PushDeliveryQueueItem(
      pushMessageId: pushMessageId,
      receivedAtIso: receivedAt,
    ),
  );
  log('[Push] Background delivery queued for $pushMessageId.');
}
