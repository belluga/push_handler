import 'dart:async';

import 'package:flutter/material.dart';
import 'package:push_handler/push_handler.dart';
import 'package:push_handler/src/presentation/controller/push_widget_controller.dart';

abstract class PushWidget extends StatefulWidget {
  final MessageData messageData;
  final Function()? onTapExpand ;
  final PushNavigationResolver? navigationResolver;
  final ValueChanged<int>? onStepChanged;
  final void Function(ButtonData button, int stepIndex)? onButtonPressed;
  final Future<void> Function(ButtonData button, StepData step)? onCustomAction;
  final Future<bool> Function(StepData step)? gatekeeper;
  final Future<List<OptionItem>> Function(OptionSource source)? optionsBuilder;
  final Future<void> Function(AnswerPayload answer, StepData step)? onStepSubmit;
  final void Function(StepData step)? onGateBlocked;

  const PushWidget(
      {super.key,
      required this.messageData,
      this.onTapExpand,
      this.navigationResolver,
      this.onStepChanged,
      this.onButtonPressed,
      this.onCustomAction,
      this.gatekeeper,
      this.optionsBuilder,
      this.onStepSubmit,
      this.onGateBlocked});

  @override
  State<PushWidget> createState();
}

abstract class PushWidgetState extends State<PushWidget>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late PushWidgetController controller;
  StreamSubscription<bool>? _gateSubscription;
  StreamSubscription<bool>? _submitSubscription;
  bool _isReady = false;

  @protected
  bool get isReady => _isReady;

  @override
  void initState() {
    super.initState();
    controller = PushWidgetController(
      messageData: widget.messageData,
      gatekeeper: widget.gatekeeper,
      onGateBlocked: widget.onGateBlocked,
    );
    controller.navigationResolver = widget.navigationResolver;
    controller.tabController = TabController(
      length: widget.messageData.steps.length,
      initialIndex: controller.currentIndexStreamValue.value,
      vsync: this,
    );

    _prepareInitialStep();
    controller.tabController.addListener(_listenTabController);
    WidgetsBinding.instance.addObserver(this);
    _gateSubscription = controller.canAdvanceStreamValue.stream.listen((_) {
      if (mounted) {
        setState(() {});
      }
    });
    _submitSubscription = controller.canSubmitStreamValue.stream.listen((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context);

  void _listenTabController() {
    _updateTabState();
  }

  void _updateTabState() {
    if (!_isReady) {
      return;
    }
    final stepsLength = controller.messageData.steps.length;
    final currentIndex = controller.tabController.index;
    final isLast = stepsLength == 0 || currentIndex + 1 >= stepsLength;

    if (currentIndex != controller.currentIndexStreamValue.value ||
        isLast != controller.isLastTabStreamValue.value) {
      setState(() {
        controller.isLastTabStreamValue.addValue(isLast);
        controller.currentIndexStreamValue.addValue(currentIndex);
      });
      controller.refreshGate();
      widget.onStepChanged?.call(currentIndex);
    }
  }


  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _gateSubscription?.cancel();
    _submitSubscription?.cancel();
    super.dispose();
    controller.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isReady) {
      controller.refreshGate();
    }
  }

  Future<void> _prepareInitialStep() async {
    final stepsLength = controller.messageData.steps.length;
    if (stepsLength == 0) {
      setState(() {
        _isReady = true;
      });
      return;
    }
    final initialIndex = await controller.findInitialRenderableIndex();
    if (!mounted) return;
    if (controller.tabController.index != initialIndex) {
      controller.tabController.index = initialIndex;
    }
    controller.currentIndexStreamValue.addValue(initialIndex);
    controller.isLastTabStreamValue.addValue(
      initialIndex + 1 >= stepsLength,
    );
    setState(() {
      _isReady = true;
    });
    widget.onStepChanged?.call(initialIndex);
    controller.refreshGate();
  }
}
