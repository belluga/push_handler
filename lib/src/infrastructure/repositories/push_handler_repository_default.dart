import 'package:push_handler/push_handler.dart';

class PushHandlerRepositoryDefault extends PushHandlerRepositoryContract {
  PushHandlerRepositoryDefault({
    required super.transportConfig,
    required super.contextProvider,
    required super.navigationResolver,
    required super.onBackgroundMessage,
    super.presentationGate,
    super.gatekeeper,
    super.optionsBuilder,
    super.onStepSubmit,
    super.onCustomAction,
    super.transportClientOverride,
    super.presenterOverride,
    super.deliveryQueueOverride,
    super.enableFirebaseMessaging,
    super.authChangeStream,
    super.platformResolver,
    super.onPushEvent,
  });
}
