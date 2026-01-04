import 'package:flutter/foundation.dart';
import 'package:push_handler/src/infrastructure/services/push_transport_client.dart';
import 'package:push_handler/src/infrastructure/services/push_transport_config.dart';
import 'package:push_handler/src/infrastructure/services/push_transport_registry.dart';

class PushTransportBackgroundReporter {
  static Future<void> reportDelivered(String pushMessageId) async {
    final config = PushTransportRegistry.config;
    if (config == null) {
      if (_shouldLog(null)) {
        debugPrint('[Push] Background transport not configured.');
      }
      return;
    }

    try {
      final client = PushTransportClient(config);
      final deviceId = await config.deviceIdProvider?.call();
      await client.reportDelivered(
        pushMessageId: pushMessageId,
        deviceId: deviceId,
      );
    } catch (error) {
      if (_shouldLog(config)) {
        debugPrint('[Push] Background delivery report failed: $error');
      }
    }
  }
}

bool _shouldLog(PushTransportConfig? config) =>
    config?.enableDebugLogs ?? true;
