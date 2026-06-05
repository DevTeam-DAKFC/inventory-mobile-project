import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SessionRole { admin, collaborator }

class AppSession extends ChangeNotifier {
  bool _isAuthenticated = false;
  SessionRole? _role;

  bool get isAuthenticated => _isAuthenticated;
  SessionRole? get role => _role;
  bool get canViewAdminEntries => _role == SessionRole.admin;

  void signInAsDemoAdmin() {
    _isAuthenticated = true;
    _role = SessionRole.admin;
    notifyListeners();
  }

  void signInAsDemoCollaborator() {
    _isAuthenticated = true;
    _role = SessionRole.collaborator;
    notifyListeners();
  }

  void signOut() {
    _isAuthenticated = false;
    _role = null;
    notifyListeners();
  }
}

final appSessionProvider = Provider<AppSession>((ref) {
  final session = AppSession();
  ref.onDispose(session.dispose);
  return session;
});
