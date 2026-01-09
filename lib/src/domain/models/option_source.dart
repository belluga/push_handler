class OptionSource {
  final String type;
  final String name;
  final Map<String, dynamic> params;
  final int? cacheTtlSec;

  const OptionSource({
    required this.type,
    required this.name,
    required this.params,
    this.cacheTtlSec,
  });

  factory OptionSource.fromMap(Map<String, dynamic> map) {
    final paramsRaw = map['params'];
    final resolvedParams = paramsRaw is Map<String, dynamic> ? paramsRaw : <String, dynamic>{};
    final cache = map['cache_ttl_sec'];
    return OptionSource(
      type: map['type']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      params: resolvedParams,
      cacheTtlSec: cache is int ? cache : int.tryParse(cache?.toString() ?? ''),
    );
  }
}
