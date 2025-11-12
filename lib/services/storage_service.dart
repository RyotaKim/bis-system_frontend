import 'package:flutter/foundation.dart';

/// Simple storage service for managing auth tokens and user data
/// For production, consider using flutter_secure_storage or shared_preferences
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // In-memory storage (for demo purposes)
  // In production, use flutter_secure_storage or shared_preferences
  String? _token;
  Map<String, dynamic>? _userData;

  // Token management
  Future<void> saveToken(String token) async {
    _token = token;
    if (kDebugMode) {
      print('Token saved: ${token.substring(0, 20)}...');
    }
  }

  String? getToken() {
    return _token;
  }

  Future<void> clearToken() async {
    _token = null;
    if (kDebugMode) {
      print('Token cleared');
    }
  }

  // User data management
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    _userData = userData;
    if (kDebugMode) {
      print('User data saved: ${userData['username']}');
    }
  }

  Map<String, dynamic>? getUserData() {
    return _userData;
  }

  Future<void> clearUserData() async {
    _userData = null;
    if (kDebugMode) {
      print('User data cleared');
    }
  }

  // Clear all data (logout)
  Future<void> clearAll() async {
    await clearToken();
    await clearUserData();
  }

  // Check if user is authenticated
  bool isAuthenticated() {
    return _token != null && _token!.isNotEmpty;
  }
}
