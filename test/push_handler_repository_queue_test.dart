import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:push_handler/push_handler.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  PushTransportConfig buildTransportConfig() {
    return PushTransportConfig(
      baseUrl: 'https://example.com',
      tokenProvider: () async => 'token',
      deviceIdProvider: () async => 'device-id',
    );
  }

  Map<String, dynamic> buildPayload({DateTime? expiresAt}) {
    return {
      'ok': true,
      if (expiresAt != null) 'expires_at': expiresAt.toIso8601String(),
      'payload': {
        'title': 'Hello',
        'body': 'Body',
        'allowDismiss': true,
        'layoutType': 'fullScreen',
        'backgroundColor': '#FFFFFF',
        'onClickLayoutType': 'fullScreen',
        'image': {
          'path': 'https://example.com/hero.png',
          'width': 100,
          'height': 100,
        },
        'steps': [],
        'buttons': [],
      },
    };
  }

  testWidgets('flush presents queued message and clears queue', (tester) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (ctx) {
            context = ctx;
            return const SizedBox();
          },
        ),
      ),
    );

    final queue = FakePushBackgroundDeliveryQueue();
    await queue.save([
      PushDeliveryQueueItem(
        pushMessageId: 'msg-1',
        receivedAtIso: DateTime.now().toIso8601String(),
      ),
    ]);
    final client = FakePushTransportClient(fetchResponse: buildPayload());
    final presenter = FakePushMessagePresenter();

    final repository = PushHandlerRepositoryDefault(
      transportConfig: buildTransportConfig(),
      contextProvider: () => context,
      navigationResolver: null,
      onBackgroundMessage: (_) async {},
      transportClientOverride: client,
      deliveryQueueOverride: queue,
      presenterOverride: presenter,
      enableFirebaseMessaging: false,
    );

    await repository.flushBackgroundQueue();

    expect(presenter.presented.length, 1);
    expect(queue.items, isEmpty);
    expect(
      client.actions.where((action) => action['action'] == 'delivered').length,
      1,
    );
  });

  testWidgets('expired queued message is dropped', (tester) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (ctx) {
            context = ctx;
            return const SizedBox();
          },
        ),
      ),
    );

    final queue = FakePushBackgroundDeliveryQueue();
    await queue.save([
      PushDeliveryQueueItem(
        pushMessageId: 'msg-2',
        receivedAtIso: DateTime.now().toIso8601String(),
      ),
    ]);
    final client = FakePushTransportClient(
      fetchResponse: buildPayload(
        expiresAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    );
    final presenter = FakePushMessagePresenter();

    final repository = PushHandlerRepositoryDefault(
      transportConfig: buildTransportConfig(),
      contextProvider: () => context,
      navigationResolver: null,
      onBackgroundMessage: (_) async {},
      transportClientOverride: client,
      deliveryQueueOverride: queue,
      presenterOverride: presenter,
      enableFirebaseMessaging: false,
    );

    await repository.flushBackgroundQueue();

    expect(presenter.presented, isEmpty);
    expect(queue.items, isEmpty);
    expect(client.actions, isEmpty);
  });

  testWidgets('delivery reported once when already flagged', (tester) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (ctx) {
            context = ctx;
            return const SizedBox();
          },
        ),
      ),
    );

    final queue = FakePushBackgroundDeliveryQueue();
    await queue.save([
      PushDeliveryQueueItem(
        pushMessageId: 'msg-3',
        receivedAtIso: DateTime.now().toIso8601String(),
        deliveryReported: true,
      ),
    ]);
    final client = FakePushTransportClient(fetchResponse: buildPayload());
    final presenter = FakePushMessagePresenter();

    final repository = PushHandlerRepositoryDefault(
      transportConfig: buildTransportConfig(),
      contextProvider: () => context,
      navigationResolver: null,
      onBackgroundMessage: (_) async {},
      transportClientOverride: client,
      deliveryQueueOverride: queue,
      presenterOverride: presenter,
      enableFirebaseMessaging: false,
    );

    await repository.flushBackgroundQueue();

    expect(presenter.presented.length, 1);
    expect(queue.items, isEmpty);
    expect(client.actions, isEmpty);
  });

  testWidgets('presentation failure keeps queue entry', (tester) async {
    final queue = FakePushBackgroundDeliveryQueue();
    await queue.save([
      PushDeliveryQueueItem(
        pushMessageId: 'msg-4',
        receivedAtIso: DateTime.now().toIso8601String(),
      ),
    ]);
    final client = FakePushTransportClient(fetchResponse: buildPayload());
    final presenter = FakePushMessagePresenter();

    final repository = PushHandlerRepositoryDefault(
      transportConfig: buildTransportConfig(),
      contextProvider: () => null,
      navigationResolver: null,
      onBackgroundMessage: (_) async {},
      transportClientOverride: client,
      deliveryQueueOverride: queue,
      presenterOverride: presenter,
      enableFirebaseMessaging: false,
    );

    await repository.flushBackgroundQueue();

    expect(presenter.presented, isEmpty);
    expect(queue.items.length, 1);
    expect(queue.items.first.deliveryReported, isTrue);
  });

  testWidgets('foreground presentation clears queued entry', (tester) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (ctx) {
            context = ctx;
            return const SizedBox();
          },
        ),
      ),
    );

    final queue = FakePushBackgroundDeliveryQueue();
    await queue.save([
      PushDeliveryQueueItem(
        pushMessageId: 'msg-5',
        receivedAtIso: DateTime.now().toIso8601String(),
      ),
    ]);
    final client = FakePushTransportClient(fetchResponse: buildPayload());
    final presenter = FakePushMessagePresenter();

    final repository = PushHandlerRepositoryDefault(
      transportConfig: buildTransportConfig(),
      contextProvider: () => context,
      navigationResolver: null,
      onBackgroundMessage: (_) async {},
      transportClientOverride: client,
      deliveryQueueOverride: queue,
      presenterOverride: presenter,
      enableFirebaseMessaging: false,
    );

    final message = RemoteMessage.fromMap({
      'data': {'push_message_id': 'msg-5'},
      'messageId': 'delivery-1',
    });
    await repository.handleMessageForTesting(message);

    expect(presenter.presented.length, 1);
    expect(queue.items, isEmpty);
  });
}

