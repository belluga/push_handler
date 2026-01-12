import 'package:flutter/material.dart';
import 'package:push_handler/push_handler.dart';
import 'package:stream_value/core/stream_value.dart';

class PushWidgetController {
  final MessageData messageData;
  final Future<bool> Function(StepData step)? gatekeeper;
  final void Function(StepData step)? onGateBlocked;
  PushNavigationResolver? navigationResolver;
  late TabController tabController;

  final isLastTabStreamValue = StreamValue<bool>(defaultValue: false);
  final currentIndexStreamValue = StreamValue<int>(defaultValue: 0);
  final canAdvanceStreamValue = StreamValue<bool>(defaultValue: true);
  final canSubmitStreamValue = StreamValue<bool>(defaultValue: true);
  bool _allowCloseOnce = false;
  bool _suppressBackOnce = false;
  Future<void> Function()? _primaryAction;

  PushWidgetController({
    required this.messageData,
    this.gatekeeper,
    this.onGateBlocked,
  });

  bool get isLastStep {
    if (messageData.steps.isEmpty) {
      return true;
    }
    return currentIndexStreamValue.value >= messageData.steps.length - 1;
  }

  Color resolveBackgroundColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  Future<void> toNext() async {
    final canAdvance = await _ensureGateSatisfied();
    if (!canAdvance) return;
    await _advanceToNextRenderable();
  }

  Future<void> toPrevious() async {
    if (tabController.index <= 0) return;
    final targetIndex = await _findRenderableIndex(
      startIndex: tabController.index - 1,
      direction: -1,
      fallbackIndex: tabController.index,
    );
    if (targetIndex == tabController.index) return;
    tabController.animateTo(targetIndex);
  }

  void requestClose() {
    _allowCloseOnce = true;
    _suppressBackOnce = true;
  }

  bool consumeCloseRequest() {
    if (!_allowCloseOnce) {
      return false;
    }
    _allowCloseOnce = false;
    return true;
  }

  bool consumeBackSuppression() {
    if (!_suppressBackOnce) {
      return false;
    }
    _suppressBackOnce = false;
    return true;
  }

  void setPrimaryAction(Future<void> Function()? action) {
    _primaryAction = action;
  }

  Future<void> Function()? get primaryAction => _primaryAction;

  Future<int> findInitialRenderableIndex() async {
    return _findRenderableIndex(startIndex: 0, direction: 1);
  }

  Future<void> skipCurrentStep() async {
    final step = currentStep;
    if (step == null) return;
    if (!step.dismissible) {
      return;
    }
    await _advanceToNextRenderable();
  }

  StepData? get currentStep {
    final index = currentIndexStreamValue.value;
    if (index < 0 || index >= messageData.steps.length) return null;
    return messageData.steps[index];
  }

  Future<void> refreshGate() async {
    final step = currentStep;
    if (step == null) return;
    if (_shouldIgnoreGate(step)) {
      canAdvanceStreamValue.addValue(true);
      return;
    }
    final gate = step.gate;
    if (gate == null) {
      canAdvanceStreamValue.addValue(true);
      return;
    }
    final allowed = await _checkGate(notifyOnFail: false);
    canAdvanceStreamValue.addValue(allowed);
    if (allowed) {
      await _advanceToNextRenderable();
      return;
    }
    if (!allowed &&
        gate.fallbackStepSlug != null &&
        gate.fallbackStepSlug!.isNotEmpty) {
      goToStepSlug(gate.fallbackStepSlug!);
    }
  }

  Future<void> advanceAfterGateAction() async {
    final step = currentStep;
    if (step == null) return;
    final gate = step.gate;
    if (gate == null) {
      await _advanceToNextRenderable();
      return;
    }
    final allowed = await _checkGate(notifyOnFail: true);
    if (allowed) {
      await _advanceToNextRenderable();
      return;
    }
    if (gate.fallbackStepSlug != null && gate.fallbackStepSlug!.isNotEmpty) {
      goToStepSlug(gate.fallbackStepSlug!);
    }
  }

  Future<bool> _ensureGateSatisfied() async {
    return _checkGate(notifyOnFail: true);
  }

  Future<bool> _checkGate({required bool notifyOnFail}) async {
    final step = currentStep;
    if (step == null) return true;
    return _checkGateForStep(step, notifyOnFail: notifyOnFail);
  }

  Future<bool> _checkGateForStep(
    StepData step, {
    required bool notifyOnFail,
  }) async {
    if (_shouldIgnoreGate(step)) {
      return true;
    }
    final gate = step.gate;
    if (gate == null) {
      return true;
    }
    final checker = gatekeeper;
    if (checker == null) {
      return true;
    }
    try {
      final allowed = await checker(step);
      if (step == currentStep) {
        canAdvanceStreamValue.addValue(allowed);
      }
      if (!allowed && notifyOnFail) {
        onGateBlocked?.call(step);
      }
      return allowed;
    } catch (_) {
      if (step == currentStep) {
        canAdvanceStreamValue.addValue(false);
      }
      if (notifyOnFail) {
        onGateBlocked?.call(step);
      }
      return false;
    }
  }

  void goToStepSlug(String slug) {
    final index = messageData.steps.indexWhere((step) => step.slug == slug);
    if (index == -1) return;
    tabController.animateTo(index);
  }

  Future<void> _advanceToNextRenderable() async {
    final nextIndex = await _findRenderableIndex(
      startIndex: tabController.index + 1,
      direction: 1,
    );
    if (nextIndex >= tabController.length ||
        nextIndex == tabController.index) {
      return;
    }
    tabController.animateTo(nextIndex);
  }

  Future<int> _findRenderableIndex({
    required int startIndex,
    required int direction,
    int? fallbackIndex,
  }) async {
    if (messageData.steps.isEmpty) {
      return 0;
    }
    var index = startIndex;
    while (index >= 0 && index < messageData.steps.length) {
      final step = messageData.steps[index];
      final hasGate = step.gate != null && !_shouldIgnoreGate(step);
      if (!hasGate || gatekeeper == null) {
        return index;
      }
      final allowed = await _checkGateForStep(step, notifyOnFail: false);
      if (!allowed) {
        return index;
      }
      index += direction;
    }
    if (fallbackIndex != null) {
      return fallbackIndex;
    }
    if (index < 0) {
      return 0;
    }
    return messageData.steps.length - 1;
  }

  bool _shouldIgnoreGate(StepData step) {
    final gate = step.gate;
    if (gate == null) return false;
    final selectionUi = step.config?.selectionUi;
    if (step.type != 'selector' || selectionUi != 'inline') {
      return false;
    }
    final minSelected = step.config?.minSelected ?? 0;
    return minSelected > 0;
  }

  void dispose() {
    canSubmitStreamValue.dispose();
    canAdvanceStreamValue.dispose();
    currentIndexStreamValue.dispose();
    isLastTabStreamValue.dispose();
    tabController.dispose();
  }
}
