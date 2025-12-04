/// API Configuration
/// Contains all API endpoint configurations and constants
class ApiConfig {
  // Base URL - Change this to your backend URL
  static const String baseUrl = 'https://bis-system-backend.onrender.com/api';

  // Auth endpoints
  static const String loginEndpoint = '/auth/login';

  // Admin endpoints
  static const String adminRequestsEndpoint = '/admin/requests';
  static String adminRequestByIdEndpoint(String id) => '/admin/requests/$id';
  static String adminUpdateRequestStatusEndpoint(String id) =>
      '/admin/requests/$id/status';
  static String adminDeleteRequestEndpoint(String id) => '/admin/requests/$id';
  static const String adminComplaintsEndpoint = '/admin/complaints';
  static String adminComplaintByIdEndpoint(String id) =>
      '/admin/complaints/$id';
  static String adminUpdateComplaintStatusEndpoint(String id) =>
      '/admin/complaints/$id/status';
  static String adminDeleteComplaintEndpoint(String id) =>
      '/admin/complaints/$id';

  // Request endpoints (legacy - keeping for backward compatibility)
  static const String requestsEndpoint = '/admin/requests';
  static const String residentRequestEndpoint = '/resident/request';
  static const String residentRequestStatusEndpoint =
      '/resident/request/status';
  static String requestByIdEndpoint(String id) => '/admin/requests/$id';
  static String updateRequestStatusEndpoint(String id) =>
      '/admin/requests/$id/status';

  // Complaint endpoints (legacy)
  static const String complaintsEndpoint = '/admin/complaints';
  static String complaintByIdEndpoint(String id) => '/admin/complaints/$id';
  static String updateComplaintStatusEndpoint(String id) =>
      '/admin/complaints/$id/status';

  // Document types endpoints
  static const String documentTypesEndpoint = '/document-types';

  // Dashboard endpoints
  static const String dashboardEndpoint = '/admin/dashboard';

  // Analytics endpoints
  static const String analyticsEndpoint = '/analytics';
  static const String weeklyRequestsEndpoint = '/analytics/weekly-requests';
  static const String complaintResolutionEndpoint =
      '/analytics/complaint-resolution';

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