class FakePushTransportClient extends PushTransportClient {
  FakePushTransportClient({
    required this.fetchResponse,
  }) : super(
          PushTransportConfig(
            baseUrl: 'https://example.com',
            tokenProvider: () async => 'token',
            deviceIdProvider: () async => 'device-id',
          ),
        );

  Map<String, dynamic>? fetchResponse;
  final List<Map<String, dynamic>> actions = [];

  @override
  Future<Map<String, dynamic>?> fetchMessagePayload({
    required String pushMessageId,
    String? tokenOverride,
  }) async {
    return fetchResponse;
  }

  @override
  Future<void> reportAction({
    required String pushMessageId,
    required String action,
    required int stepIndex,
    String? buttonKey,
    String? deviceId,
    Map<String, dynamic>? metadata,
    String? idempotencyKey,
    String? messageId,
    String? tokenOverride,
  }) async {
    actions.add({
      'push_message_id': pushMessageId,
      'action': action,
      'step_index': stepIndex,
    });
  }

  @override
  Future<void> registerDevice({
    required String deviceId,
    required String platform,
    required String pushToken,
    String? tokenOverride,
  }) async {}
}

class FakePushMessagePresenter extends PushMessagePresenter {
  FakePushMessagePresenter() : super(contextProvider: () => null);

  final List<MessageData> presented = [];

  @override
  Future<void> present({
    required MessageData messageData,
    required PushActionReporter reportAction,
    String? deviceId,
  }) async {
    presented.add(messageData);
  }
}

class FakePushBackgroundDeliveryQueue extends PushBackgroundDeliveryQueue {
  List<PushDeliveryQueueItem> items = [];

  @override
  Future<List<PushDeliveryQueueItem>> load() async => List.of(items);

  @override
  Future<void> save(List<PushDeliveryQueueItem> items) async {
    this.items = List.of(items);
  }

  @override
  Future<void> enqueue(PushDeliveryQueueItem item) async {
    items = [
      for (final existing in items)
        if (existing.pushMessageId != item.pushMessageId) existing,
      item,
    ];
  }

  @override
  Future<void> removeByIds(List<String> ids) async {
    if (ids.isEmpty) return;
    items = items.where((item) => !ids.contains(item.pushMessageId)).toList();
  }
}
