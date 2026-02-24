import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/models.dart';
import '../providers/filter_providers.dart';
import 'auth_repository.dart';

class EquipmentRepository {
  final AuthRepository _authRepository;
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://35.232.29.210';

  EquipmentRepository(this._authRepository);

  Map<String, String> get _headers {
    final token = _authRepository.token;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<EquipmentEntry>> getAllEquipment({String? subcontractorId, FilterState? filter}) async {
    final queryParams = <String, String>{};
    
    if (subcontractorId != null) queryParams['subcontractorId'] = subcontractorId;
    if (filter != null) {
      if (filter.search.isNotEmpty) queryParams['search'] = filter.search;
      if (filter.status != 'all') queryParams['approval_status'] = filter.status;
      if (filter.status2 != 'all') queryParams['deployment_status'] = filter.status2;
    }

    final uri = Uri.parse('$baseUrl/equipment').replace(
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    final response = await http.get(uri, headers: _headers);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      final List<dynamic> list = data['data'];
      return list.map((json) => _fromJson(json)).toList();
    }
    throw Exception(data['message'] ?? 'Failed to load equipment');
  }

  Future<EquipmentEntry> createEquipment(String name, String type) async {
    final response = await http.post(
      Uri.parse('$baseUrl/equipment'),
      headers: _headers,
      body: jsonEncode({'name': name, 'type': type}),
    );
    final data = jsonDecode(response.body);

    if (response.statusCode == 201 && data['success'] == true) {
      return _fromJson(data['data']);
    }
    throw Exception(data['message'] ?? 'Failed to create equipment');
  }

  Future<void> updateApproval(String id, ApprovalStatus status) async {
    final statusStr = status == ApprovalStatus.approved ? 'approve' : 'reject';
    final response = await http.put(
      Uri.parse('$baseUrl/equipment/$id/$statusStr'),
      headers: _headers,
    );
    final data = jsonDecode(response.body);

    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Failed to update equipment approval');
    }
  }

  Future<void> updateStatus(String id, DeploymentStatus status) async {
    String statusStr;
    switch (status) {
      case DeploymentStatus.deployed: statusStr = 'deployed'; break;
      case DeploymentStatus.underRepair: statusStr = 'under_repair'; break;
      default: statusStr = 'non_deployed'; break;
    }

    final response = await http.put(
      Uri.parse('$baseUrl/equipment/$id/status'),
      headers: _headers,
      body: jsonEncode({'status': statusStr}),
    );
    final data = jsonDecode(response.body);

    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Failed to update equipment status');
    }
  }

  EquipmentEntry _fromJson(Map<String, dynamic> json) {
    return EquipmentEntry(
      id: json['id'],
      subcontractorId: json['subcontractorId'],
      name: json['name'],
      type: json['type'],
      approvalStatus: _parseApprovalStatus(json['approvalStatus']),
      deploymentStatus: _parseDeploymentStatus(json['deploymentStatus']),
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

  DeploymentStatus _parseDeploymentStatus(String status) {
    switch (status) {
      case 'deployed': return DeploymentStatus.deployed;
      case 'under_repair': return DeploymentStatus.underRepair;
      default: return DeploymentStatus.nonDeployed;
    }
  }
}
