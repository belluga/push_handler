import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PushTransportStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _baseUrlKey = 'push_handler.base_url';
  static const String _tokenKey = 'push_handler.auth_token';
  static const String _deviceIdKey = 'push_handler.device_id';
  static const String _debugLogsKey = 'push_handler.debug_logs';

  Future<void> persist({
    required String baseUrl,
    required String authToken,
    required String deviceId,
    required bool enableDebugLogs,
  }) async {
    await _storage.write(key: _baseUrlKey, value: baseUrl);
    await _storage.write(key: _tokenKey, value: authToken);
    await _storage.write(key: _deviceIdKey, value: deviceId);
    await _storage.write(
      key: _debugLogsKey,
      value: enableDebugLogs ? '1' : '0',
    );
  }

  Future<PushTransportStoredConfig?> load() async {
    final baseUrl = await _storage.read(key: _baseUrlKey);
    final authToken = await _storage.read(key: _tokenKey);
    final deviceId = await _storage.read(key: _deviceIdKey);
    final debugLogsRaw = await _storage.read(key: _debugLogsKey);
    if (baseUrl == null ||
        baseUrl.isEmpty ||
        authToken == null ||
        authToken.isEmpty ||
        deviceId == null ||
        deviceId.isEmpty) {
      return null;
    }
    return PushTransportStoredConfig(
      baseUrl: baseUrl,
      authToken: authToken,
      deviceId: deviceId,
      enableDebugLogs: debugLogsRaw != '0',
    );
  }
}

class PushTransportStoredConfig {
  PushTransportStoredConfig({
    required this.baseUrl,
    required this.authToken,
    required this.deviceId,
    required this.enableDebugLogs,
  });

  final String baseUrl;
  final String authToken;
  final String deviceId;
  final bool enableDebugLogs;
}
