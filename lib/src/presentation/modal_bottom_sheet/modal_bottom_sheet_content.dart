import 'package:flutter/material.dart';
import 'package:push_handler/src/domain/push_data_models/image_data/image_data.dart';
import 'package:push_handler/src/presentation/push_widget.dart';

class PushModalBottomSheetContent extends PushWidget {
  const PushModalBottomSheetContent(
      {super.key, required super.messageData, required super.navigatorKey});

  @override
  State<PushWidget> createState() => _PushPopupState();
}

class _PushPopupState extends PushWidgetState {
  @override
  Widget build(BuildContext context) {
    final ImageData? _imageData = controller.messageData.image;
    final BuildContext _context = controller.navigatorKey.currentContext!;

    final TextStyle? _labelMedium = Theme.of(_context).textTheme.titleMedium;
    final TextStyle? _bodySmall = Theme.of(_context).textTheme.bodySmall;
    final Color _onPrimary = Theme.of(_context).colorScheme.onPrimary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Theme.of(_context).colorScheme.primary,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (_imageData != null)
                Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.all(8),
                  child: Image.network(
                    _imageData.pathValue.value.toString(),
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    controller.messageData.title.value,
                    textAlign: TextAlign.left,
                    style: _labelMedium?.copyWith(
                      color: _onPrimary,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.open_in_full,
                  color: _onPrimary,
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    controller.messageData.body.value,
                    style: _bodySmall?.copyWith(
                      color: _onPrimary,
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
