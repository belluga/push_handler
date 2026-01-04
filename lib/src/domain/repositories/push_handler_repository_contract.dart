import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:push_handler/push_handler.dart';

abstract class PushHandlerRepositoryContract with WidgetsBindingObserver {
  PushHandlerRepositoryContract({
    required this.transportConfig,
    required this.contextProvider,
    required this.navigationResolver,
    required this.onBackgroundMessage,
    PushTransportClient? transportClientOverride,
    PushMessagePresenter? presenterOverride,
    PushBackgroundDeliveryQueue? deliveryQueueOverride,
    bool enableFirebaseMessaging = true,
    this.authChangeStream,
    String Function()? platformResolver,
  })  : _platformResolver = platformResolver ?? _defaultPlatformResolver,
        _transportClient = transportClientOverride,
        _deliveryQueue = deliveryQueueOverride ?? PushBackgroundDeliveryQueue(),
        _enableFirebaseMessaging = enableFirebaseMessaging,
        presenter = presenterOverride ??
            PushMessagePresenter(
              contextProvider: contextProvider,
              navigationResolver: navigationResolver,
            );

  final PushTransportConfig transportConfig;
  final BuildContext? Function()? contextProvider;
  final PushNavigationResolver? navigationResolver;
  final Future<void> Function(RemoteMessage) onBackgroundMessage;
  final Stream<dynamic>? authChangeStream;
  final String Function() _platformResolver;
  final PushMessagePresenter presenter;
  late PushHandler pushHandler;

  PushTransportClient? _transportClient;
  final PushBackgroundDeliveryQueue _deliveryQueue;
  final bool _enableFirebaseMessaging;
  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<dynamic>? _authSubscription;
  bool _lifecycleObserverRegistered = false;

  void _log(String message) {
    if (transportConfig.enableDebugLogs) {
      debugPrint(message);
    }
  }

  Future<void> init() async {
    _log('[Push] Repository init start.');
    PushTransportRegistry.configure(transportConfig);
    _transportClient ??= PushTransportClient(transportConfig);
    if (_enableFirebaseMessaging) {
      await PushHandler.requestPermission();
      FirebaseMessaging.onBackgroundMessage(
        pushHandlerBackgroundEntryPoint,
      );
      pushHandler = PushHandler(
        onbackgroundStartMessage: _handleBackgroundMessage,
        onMessage: _handleMessage,
        onMessageOpenedApp: _handleMessage,
      );
      await pushHandler.init();
    }
    await _persistTransportConfig();
    await _registerTokenIfAvailable();
    _listenForTokenRefresh();
    _listenForAuthChanges();
    _ensureLifecycleObserver();
    _log('[Push] Repository init flush queue.');
    await flushBackgroundQueue();
  }

  static String _defaultPlatformResolver() => 'web';

