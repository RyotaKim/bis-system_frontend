import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../config/api_config.dart';
import 'storage_service.dart';

/// Main API Service for handling all backend communication
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final _storage = StorageService();

  /// Make GET request
  Future<dynamic> get(String endpoint, {bool requiresAuth = true}) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = requiresAuth
          ? ApiConfig.headersWithAuth(_storage.getToken() ?? '')
          : ApiConfig.headers;

      final response =
          await http.get(url, headers: headers).timeout(ApiConfig.timeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Make POST request
  Future<dynamic> post(String endpoint, dynamic body,
      {bool requiresAuth = true}) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = requiresAuth
          ? ApiConfig.headersWithAuth(_storage.getToken() ?? '')
          : ApiConfig.headers;

      final response = await http
          .post(url, headers: headers, body: jsonEncode(body))
          .timeout(ApiConfig.timeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Make PUT request
  Future<dynamic> put(String endpoint, dynamic body,
      {bool requiresAuth = true}) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = requiresAuth
          ? ApiConfig.headersWithAuth(_storage.getToken() ?? '')
          : ApiConfig.headers;

      final response = await http
          .put(url, headers: headers, body: jsonEncode(body))
          .timeout(ApiConfig.timeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Make PATCH request
  Future<dynamic> patch(String endpoint, dynamic body,
      {bool requiresAuth = true}) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = requiresAuth
          ? ApiConfig.headersWithAuth(_storage.getToken() ?? '')
          : ApiConfig.headers;

      final response = await http
          .patch(url, headers: headers, body: jsonEncode(body))
          .timeout(ApiConfig.timeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Make DELETE request
  Future<dynamic> delete(String endpoint, {bool requiresAuth = true}) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = requiresAuth
          ? ApiConfig.headersWithAuth(_storage.getToken() ?? '')
          : ApiConfig.headers;

      final response =
          await http.delete(url, headers: headers).timeout(ApiConfig.timeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Make multipart request (for file uploads)
  Future<dynamic> postMultipart(
    String endpoint,
    Map<String, String> fields,
    File? imageFile, {
    bool requiresAuth = false,
    String fileFieldName = 'idImage',
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final request = http.MultipartRequest('POST', url);

      // Add headers
      if (requiresAuth) {
        final token = _storage.getToken();
        if (token != null && token.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer $token';
        }
      }

      // Add text fields
      request.fields.addAll(fields);

      // Add image file if provided
      if (imageFile != null) {
        final mimeType = _getMimeType(imageFile.path);
        request.files.add(
          await http.MultipartFile.fromPath(
            fileFieldName,
            imageFile.path,
            contentType: MediaType.parse(mimeType),
          ),
        );
      }

      // Send request
      final streamedResponse = await request.send().timeout(ApiConfig.timeout);
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Make multipart request with bytes (for web uploads)
  Future<dynamic> postMultipartWithBytes(
    String endpoint,
    Map<String, String> fields,
    List<int>? imageBytes,
    String fileName, {
    bool requiresAuth = false,
    String fileFieldName = 'idImage',
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final request = http.MultipartRequest('POST', url);

      // Add headers
      if (requiresAuth) {
        final token = _storage.getToken();
        if (token != null && token.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer $token';
        }
      }

      // Add text fields
      request.fields.addAll(fields);

      // Add image bytes if provided
      if (imageBytes != null) {
        final mimeType = _getMimeType(fileName);
        request.files.add(
          http.MultipartFile.fromBytes(
            fileFieldName,
            imageBytes,
            filename: fileName,
            contentType: MediaType.parse(mimeType),
          ),
        );
      }

      // Send request
      final streamedResponse = await request.send().timeout(ApiConfig.timeout);
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get MIME type from file extension
  String _getMimeType(String path) {
    final ext = path.toLowerCase().split('.').last;
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  /// Handle HTTP response
  dynamic _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        if (response.body.isEmpty) {
          return {'success': true};
        }
        return jsonDecode(response.body);
      case 204:
        return {'success': true};
      case 400:
        throw Exception('Bad Request: ${_getErrorMessage(response)}');
      case 401:
        throw Exception('Unauthorized: ${_getErrorMessage(response)}');
      case 403:
        throw Exception('Forbidden: ${_getErrorMessage(response)}');
      case 404:
        throw Exception('Not Found: ${_getErrorMessage(response)}');
      case 500:
        throw Exception('Internal Server Error: ${_getErrorMessage(response)}');
      default:
        throw Exception(
            'Error ${response.statusCode}: ${_getErrorMessage(response)}');
    }
  }

  /// Extract error message from response
  String _getErrorMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      return body['message'] ?? body['error'] ?? 'Unknown error';
    } catch (e) {
      return response.body.isNotEmpty ? response.body : 'Unknown error';
    }
  }

  /// Handle errors
  String _handleError(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return error.toString();
  }
}
