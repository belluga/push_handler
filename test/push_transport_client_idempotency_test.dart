import 'package:flutter_test/flutter_test.dart';
import 'package:push_handler/src/infrastructure/services/push_transport_client.dart';
import 'package:push_handler/src/infrastructure/services/push_transport_config.dart';

void main() {
  PushTransportClient buildClient() => PushTransportClient(
        const PushTransportConfig(
          baseUrl: 'https://example.com',
        ),
      );

  test('buildIdempotencyKey uses messageId when provided', () {
    final client = buildClient();

    final key = client.buildIdempotencyKey(
      pushMessageId: 'push-1',
      messageId: 'msg-1',
      action: 'clicked',
      stepIndex: 0,
      buttonKey: 'cta',
      deviceId: 'device-1',
    );

    expect(key, 'action:msg-1:clicked:0:cta:device-1');
  });

  test('buildIdempotencyKey includes button key when present', () {
    final client = buildClient();

    final first = client.buildIdempotencyKey(
      pushMessageId: 'push-1',
      action: 'clicked',
      stepIndex: 0,
      buttonKey: 'primary',
      deviceId: 'device-1',
    );
    final second = client.buildIdempotencyKey(
      pushMessageId: 'push-1',
      action: 'clicked',
      stepIndex: 0,
      buttonKey: 'secondary',
      deviceId: 'device-1',
    );

    expect(first, isNot(second));
  });

  test('buildIdempotencyKey falls back to none button key', () {
    final client = buildClient();

    final key = client.buildIdempotencyKey(
      pushMessageId: 'push-1',
      action: 'opened',
      stepIndex: 2,
      deviceId: 'device-1',
    );

    expect(key, 'action:push-1:opened:2:none:device-1');
  });

  test('buildIdempotencyKey falls back to unknown deviceId', () {
    final client = buildClient();

    final key = client.buildIdempotencyKey(
      pushMessageId: 'push-1',
      action: 'dismissed',
      stepIndex: 1,
      buttonKey: '',
      deviceId: '',
    );

    expect(key, 'action:push-1:dismissed:1:none:unknown');
  });
}
