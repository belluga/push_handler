class StepSubmitData {
  final String action;
  final String storeKey;

  const StepSubmitData({
    required this.action,
    required this.storeKey,
  });

  factory StepSubmitData.fromMap(Map<String, dynamic> map) {
    return StepSubmitData(
      action: map['action']?.toString() ?? '',
      storeKey: map['store_key']?.toString() ?? '',
    );
  }
}
