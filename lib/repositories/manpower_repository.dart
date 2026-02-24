import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/models.dart';
import '../providers/filter_providers.dart';
import 'auth_repository.dart';

class ManpowerRepository {
  final AuthRepository _authRepository;
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://35.232.29.210';

  ManpowerRepository(this._authRepository);

  Map<String, String> get _headers {
    final token = _authRepository.token;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<ManpowerEntry>> getAllManpower({String? subcontractorId, FilterState? filter}) async {
    final queryParams = <String, String>{};
    
    if (subcontractorId != null) queryParams['subcontractorId'] = subcontractorId;
    if (filter != null) {
      if (filter.search.isNotEmpty) queryParams['search'] = filter.search;
      if (filter.status != 'all') queryParams['approval_status'] = filter.status;
      if (filter.status2 != 'all') queryParams['attendance_status'] = filter.status2;
    }

    final uri = Uri.parse('$baseUrl/manpower').replace(
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    final response = await http.get(uri, headers: _headers);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      final List<dynamic> list = data['data'];
      return list.map((json) => _fromJson(json)).toList();
    }
    throw Exception(data['message'] ?? 'Failed to load manpower');
  }

  Future<ManpowerEntry> createManpower(String name) async {
    final response = await http.post(
      Uri.parse('$baseUrl/manpower'),
      headers: _headers,
      body: jsonEncode({'name': name}),
    );
    final data = jsonDecode(response.body);

    if (response.statusCode == 201 && data['success'] == true) {
      return _fromJson(data['data']);
    }
    throw Exception(data['message'] ?? 'Failed to create manpower');
  }

  Future<void> updateApproval(String id, ApprovalStatus status) async {
    final statusStr = status == ApprovalStatus.approved ? 'approve' : 'reject';
    final response = await http.put(
      Uri.parse('$baseUrl/manpower/$id/$statusStr'),
      headers: _headers,
    );
    final data = jsonDecode(response.body);

    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Failed to update approval');
    }
  }

  Future<void> updateAttendance(String id, AttendanceStatus status) async {
    final statusStr = status == AttendanceStatus.present ? 'present' : 'absent';
    final response = await http.put(
      Uri.parse('$baseUrl/manpower/$id/attendance'),
      headers: _headers,
      body: jsonEncode({'status': statusStr}),
    );
    final data = jsonDecode(response.body);

    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Failed to update attendance');
    }
  }

  ManpowerEntry _fromJson(Map<String, dynamic> json) {
    return ManpowerEntry(
      id: json['id'],
      subcontractorId: json['subcontractorId'],
      name: json['name'],
      approvalStatus: _parseApprovalStatus(json['approvalStatus']),
      attendanceStatus: _parseAttendanceStatus(json['attendanceStatus']),
      date: DateTime.parse(json['date']),
    );
  }

  ApprovalStatus _parseApprovalStatus(String status) {
    switch (status) {
      case 'approved': return ApprovalStatus.approved;
      case 'rejected': return ApprovalStatus.rejected;
      default: return ApprovalStatus.pending;
    }
  }

  AttendanceStatus _parseAttendanceStatus(String status) {
    switch (status) {
      case 'present': return AttendanceStatus.present;
      case 'absent': return AttendanceStatus.absent;
      default: return AttendanceStatus.notMarked;
    }
  }
}
