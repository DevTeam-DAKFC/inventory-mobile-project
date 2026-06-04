/// Store branch where inventory is held.
final class Branch {
  const Branch({
    required this.id,
    required this.name,
    required this.isActive,
    required this.createdAt,
    this.address,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String? address;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
}
