final class BranchWriteRequestDto {
  const BranchWriteRequestDto({required this.name, this.address});

  final String name;
  final String? address;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': name.trim(),
    'address': _normalizeOptional(address),
  };

  static String? _normalizeOptional(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}
