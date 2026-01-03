import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:push_handler/src/infrastructure/services/push_transport_config.dart';

class PushTransportClient {
  final Dio _dio;
  final PushTransportConfig _config;

  PushTransportClient(this._config)
      : _dio = Dio(
          BaseOptions(
            baseUrl: _config.resolvedBaseUrl,
          ),
        );

  Future<void> registerDevice({
    required String deviceId,
    required String platform,
    required String pushToken,
    String? tokenOverride,
  }) async {
    await _dio.post(
      '/push/register',
      data: {
        'device_id': deviceId,
        'platform': platform,
        'push_token': pushToken,
      },
      options: Options(headers: await _buildAuthHeaders(tokenOverride)),
    );
  }

  Future<void> unregisterDevice({
    required String deviceId,
    String? tokenOverride,
  }) async {
    await _dio.delete(
      '/push/unregister',
      data: {
        'device_id': deviceId,
      },
      options: Options(headers: await _buildAuthHeaders(tokenOverride)),
    );
  }

  Future<Map<String, dynamic>?> fetchMessagePayload({
    required String pushMessageId,
    String? tokenOverride,
  }) async {
    final response = await _dio.get(
      '/push/messages/$pushMessageId/data',
      options: Options(headers: await _buildAuthHeaders(tokenOverride)),
    );
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      return null;
    }
    return data;
  }

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
    final resolvedIdempotencyKey = idempotencyKey ??
        buildIdempotencyKey(
          pushMessageId: pushMessageId,
          action: action,
          stepIndex: stepIndex,
          buttonKey: buttonKey,
          deviceId: deviceId,
          messageId: messageId,
        );
    final body = <String, dynamic>{
      'action': action,
      'step_index': stepIndex,
      'idempotency_key': resolvedIdempotencyKey,
    };
    if (buttonKey != null && buttonKey.isNotEmpty) {
      body['button_key'] = buttonKey;
    }
    if (deviceId != null && deviceId.isNotEmpty) {
      body['device_id'] = deviceId;
    }
    if (metadata != null && metadata.isNotEmpty) {
      body['metadata'] = metadata;
    }
    debugPrint(
      '[Push] action report send: action=$action step_index=$stepIndex'
      ' button_key=${buttonKey ?? '-'} idempotency_key=$resolvedIdempotencyKey',
    );
    await _dio.post(
      '/push/messages/$pushMessageId/actions',
      data: body,
      options: Options(headers: await _buildAuthHeaders(tokenOverride)),
    );
  }

  String buildIdempotencyKey({
    required String pushMessageId,
    required String action,
    required int stepIndex,
    String? buttonKey,
    String? deviceId,
    String? messageId,
  }) {
    final root = messageId != null && messageId.isNotEmpty
        ? messageId
        : pushMessageId;
    final source = deviceId == null || deviceId.isEmpty ? 'unknown' : deviceId;
    final button = buttonKey == null || buttonKey.isEmpty ? 'none' : buttonKey;
    return 'action:$root:$action:$stepIndex:$button:$source';
  }

  Future<void> reportDelivered({
    required String pushMessageId,
    String? deviceId,
    String? messageId,
    String? tokenOverride,
  }) async {
    await reportAction(
      pushMessageId: pushMessageId,
      action: 'delivered',
      stepIndex: 0,
      deviceId: deviceId,
      messageId: messageId,
      tokenOverride: tokenOverride,
    );
  }

  Future<Map<String, String>> _buildAuthHeaders(String? tokenOverride) async {
    final token =
        tokenOverride ?? await _config.tokenProvider?.call() ?? '';
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }
}
