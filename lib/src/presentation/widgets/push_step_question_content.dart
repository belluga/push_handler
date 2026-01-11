import 'package:flutter/material.dart';
import 'package:push_handler/push_handler.dart';
import 'package:push_handler/src/presentation/controller/push_widget_controller.dart';

class PushStepQuestionContent extends StatefulWidget {
  const PushStepQuestionContent({
    super.key,
    required this.stepData,
    required this.controller,
    this.optionsBuilder,
    this.onStepSubmit,
    this.stepValidator,
  });

  final StepData stepData;
  final PushWidgetController controller;
  final Future<List<OptionItem>> Function(OptionSource source)? optionsBuilder;
  final Future<void> Function(AnswerPayload answer, StepData step)? onStepSubmit;
  final String? Function(StepData step, String? value)? stepValidator;

  @override
  State<PushStepQuestionContent> createState() =>
      _PushStepQuestionContentState();
}

class _PushStepQuestionContentState extends State<PushStepQuestionContent> {
  final Set<dynamic> _selectedValues = {};
  final TextEditingController _textController = TextEditingController();
  List<OptionItem> _options = const [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_syncCanSubmit);
    widget.controller.setPrimaryAction(_submit);
    _syncCanSubmit();
    _loadOptions();
  }

  @override
  void didUpdateWidget(covariant PushStepQuestionContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stepData.slug != widget.stepData.slug) {
      _selectedValues.clear();
      _textController.clear();
      widget.controller.setPrimaryAction(_submit);
      _syncCanSubmit();
      _loadOptions();
    }
  }

  Future<void> _loadOptions() async {
    final config = widget.stepData.config;
    if (config == null) {
      setState(() => _options = const []);
      return;
    }
    final optionSource = config.optionSource;
    if (optionSource != null && widget.optionsBuilder != null) {
      setState(() => _loading = true);
      final options = await widget.optionsBuilder!(optionSource);
      if (!mounted) return;
      setState(() {
        _options = options;
        _loading = false;
      });
      return;
    }
    setState(() => _options = config.options);
  }

  bool _isSelectionValid() {
    final config = widget.stepData.config;
    if (config == null) return true;
    final questionType = config.questionType;
    final isSelector = widget.stepData.type == 'selector';
    final isInlineSelector = isSelector && config.selectionUi == 'inline';
    final shouldValidateSelection = !isSelector || isInlineSelector;
    if (questionType == 'text') {
      if (config.validator != null && widget.stepValidator != null) {
        final error =
            widget.stepValidator!(widget.stepData, _textController.text);
        return error == null;
      }
      return true;
    }
    if (widget.stepData.type == 'question') {
      return true;
    }
    if (!shouldValidateSelection) return true;
    if (isSelector) {
      final selectionMode = config.selectionMode ?? 'single';
      if (selectionMode == 'multi') {
        final min = config.minSelected ?? 0;
        final max = config.maxSelected;
        final shouldEnforceMax = max != null && max > 0;
        if (shouldEnforceMax && _selectedValues.length > max) return false;
        if (_selectedValues.length < min) return false;
        return true;
      }
      return _selectedValues.length == 1;
    }
    return true;
  }

  void _syncCanSubmit() {
    widget.controller.canSubmitStreamValue.addValue(_isSelectionValid());
  }

  Future<void> _submit() async {
    if (!_isSelectionValid()) return;
    final config = widget.stepData.config;
    final questionType = config?.questionType;
    dynamic value;
    if (questionType == 'text') {
      value = _textController.text.trim();
    } else if (_selectedValues.length <= 1) {
      value = _selectedValues.isEmpty ? null : _selectedValues.first;
    } else {
      value = _selectedValues.toList();
    }
    final handler = widget.onStepSubmit;
    if (handler != null) {
      final storeKey = widget.stepData.onSubmit?.storeKey ?? config?.storeKey;
      await handler(
        AnswerPayload(
          stepSlug: widget.stepData.slug,
          value: value,
          metadata: {
            'store_key': storeKey,
            'question_type': questionType,
          },
        ),
        widget.stepData,
      );
    }
    await widget.controller.toNext();
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.stepData.config;
    final questionType = config?.questionType;
    final layout = config?.layout ?? 'list';

    if (questionType == 'text') {
      return TextField(
        controller: _textController,
        minLines: 1,
        maxLines: 4,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
        ),
      );
    }

    if (widget.stepData.type == 'question') {
      return const SizedBox.shrink();
    }

    if (widget.stepData.type == 'selector' &&
        config?.selectionUi == 'external') {
      return const SizedBox.shrink();
    }

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return _buildOptions(context, layout);
  }

  Widget _buildOptions(BuildContext context, String layout) {
    switch (layout) {
      case 'row':
      case 'tags':
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _options
              .map((option) => _buildChip(context, option))
              .toList(),
        );
      case 'grid':
        final columns = widget.stepData.config?.gridColumns ?? 2;
        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.6,
          children: _options
              .map((option) => _buildGridItem(context, option))
              .toList(),
        );
      case 'list':
      default:
        return ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: _options
              .map((option) => _buildListItem(context, option))
              .toList(),
        );
    }
  }

  Widget _buildChip(BuildContext context, OptionItem option) {
    final selected = _selectedValues.contains(option.value);
    if (option.customWidgetBuilder != null) {
      return InkWell(
        onTap: () => _toggleOption(option),
        child: option.customWidgetBuilder!(context, selected),
      );
    }
    return ChoiceChip(
      label: Text(option.label ?? option.value.toString()),
      selected: selected,
      onSelected: (_) => _toggleOption(option),
    );
  }

  Widget _buildGridItem(BuildContext context, OptionItem option) {
    final selected = _selectedValues.contains(option.value);
    if (option.customWidgetBuilder != null) {
      return InkWell(
        onTap: () => _toggleOption(option),
        child: option.customWidgetBuilder!(context, selected),
      );
    }
    return Card(
      color: selected ? Theme.of(context).colorScheme.primary : null,
      child: InkWell(
        onTap: () => _toggleOption(option),
        child: Center(
          child: Text(option.label ?? option.value.toString()),
        ),
      ),
    );
  }

  Widget _buildListItem(BuildContext context, OptionItem option) {
    final selected = _selectedValues.contains(option.value);
    if (option.customWidgetBuilder != null) {
      return InkWell(
        onTap: () => _toggleOption(option),
        child: option.customWidgetBuilder!(context, selected),
      );
    }
    return CheckboxListTile(
      value: selected,
      onChanged: (_) => _toggleOption(option),
      title: Text(option.label ?? option.value.toString()),
      subtitle: option.subtitle != null ? Text(option.subtitle!) : null,
    );
  }

  void _toggleOption(OptionItem option) {
    final config = widget.stepData.config;
    if (config == null || widget.stepData.type != 'selector') {
      return;
    }
    final selectionMode = config.selectionMode ?? 'single';
    final maxSelected = config.maxSelected;
    final shouldEnforceMax = maxSelected != null && maxSelected > 0;
    setState(() {
      final isSelected = _selectedValues.contains(option.value);
      if (selectionMode == 'single') {
        if (isSelected) {
          _selectedValues.remove(option.value);
          return;
        }
        _selectedValues
          ..clear()
          ..add(option.value);
        return;
      }
      if (!isSelected && shouldEnforceMax && _selectedValues.length >= maxSelected) {
        return;
      }
      if (isSelected) {
        _selectedValues.remove(option.value);
        return;
      }
      _selectedValues.add(option.value);
    });
    _syncCanSubmit();
  }

  @override
  void dispose() {
    _textController.removeListener(_syncCanSubmit);
    if (widget.controller.primaryAction == _submit) {
      widget.controller.setPrimaryAction(null);
    }
    _textController.dispose();
    super.dispose();
  }
}
