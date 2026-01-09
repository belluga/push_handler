import 'package:push_handler/src/domain/models/option_item.dart';
import 'package:push_handler/src/domain/models/option_source.dart';

class StepConfig {
  StepConfig(this.raw);

  final Map<String, dynamic> raw;

  String? get questionType => raw['question_type']?.toString();

  String? get layout => raw['layout']?.toString();

  int? get gridColumns {
    final value = raw['grid_columns'];
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  int? get minSelected {
    final value = raw['min_selected'];
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  int? get maxSelected {
    final value = raw['max_selected'];
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  String? get storeKey => raw['store_key']?.toString();

  OptionSource? get optionSource {
    final value = raw['option_source'];
    if (value is Map<String, dynamic>) {
      return OptionSource.fromMap(value);
    }
    return null;
  }

  List<OptionItem> get options {
    final rawOptions = raw['options'];
    if (rawOptions is! List) {
      return const [];
    }
    return rawOptions.map((item) {
      if (item is Map<String, dynamic>) {
        return OptionItem.fromMap(item);
      }
      return OptionItem(value: item, label: item?.toString());
    }).toList();
  }
}
