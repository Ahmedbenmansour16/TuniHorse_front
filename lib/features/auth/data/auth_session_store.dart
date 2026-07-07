import 'package:tunihorse/features/auth/data/auth_api_client.dart';

class AuthSessionStore {
  static AuthSession? _session;

  static AuthSession? get session => _session;
  static String? get accessToken => _session?.accessToken;
  static bool get isAuthenticated => _session != null;

  static void save(AuthSession session) {
    _session = session;
  }

  static void updateUser(Map<String, dynamic> user) {
    final current = _session;
    if (current == null) return;

    _session = AuthSession(
      accessToken: current.accessToken,
      role: user['role']?.toString() ?? current.role,
      user: user,
    );
  }

  static void clear() {
    _session = null;
  }
}
