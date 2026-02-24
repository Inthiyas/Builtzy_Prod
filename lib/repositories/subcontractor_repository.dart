import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/models.dart';
import '../providers/filter_providers.dart';
import 'auth_repository.dart';

class SubcontractorRepository {
  final AuthRepository _authRepository;
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://35.232.29.210';

  SubcontractorRepository(this._authRepository);

  Future<List<Subcontractor>> getSubcontractors({SubcontractorFilter? filter}) async {
    final token = _authRepository.token;
    if (token == null) return [];

    final queryParams = <String, String>{};
    if (filter != null) {
      if (filter.search.isNotEmpty) queryParams['search'] = filter.search;
      
      if (filter.manpowerRange != 'all') {
        final parts = filter.manpowerRange.split('-');
        if (parts.length == 2) {
          queryParams['min_manpower'] = parts[0];
          queryParams['max_manpower'] = parts[1];
        } else if (filter.manpowerRange == '51+') {
          queryParams['min_manpower'] = '51';
        }
      }
      
      if (filter.equipmentRange != 'all') {
        final parts = filter.equipmentRange.split('-');
        if (parts.length == 2) {
          queryParams['min_equipment'] = parts[0];
          queryParams['max_equipment'] = parts[1];
        } else if (filter.equipmentRange == '51+') {
          queryParams['min_equipment'] = '51';
        }
      }
    }

    final uri = Uri.parse('$baseUrl/api/subcontractors').replace(
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      final List list = data['data'];
      return list.map((e) => Subcontractor.fromJson(e)).toList();
    }
    throw Exception(data['message'] ?? 'Failed to load subcontractors');
  }

  Future<Subcontractor> createSubcontractor({
    required String username,
    required String password,
    required String companyName,
    required String contactPerson,
    required String phoneNumber,
  }) async {
    final token = _authRepository.token;
    final response = await http.post(
      Uri.parse('$baseUrl/api/subcontractors'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'username': username,
        'password': password,
        'companyName': companyName,
        'contactPerson': contactPerson,
        'phoneNumber': phoneNumber,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201 && data['success'] == true) {
      return Subcontractor.fromJson(data['data']);
    }
    throw Exception(data['message'] ?? 'Failed to create subcontractor');
  }

  Future<Subcontractor> updateSubcontractor(String id, {
    required String companyName,
    required String contactPerson,
    required String phoneNumber,
  }) async {
    final token = _authRepository.token;
    final response = await http.put(
      Uri.parse('$baseUrl/api/subcontractors/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'companyName': companyName,
        'contactPerson': contactPerson,
        'phoneNumber': phoneNumber,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return Subcontractor.fromJson(data['data']);
    }
    throw Exception(data['message'] ?? 'Failed to update subcontractor');
  }

  Future<void> deleteSubcontractor(String id) async {
    final token = _authRepository.token;
    final response = await http.delete(
      Uri.parse('$baseUrl/api/subcontractors/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Failed to delete subcontractor');
    }
  }
}
