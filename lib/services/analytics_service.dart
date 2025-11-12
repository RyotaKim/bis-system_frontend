import '../config/api_config.dart';
import 'api_service.dart';

/// Analytics Service for dashboard statistics
class AnalyticsService {
  final _api = ApiService();

  /// Get dashboard statistics
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await _api.get(ApiConfig.analyticsEndpoint);
      return response;
    } catch (e) {
      throw Exception('Failed to fetch dashboard stats: $e');
    }
  }

  /// Get weekly requests data for charts
  Future<List<dynamic>> getWeeklyRequests() async {
    try {
      final response = await _api.get(ApiConfig.weeklyRequestsEndpoint);
      return response['data'] ?? response;
    } catch (e) {
      throw Exception('Failed to fetch weekly requests: $e');
    }
  }

  /// Get weekly complaints data for charts
  Future<List<dynamic>> getWeeklyComplaints() async {
    try {
      final response = await _api.get(ApiConfig.weeklyComplaintsEndpoint);
      return response['data'] ?? response;
    } catch (e) {
      throw Exception('Failed to fetch weekly complaints: $e');
    }
  }
}