  void _ensureLifecycleObserver() {
    if (_lifecycleObserverRegistered) return;
    WidgetsBinding.instance.addObserver(this);
    _lifecycleObserverRegistered = true;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(flushBackgroundQueue());
    }
  }

  @visibleForTesting
  Future<void> handleMessageForTesting(RemoteMessage message) async {
    await _handleMessage(message);
  }

  Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    final pushMessageId = message.data['push_message_id']?.toString();
    if (pushMessageId == null || pushMessageId.isEmpty) return;
    await PushTransportBackgroundReporter.reportDelivered(pushMessageId);
    await onBackgroundMessage(message);
  }

  Future<void> _handleMessage(RemoteMessage message) async {
    final client = _transportClient;
    if (client == null) return;
    await _reportDelivered(message, client);
    await _fetchAndPresent(message, client);
  }

  void _listenForTokenRefresh() {
    final client = _transportClient;
    if (client == null) return;
    _tokenRefreshSubscription =
        FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      debugPrint(
        '[Push] Token refreshed; registering token_len=${token.length}.',
      );
      unawaited(_registerToken(token, client));
    });
  }

  void _listenForAuthChanges() {
    final stream = authChangeStream;
    final client = _transportClient;
    if (stream == null || client == null) return;
    _authSubscription = stream.listen((_) {
      unawaited(_registerTokenIfAvailable());
    });
  }

  Future<void> _registerTokenIfAvailable() async {
    final client = _transportClient;
    if (client == null) return;
    _log('[Push] Token register flow start.');
    final token = await PushHandler.getToken();
    if (token == null || token.isEmpty) {
      _log('[Push] Token unavailable; skip register.');
      return;
    }
    _log('[Push] Token acquired; token_len=${token.length}.');
    final authToken = await transportConfig.tokenProvider?.call();
    if (authToken == null || authToken.isEmpty) {
      _log('[Push] Auth token missing; skip register.');
      return;
    }
    await _persistTransportConfig();
    await _registerToken(token, client);
  }

  Future<void> _persistTransportConfig() async {
    final authToken = await transportConfig.tokenProvider?.call();
    final deviceId = await transportConfig.deviceIdProvider?.call();
    if (authToken == null ||
        authToken.isEmpty ||
        deviceId == null ||
        deviceId.isEmpty) {
      return;
    }
    final storage = PushTransportStorage();
    await storage.persist(
      baseUrl: transportConfig.resolvedBaseUrl,
      authToken: authToken,
      deviceId: deviceId,
      enableDebugLogs: transportConfig.enableDebugLogs,
    );
  }

  Future<void> flushBackgroundQueue() async {
    final client = _transportClient;
    if (client == null) return;
    final items = await _deliveryQueue.load();
    _log('[Push] Background queue size: ${items.length}.');
    if (items.isEmpty) return;
    final deviceId = await transportConfig.deviceIdProvider?.call();
    final authToken = await transportConfig.tokenProvider?.call();
    if (deviceId == null ||
        deviceId.isEmpty ||
        authToken == null ||
        authToken.isEmpty) {
      return;
    }

    final nextItems = <PushDeliveryQueueItem>[];
    for (final item in items) {
      final receivedAt = DateTime.tryParse(item.receivedAtIso);
      if (receivedAt == null) {
        continue;
      }
      _log('[Push] Background queue processing ${item.pushMessageId}.');
      final payload = await _fetchPayload(client, item.pushMessageId);
      if (payload == null) {
        nextItems.add(item);
        continue;
      }
      final expiresAt = payload.expiresAt;
      if (expiresAt != null && receivedAt.isAfter(expiresAt)) {
        _log('[Push] Background queue expired ${item.pushMessageId}.');
        continue;
      }

      var deliveryReported = item.deliveryReported;
      if (!deliveryReported) {
        try {
          await client.reportAction(
            pushMessageId: item.pushMessageId,
            action: 'delivered',
            stepIndex: 0,
            deviceId: deviceId,
            metadata: {
              'received_at': item.receivedAtIso,
            },
          );
          deliveryReported = true;
        } catch (_) {
          nextItems.add(item);
          continue;
        }
      }

      final presented = await _presentMessageData(
        payload.messageData,
        pushMessageId: item.pushMessageId,
        client: client,
        deviceId: deviceId,
        deliveryId: null,
      );
      if (presented) {
        _log('[Push] Background queue sent ${item.pushMessageId}.');
        continue;
      }

      nextItems.add(
        PushDeliveryQueueItem(
          pushMessageId: item.pushMessageId,
          receivedAtIso: item.receivedAtIso,
          deliveryReported: deliveryReported,
        ),
      );
      _log('[Push] Background queue failed ${item.pushMessageId}.');
    }

    await _deliveryQueue.save(nextItems);
  }

  Future<_PushMessagePayload?> _fetchPayload(
    PushTransportClient client,
    String pushMessageId,
  ) async {
    try {
      final response = await client.fetchMessagePayload(
        pushMessageId: pushMessageId,
      );
      if (response == null) return null;
      const messageDataService = PushMessageDataService();
      final messageData = messageDataService.fromApiResponse(response);
      if (messageData == null) return null;
      return _PushMessagePayload(
        messageData: messageData,
        expiresAt: _extractExpiresAt(response),
      );
    } catch (_) {
      return null;
    }
  }

  DateTime? _extractExpiresAt(Map<String, dynamic> response) {
    final direct = _parseDate(response['expires_at']);
    if (direct != null) return direct;
    final delivery = response['delivery'];
    if (delivery is Map<String, dynamic>) {
      final nested = _parseDate(delivery['expires_at']);
      if (nested != null) return nested;
    }
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      final nested = _parseDate(data['expires_at']);
      if (nested != null) return nested;
    }
    return null;
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    final text = value.toString();
    if (text.isEmpty) return null;
    return DateTime.tryParse(text);
  }

  Future<void> _registerToken(
    String token,
    PushTransportClient client,
  ) async {
    final deviceId = await transportConfig.deviceIdProvider?.call();
    if (deviceId == null || deviceId.isEmpty) {
      _log('[Push] Device id missing; skip register.');
      return;
    }
    final platform = _platformResolver();
    final resolvedPlatform =
        (platform == 'android' || platform == 'ios') ? platform : 'web';
    _log(
      '[Push] Registering device: device_id=$deviceId platform=$resolvedPlatform '
      'token_len=${token.length}.',
    );
    await client.registerDevice(
      deviceId: deviceId,
      platform: resolvedPlatform,
      pushToken: token,
    );
  }

  Future<void> _reportDelivered(
    RemoteMessage message,
    PushTransportClient client,
  ) async {
    final pushMessageId = message.data['push_message_id']?.toString();
    if (pushMessageId == null || pushMessageId.isEmpty) return;
    final deviceId = await transportConfig.deviceIdProvider?.call();
    if (deviceId == null || deviceId.isEmpty) return;
    final deliveryId = message.messageId;
    try {
      await client.reportAction(
        pushMessageId: pushMessageId,
        action: 'delivered',
        stepIndex: 0,
        deviceId: deviceId,
        messageId: deliveryId,
      );
    } catch (_) {
      // Ignore delivery reporting failures.
    }
  }

  Future<void> _fetchAndPresent(
    RemoteMessage message,
    PushTransportClient client,
  ) async {
    final pushMessageId = message.data['push_message_id']?.toString();
    if (pushMessageId == null || pushMessageId.isEmpty) return;
    final deliveryId = message.messageId;
    final payload = await _fetchPayload(client, pushMessageId);
    if (payload == null) return;
    final deviceId = await transportConfig.deviceIdProvider?.call();
    if (deviceId == null || deviceId.isEmpty) return;
    final presented = await _presentMessageData(
      payload.messageData,
      pushMessageId: pushMessageId,
      client: client,
      deviceId: deviceId,
      deliveryId: deliveryId,
    );
    if (presented) {
      await _deliveryQueue.removeByIds([pushMessageId]);
    }
  }

  Future<bool> _presentMessageData(
    MessageData messageData, {
    required String pushMessageId,
    required PushTransportClient client,
    required String deviceId,
    String? deliveryId,
  }) async {
    final context = contextProvider?.call();
    if (context == null) return false;
    await presenter.present(
      messageData: messageData,
      deviceId: deviceId,
      reportAction: ({
        required String action,
        required int stepIndex,
        String? buttonKey,
        String? deviceId,
      }) {
        _log(
          '[Push] action report queued: action=$action step_index=$stepIndex'
          ' button_key=${buttonKey ?? '-'} message_id=${deliveryId ?? '-'}',
        );
        unawaited(
          client
              .reportAction(
                pushMessageId: pushMessageId,
                action: action,
                stepIndex: stepIndex,
                buttonKey: buttonKey,
                deviceId: deviceId,
                messageId: deliveryId,
              )
              .catchError((_) {}),
        );
        return Future.value();
      },
    );
    return true;
  }

  Future<void> dispose() async {
    await _tokenRefreshSubscription?.cancel();
    await _authSubscription?.cancel();
  }
}

class _PushMessagePayload {
  _PushMessagePayload({
    required this.messageData,
    this.expiresAt,
  });

  final MessageData messageData;
  final DateTime? expiresAt;
}
