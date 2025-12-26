import 'package:flutter/material.dart';
import 'package:push_handler/push_handler.dart';

class PushHandlerRepositoryDefault extends PushHandlerRepositoryContract {
  PushHandlerRepositoryDefault(super.onBackgroundMessage);

  @override
  final globalNavigatorKey = GlobalKey<NavigatorState>();
}
