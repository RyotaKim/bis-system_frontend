import '../config/api_config.dart';
import 'api_service.dart';

/// Complaint Service for managing complaints
class ComplaintService {
  final _api = ApiService();

  /// Get all complaints
  Future<List<dynamic>> getComplaints() async {
    try {
      final response = await _api.get(ApiConfig.complaintsEndpoint);
      return response['complaints'] ?? response;
    } catch (e) {
      throw Exception('Failed to fetch complaints: $e');
    }
  }

  /// Get complaint by ID
  Future<Map<String, dynamic>> getComplaintById(String id) async {
    try {
      final response = await _api.get(ApiConfig.complaintByIdEndpoint(id));
      return response['complaint'] ?? response;
    } catch (e) {
      throw Exception('Failed to fetch complaint: $e');
    }
  }

  /// Create new complaint
  Future<Map<String, dynamic>> createComplaint(
      Map<String, dynamic> complaintData) async {
    try {
      final response = await _api.post(
        ApiConfig.complaintsEndpoint,
        complaintData,
      );
      return response['complaint'] ?? response;
    } catch (e) {
      throw Exception('Failed to create complaint: $e');
    }
  }

  /// Update complaint status
  Future<Map<String, dynamic>> updateComplaintStatus(
      String id, String status) async {
    try {
      final response = await _api.patch(
        ApiConfig.updateComplaintStatusEndpoint(id),
        {'status': status},
      );
      return response['complaint'] ?? response;
    } catch (e) {
      throw Exception('Failed to update complaint status: $e');
    }
  }

  /// Delete complaint
  Future<void> deleteComplaint(String id) async {
    try {
      await _api.delete(ApiConfig.complaintByIdEndpoint(id));
    } catch (e) {
      throw Exception('Failed to delete complaint: $e');
    }
  }
}
