import 'package:flutter/material.dart';
import 'package:push_handler/push_handler.dart';
import 'package:stream_value/core/stream_value.dart';

class PushWidgetController {
  final MessageData messageData;
  PushNavigationResolver? navigationResolver;
  late TabController tabController;

  final isLastTabStreamValue = StreamValue<bool>(defaultValue: false);
  final currentIndexStreamValue = StreamValue<int>(defaultValue: 0);

  PushWidgetController({required this.messageData});

  Color resolveBackgroundColor(BuildContext context) {
    return messageData.backgroundColor.value ??
        Theme.of(context).colorScheme.primary;
  }

  void toNext() {
    final nextIndex = tabController.index + 1;
    if (nextIndex >= tabController.length) return;
    tabController.animateTo(nextIndex);
  }

  void toPrevious() {
    final prevIndex = tabController.index - 1;
    if (prevIndex < 0) return;
    tabController.animateTo(prevIndex);
  }

  void dispose() {
    tabController.dispose();
  }
}
