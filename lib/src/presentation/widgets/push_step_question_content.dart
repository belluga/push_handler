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
  });

  final StepData stepData;
  final PushWidgetController controller;
  final Future<List<OptionItem>> Function(OptionSource source)? optionsBuilder;
  final Future<void> Function(AnswerPayload answer, StepData step)? onStepSubmit;

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
    _loadOptions();
  }

  @override
  void didUpdateWidget(covariant PushStepQuestionContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stepData.slug != widget.stepData.slug) {
      _selectedValues.clear();
      _textController.clear();
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
    final min = config.minSelected ?? 0;
    final max = config.maxSelected;
    if (config.questionType == 'text') {
      if (min <= 0) return true;
      return _textController.text.trim().isNotEmpty;
    }
    if (max != null && _selectedValues.length > max) return false;
    if (_selectedValues.length < min) return false;
    return true;
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
      return Column(
        children: [
          TextField(
            controller: _textController,
            minLines: 1,
            maxLines: 4,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _submit,
            child: const Text('Continuar'),
          ),
        ],
      );
    }

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final content = _buildOptions(context, layout);
    return Column(
      children: [
        content,
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _isSelectionValid() ? _submit : null,
          child: const Text('Continuar'),
        ),
      ],
    );
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
    final maxSelected = config?.maxSelected;
    final questionType = config?.questionType;
    final isSingleSelect = questionType == 'single_select';
    final isMultiSelect = questionType == 'multi_select' || !isSingleSelect;
    setState(() {
      if (_selectedValues.contains(option.value)) {
        _selectedValues.remove(option.value);
        return;
      }
      if (isSingleSelect) {
        _selectedValues
          ..clear()
          ..add(option.value);
        return;
      }
      if (maxSelected != null && _selectedValues.length >= maxSelected && isMultiSelect) {
        return;
      }
      _selectedValues.add(option.value);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
