import '../config/api_config.dart';
import 'api_service.dart';
import 'storage_service.dart';

/// Authentication Service
class AuthService {
  final _api = ApiService();
  final _storage = StorageService();

  /// Login with username and password
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _api.post(
        ApiConfig.loginEndpoint,
        {
          'username': username,
          'password': password,
        },
        requiresAuth: false,
      );

      // Save token and user data
      if (response['token'] != null) {
        await _storage.saveToken(response['token']);
      }

      if (response['user'] != null) {
        await _storage.saveUserData(response['user']);
      }

      return response;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  /// Logout
  Future<void> logout() async {
    await _storage.clearAll();
  }

  /// Check if user is authenticated
  bool isAuthenticated() {
    return _storage.isAuthenticated();
  }

  /// Get current user data
  Map<String, dynamic>? getCurrentUser() {
    return _storage.getUserData();
  }
}
