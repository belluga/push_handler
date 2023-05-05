import 'package:flutter/material.dart';
import 'package:push_handler/main.dart';
import 'package:push_handler/src/domain/push_data_models/image_data/image_data.dart';

class PushStepContent extends StatelessWidget {
  final EdgeInsets? padding;
  final StepData stepData;

  const PushStepContent({super.key, required this.stepData, this.padding});

  @override
  Widget build(BuildContext context) {
    final String _body = stepData.body.value;
    final ImageData? _imageData = stepData.image;

    return Padding(
      padding: padding ?? const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_imageData != null)
            Container(
              width: _imageData.widthValue.value,
              height: _imageData.heightValue.value,
              margin: const EdgeInsets.all(8),
              child: Image.network(
                _imageData.pathValue.value.toString(),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.onPrimary,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
            ),
          if (_imageData != null) const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: Text(
                  stepData.title.value,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          if (_body.isNotEmpty) const SizedBox(height: 16),
          if (_body.isNotEmpty)
            Row(
              children: [
                Expanded(
                  child: Text(
                    stepData.body.value,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
