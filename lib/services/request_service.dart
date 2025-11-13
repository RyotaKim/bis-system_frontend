import 'dart:io';
import '../config/api_config.dart';
import 'api_service.dart';

/// Request Service for managing document requests
class RequestService {
  final _api = ApiService();

  /// Get all requests
  Future<List<dynamic>> getRequests() async {
    try {
      final response = await _api.get(ApiConfig.requestsEndpoint);
      return response['requests'] ?? response;
    } catch (e) {
      throw Exception('Failed to fetch requests: $e');
    }
  }

  /// Get request by ID
  Future<Map<String, dynamic>> getRequestById(String id) async {
    try {
      final response = await _api.get(ApiConfig.requestByIdEndpoint(id));
      return response['request'] ?? response;
    } catch (e) {
      throw Exception('Failed to fetch request: $e');
    }
  }

  /// Get request by reference number
  Future<Map<String, dynamic>> getRequestByRefNo(String refNo) async {
    try {
      final response = await _api
          .get('${ApiConfig.requestsEndpoint}?ref=$refNo', requiresAuth: false);
      final requests = response['requests'] ?? response;
      if (requests is List && requests.isNotEmpty) {
        return requests[0];
      }
      throw Exception('Request not found');
    } catch (e) {
      throw Exception('Failed to fetch request: $e');
    }
  }

  /// Create new request
  Future<Map<String, dynamic>> createRequest(
      Map<String, dynamic> requestData) async {
    try {
      final response = await _api.post(
        ApiConfig.requestsEndpoint,
        requestData,
        requiresAuth: false,
      );
      return response['request'] ?? response;
    } catch (e) {
      throw Exception('Failed to create request: $e');
    }
  }

  /// Create new request with image upload (for residents)
  Future<Map<String, dynamic>> createRequestWithImage({
    required String fullName,
    required String contactNumber,
    required String address,
    required String purpose,
    required int age,
    required String docTypeId,
    File? idImage,
    List<int>? idImageBytes,
    String? idImageName,
    String? eduAttainment,
    String? eduCourse,
    String? maritalStatus,
  }) async {
    try {
      // Prepare form fields
      final fields = {
        'fullName': fullName,
        'contactNumber': contactNumber,
        'address': address,
        'purpose': purpose,
        'age': age.toString(),
        'docTypeId': docTypeId,
      };

      // Add optional fields
      if (eduAttainment != null && eduAttainment.isNotEmpty) {
        fields['eduAttainment'] = eduAttainment;
      }
      if (eduCourse != null && eduCourse.isNotEmpty) {
        fields['eduCourse'] = eduCourse;
      }
      if (maritalStatus != null && maritalStatus.isNotEmpty) {
        fields['maritalStatus'] = maritalStatus;
      }

      // Make multipart request (use bytes for web, File for mobile)
      final response = idImageBytes != null
          ? await _api.postMultipartWithBytes(
              ApiConfig.residentRequestEndpoint,
              fields,
              idImageBytes,
              idImageName ?? 'image.jpg',
              requiresAuth: false,
            )
          : await _api.postMultipart(
              ApiConfig.residentRequestEndpoint,
              fields,
              idImage,
              requiresAuth: false,
            );

      return response;
    } catch (e) {
      throw Exception('Failed to create request: $e');
    }
  }

  /// Update request status
  Future<Map<String, dynamic>> updateRequestStatus(
      String id, String status) async {
    try {
      final response = await _api.patch(
        ApiConfig.updateRequestStatusEndpoint(id),
        {'status': status},
      );
      return response['request'] ?? response;
    } catch (e) {
      throw Exception('Failed to update request status: $e');
    }
  }

  /// Delete request
  Future<void> deleteRequest(String id) async {
    try {
      await _api.delete(ApiConfig.requestByIdEndpoint(id));
    } catch (e) {
      throw Exception('Failed to delete request: $e');
    }
  }

  /// Get document types
  Future<List<dynamic>> getDocumentTypes() async {
    try {
      final response =
          await _api.get(ApiConfig.documentTypesEndpoint, requiresAuth: false);
      // Backend returns 'docTypes' not 'documentTypes'
      return response['docTypes'] ?? response['documentTypes'] ?? response;
    } catch (e) {
      throw Exception('Failed to fetch document types: $e');
    }
  }
}
