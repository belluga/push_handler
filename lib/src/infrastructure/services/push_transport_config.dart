typedef PushTokenProvider = Future<String?> Function();
typedef PushDeviceIdProvider = Future<String?> Function();

class PushTransportConfig {
  final String baseUrl;
  final String apiPrefix;
  final PushTokenProvider? tokenProvider;
  final PushDeviceIdProvider? deviceIdProvider;

  const PushTransportConfig({
    required this.baseUrl,
    this.apiPrefix = '/v1',
    this.tokenProvider,
    this.deviceIdProvider,
  });

  String get resolvedBaseUrl {
    final trimmed = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    return '$trimmed$apiPrefix';
  }
}
