import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PushTransportStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _baseUrlKey = 'push_handler.base_url';
  static const String _tokenKey = 'push_handler.auth_token';
  static const String _deviceIdKey = 'push_handler.device_id';

  Future<void> persist({
    required String baseUrl,
    required String authToken,
    required String deviceId,
  }) async {
    await _storage.write(key: _baseUrlKey, value: baseUrl);
    await _storage.write(key: _tokenKey, value: authToken);
    await _storage.write(key: _deviceIdKey, value: deviceId);
  }

  Future<PushTransportStoredConfig?> load() async {
    final baseUrl = await _storage.read(key: _baseUrlKey);
    final authToken = await _storage.read(key: _tokenKey);
    final deviceId = await _storage.read(key: _deviceIdKey);
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
    );
  }
}

class PushTransportStoredConfig {
  PushTransportStoredConfig({
    required this.baseUrl,
    required this.authToken,
    required this.deviceId,
  });

  final String baseUrl;
  final String authToken;
  final String deviceId;
}
