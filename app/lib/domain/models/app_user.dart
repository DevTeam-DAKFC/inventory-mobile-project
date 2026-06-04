/// Role of an authenticated user.
enum UserRole { admin, collaborator }

/// Authenticated user of the inventory mobile app.
final class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.branchIds,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String email;
  final UserRole role;
  final List<String> branchIds;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
}
