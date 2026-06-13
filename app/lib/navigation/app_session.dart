import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/app_user.dart';

enum SessionRole { admin, collaborator }

class AppSession extends ChangeNotifier {
  bool _isAuthenticated = false;
  SessionRole? _role;
  AppUser? _user;

  bool get isAuthenticated => _isAuthenticated;
  SessionRole? get role => _role;
  AppUser? get user => _user;
  bool get canViewAdminEntries => _role == SessionRole.admin;

  /// Promotes the session to "authenticated" with a real domain user.
  ///
  /// Derives [SessionRole] from [AppUser.role] so the existing router and
  /// role checks keep working without changes.
  void setAuthenticatedUser(AppUser user) {
    _user = user;
    _isAuthenticated = true;
    _role = _sessionRoleFromUserRole(user.role);
    notifyListeners();
  }

  void signInAsDemoAdmin() {
    setAuthenticatedUser(_demoAdminUser);
  }

  void signInAsDemoCollaborator() {
    setAuthenticatedUser(_demoCollaboratorUser);
  }

  void signOut() {
    _user = null;
    _isAuthenticated = false;
    _role = null;
    notifyListeners();
  }

  static SessionRole _sessionRoleFromUserRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return SessionRole.admin;
      case UserRole.collaborator:
        return SessionRole.collaborator;
    }
  }

  static final AppUser _demoAdminUser = AppUser(
    id: 'demo_admin_user',
    name: 'Demo Admin',
    email: 'demo.admin@inventory.local',
    role: UserRole.admin,
    branchIds: const ['demo_branch'],
    isActive: true,
    createdAt: DateTime.utc(2026, 1, 1),
  );

  static final AppUser _demoCollaboratorUser = AppUser(
    id: 'demo_collaborator_user',
    name: 'Demo Collaborator',
    email: 'demo.collaborator@inventory.local',
    role: UserRole.collaborator,
    branchIds: const ['demo_branch'],
    isActive: true,
    createdAt: DateTime.utc(2026, 1, 1),
  );
}

final appSessionProvider = Provider<AppSession>((ref) {
  final session = AppSession();
  ref.onDispose(session.dispose);
  return session;
});
