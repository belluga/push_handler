import 'package:push_handler/src/infrastructure/services/push_transport_config.dart';

class PushTransportRegistry {
  static PushTransportConfig? _config;

  static void configure(PushTransportConfig config) {
    _config = config;
  }

  static PushTransportConfig? get config => _config;
}
