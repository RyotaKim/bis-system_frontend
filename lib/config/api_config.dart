/// API Configuration
/// Contains all API endpoint configurations and constants
class ApiConfig {
  // Base URL - Change this to your backend URL
  static const String baseUrl = 'http://localhost:3000/api';

  // Auth endpoints
  static const String loginEndpoint = '/auth/login';

  // Request endpoints
  static const String requestsEndpoint = '/requests';
  static String requestByIdEndpoint(String id) => '/requests/$id';
  static String updateRequestStatusEndpoint(String id) =>
      '/requests/$id/status';

  // Complaint endpoints
  static const String complaintsEndpoint = '/complaints';
  static String complaintByIdEndpoint(String id) => '/complaints/$id';
  static String updateComplaintStatusEndpoint(String id) =>
      '/complaints/$id/status';

  // Document types endpoints
  static const String documentTypesEndpoint = '/document-types';

  // Analytics endpoints
  static const String analyticsEndpoint = '/analytics';
  static const String weeklyRequestsEndpoint = '/analytics/weekly-requests';
  static const String weeklyComplaintsEndpoint = '/analytics/weekly-complaints';

  // Request timeout
  static const Duration timeout = Duration(seconds: 30);

  // Headers
  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Map<String, String> headersWithAuth(String token) => {
        ...headers,
        'Authorization': 'Bearer $token',
      };
}
