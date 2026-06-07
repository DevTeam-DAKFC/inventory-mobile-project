import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_mobile/domain/models/app_user.dart';
import 'package:inventory_mobile/navigation/app_session.dart';

AppUser _user({required UserRole role}) {
  return AppUser(
    id: 'u1',
    name: 'Test User',
    email: 'user@example.com',
    role: role,
    branchIds: const ['branch_central'],
    isActive: true,
    createdAt: DateTime.utc(2026, 6, 2, 20),
  );
}

void main() {
  group('AppSession defaults', () {
    test('starts unauthenticated with no user and no role', () {
      final session = AppSession();

      expect(session.isAuthenticated, isFalse);
      expect(session.user, isNull);
      expect(session.role, isNull);
      expect(session.canViewAdminEntries, isFalse);
    });
  });

  group('setAuthenticatedUser', () {
    test('with admin user sets state and derives admin role', () {
      final session = AppSession();
      final admin = _user(role: UserRole.admin);

      session.setAuthenticatedUser(admin);

      expect(session.user, same(admin));
      expect(session.isAuthenticated, isTrue);
      expect(session.role, SessionRole.admin);
      expect(session.canViewAdminEntries, isTrue);
    });

    test('with collaborator user sets state and derives collaborator role', () {
      final session = AppSession();
      final collaborator = _user(role: UserRole.collaborator);

      session.setAuthenticatedUser(collaborator);

      expect(session.user, same(collaborator));
      expect(session.isAuthenticated, isTrue);
      expect(session.role, SessionRole.collaborator);
      expect(session.canViewAdminEntries, isFalse);
    });

    test('notifies listeners', () {
      final session = AppSession();
      var notifications = 0;
      session.addListener(() => notifications++);

      session.setAuthenticatedUser(_user(role: UserRole.admin));

      expect(notifications, 1);
    });
  });

  group('signOut', () {
    test('clears user, isAuthenticated, role and canViewAdminEntries', () {
      final session = AppSession()
        ..setAuthenticatedUser(_user(role: UserRole.admin));

      session.signOut();

      expect(session.user, isNull);
      expect(session.isAuthenticated, isFalse);
      expect(session.role, isNull);
      expect(session.canViewAdminEntries, isFalse);
    });

    test('notifies listeners', () {
      final session = AppSession()
        ..setAuthenticatedUser(_user(role: UserRole.admin));
      var notifications = 0;
      session.addListener(() => notifications++);

      session.signOut();

      expect(notifications, 1);
    });
  });

  group('demo helpers', () {
    test('signInAsDemoAdmin populates a non-null admin user', () {
      final session = AppSession()..signInAsDemoAdmin();

      expect(session.user, isNotNull);
      expect(session.user!.role, UserRole.admin);
      expect(session.role, SessionRole.admin);
      expect(session.isAuthenticated, isTrue);
      expect(session.canViewAdminEntries, isTrue);
    });

    test('signInAsDemoCollaborator populates a non-null collaborator user', () {
      final session = AppSession()..signInAsDemoCollaborator();

      expect(session.user, isNotNull);
      expect(session.user!.role, UserRole.collaborator);
      expect(session.role, SessionRole.collaborator);
      expect(session.isAuthenticated, isTrue);
      expect(session.canViewAdminEntries, isFalse);
    });
  });
}
