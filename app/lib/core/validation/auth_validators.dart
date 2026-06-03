/// Form-field validators for the authentication flow.
///
/// Returns `null` when the value is valid, or a human-readable English error
/// message otherwise.
final class AuthValidators {
  const AuthValidators._();

  static final RegExp _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required.';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters long.';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required.';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Email format is invalid.';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long.';
    }
    return null;
  }
}
