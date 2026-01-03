import 'package:flutter/material.dart';
import 'package:push_handler/src/domain/push_data_models/image_data/image_data.dart';
import 'package:push_handler/src/presentation/push_widget.dart';

class PushSnackBarContent extends PushWidget {
  const PushSnackBarContent({
    super.key,
    required super.messageData,
    required super.onTapExpand,
    super.navigationResolver,
    super.onStepChanged,
    super.onButtonPressed,
  });

  @override
  State<PushWidget> createState() => _PushPopupState();
}

class _PushPopupState extends PushWidgetState {
  @override
  Widget build(BuildContext context) {
    final ImageData? _imageData = controller.messageData.image;

    final TextStyle? _labelMedium =
        Theme.of(context).textTheme.titleMedium;
    final TextStyle? _bodySmall =
        Theme.of(context).textTheme.bodySmall;
    final Color _onPrimary =
        Theme.of(context).colorScheme.onPrimary;

    return Row(
      children: [
        if (_imageData != null)
          Container(
            width: 50,
            height: 50,
            margin: const EdgeInsets.all(8),
            child: Image.network(
              _imageData.pathValue.value.toString(),
            ),
          ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.messageData.title.value,
                  style: _labelMedium?.copyWith(
                    color: _onPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  controller.messageData.body.value,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: _bodySmall?.copyWith(
                    color: _onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        IconButton(
          onPressed: widget.onTapExpand,
          icon: Icon(
            Icons.open_in_full,
            color: _onPrimary,
          ),
        )
      ],
    );
  }
}
