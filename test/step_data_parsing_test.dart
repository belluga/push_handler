import 'package:flutter_test/flutter_test.dart';
import 'package:push_handler/push_handler.dart';

void main() {
  test('parses step slug, gate, onSubmit, and dismissible', () {
    final step = StepData.fromMap({
      'slug': 'welcome',
      'type': 'cta',
      'title': 'Welcome',
      'body': 'Body',
      'dismissible': false,
      'gate': {
        'type': 'notifications_permission',
        'onFail': {
          'toast': 'Enable notifications',
          'fallback_step': 'welcome',
        },
      },
      'onSubmit': {
        'action': 'save_response',
        'store_key': 'preferences.tags',
      },
      'config': {
        'layout': 'tags',
        'min_selected': 1,
        'max_selected': 3,
      },
      'buttons': [
        {
          'label': 'Continue',
          'action': {
            'type': 'route',
            'route_key': 'detail',
          },
        },
      ],
    });

    expect(step.slug, 'welcome');
    expect(step.type, 'cta');
    expect(step.dismissible, isFalse);
    expect(step.gate?.type, 'notifications_permission');
    expect(step.gate?.onFailToast, 'Enable notifications');
    expect(step.gate?.fallbackStepSlug, 'welcome');
    expect(step.onSubmit?.action, 'save_response');
    expect(step.onSubmit?.storeKey, 'preferences.tags');
    expect(step.config?.layout, 'tags');
    expect(step.config?.minSelected, 1);
    expect(step.config?.maxSelected, 3);
    expect(step.buttons, hasLength(1));
  });
}
