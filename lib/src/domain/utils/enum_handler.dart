class EnumHandler {
  static T enumFromString<T extends Enum>({
    required List<T> values,
    required String value,
    required T defaultValue,
  }) {
    for (final entry in values) {
      if (entry.name == value) {
        return entry;
      }
    }
    return defaultValue;
  }

  static T? enumOrNullFromString<T extends Enum>({
    required List<T> values,
    required String value,
  }) {
    for (final entry in values) {
      if (entry.name == value) {
        return entry;
      }
    }
    return null;
  }
}
