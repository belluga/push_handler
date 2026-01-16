import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:push_handler/push_handler.dart';

@pragma('vm:entry-point')
Future<void> pushHandlerBackgroundEntryPoint(RemoteMessage message) async {
  final receivedAt = DateTime.now().toUtc().toIso8601String();
  final pushMessageId = message.data['push_message_id']?.toString();
  final messageInstanceId =
      message.data['message_instance_id']?.toString() ?? message.messageId;
  if (pushMessageId == null || pushMessageId.isEmpty) return;

  PushTransportStoredConfig? stored;
  var enableDebugLogs = true;
  try {
    stored = await PushTransportStorage().load();
    enableDebugLogs = stored?.enableDebugLogs ?? true;
  } catch (error) {
    debugPrint('[Push] Background storage unavailable: $error');
  }
  void log(String value) {
    if (enableDebugLogs) {
      debugPrint(value);
    }
  }

  log('[Push] Background entrypoint invoked.');
  final resolvedStored = stored;
  if (resolvedStored != null) {
    final config = PushTransportConfig(
      baseUrl: resolvedStored.baseUrl,
      tokenProvider: () async => resolvedStored.authToken,
      deviceIdProvider: () async => resolvedStored.deviceId,
      enableDebugLogs: enableDebugLogs,
    );
    PushTransportRegistry.configure(config);
    try {
      final client = PushTransportClient(config);
      log(
        '[Push] Background delivery attempt for $pushMessageId instance=${messageInstanceId ?? '-'}.',
      );
      await client.reportAction(
        pushMessageId: pushMessageId,
        action: 'delivered',
        stepIndex: 0,
        deviceId: resolvedStored.deviceId,
        messageId: messageInstanceId,
        metadata: {
          'received_at': receivedAt,
        },
      );
      log(
        '[Push] Background delivery reported for $pushMessageId instance=${messageInstanceId ?? '-'}.',
      );
      return;
    } catch (_) {
      // Fall through to queue on failure.
      log('[Push] Background delivery failed; enqueueing.');
    }
  }

  try {
    await PushBackgroundDeliveryQueue().enqueue(
      PushDeliveryQueueItem(
        pushMessageId: pushMessageId,
        receivedAtIso: receivedAt,
        messageInstanceId: messageInstanceId,
      ),
    );
    log(
      '[Push] Background delivery queued for $pushMessageId instance=${messageInstanceId ?? '-'}.',
    );
  } catch (error) {
    log('[Push] Background queue unavailable; skipping.');
  }
}
