import '../../../core/network/api_client.dart';
import '../models/field_survey_record.dart';

/// FieldSurveyApiService
/// Communicates with Node.js Express field survey REST API (`/api/v1/field-surveys/*`).
class FieldSurveyApiService {
  final ApiClient _apiClient;

  FieldSurveyApiService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// GET /api/v1/field-surveys
  Future<List<FieldSurveyRecord>> getFieldSurveys({String? status}) async {
    final Map<String, dynamic> queryParams = {};
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }

    final response = await _apiClient.get(
      '/field-surveys',
      queryParameters: queryParams,
    );

    if (response is Map<String, dynamic> && response['data'] is List) {
      final list = response['data'] as List;
      return list
          .map((item) => FieldSurveyRecord.fromBackendJson(item as Map<String, dynamic>))
          .toList();
    } else if (response is List) {
      return response
          .map((item) => FieldSurveyRecord.fromBackendJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// GET /api/v1/field-surveys/:id
  Future<FieldSurveyRecord?> getFieldSurveyById(String id) async {
    final response = await _apiClient.get('/field-surveys/$id');
    if (response is Map<String, dynamic>) {
      final data = response['data'] ?? response;
      if (data is Map<String, dynamic>) {
        return FieldSurveyRecord.fromBackendJson(data);
      }
    }
    return null;
  }

  /// POST /api/v1/field-surveys
  Future<FieldSurveyRecord?> createFieldSurvey(Map<String, dynamic> payload) async {
    final response = await _apiClient.post(
      '/field-surveys',
      data: payload,
    );
    if (response is Map<String, dynamic>) {
      final data = response['data'] ?? response;
      if (data is Map<String, dynamic>) {
        return FieldSurveyRecord.fromBackendJson(data);
      }
    }
    return null;
  }

  /// PATCH /api/v1/field-surveys/:id/approve
  Future<Map<String, dynamic>?> approveFieldSurvey(String id, {String? reviewNotes}) async {
    final response = await _apiClient.patch(
      '/field-surveys/$id/approve',
      data: {
        if (reviewNotes != null && reviewNotes.isNotEmpty) 'reviewNotes': reviewNotes,
      },
    );
    if (response is Map<String, dynamic> && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }
    return null;
  }

  /// PATCH /api/v1/field-surveys/:id/reject
  Future<FieldSurveyRecord?> rejectFieldSurvey(String id, {String? reviewNotes}) async {
    final response = await _apiClient.patch(
      '/field-surveys/$id/reject',
      data: {
        if (reviewNotes != null && reviewNotes.isNotEmpty) 'reviewNotes': reviewNotes,
      },
    );
    if (response is Map<String, dynamic>) {
      final data = response['data'] ?? response;
      if (data is Map<String, dynamic>) {
        return FieldSurveyRecord.fromBackendJson(data);
      }
    }
    return null;
  }
}
