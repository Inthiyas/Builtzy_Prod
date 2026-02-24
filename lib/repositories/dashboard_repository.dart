import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/models.dart';
import 'auth_repository.dart';

class DashboardMetrics {
  final int totalManpower;
  final int presentManpower;
  final int absentManpower;
  
  final int totalEquipment;
  final int deployedEquipment;
  final int underRepairEquipment;

  const DashboardMetrics({
    this.totalManpower = 0,
    this.presentManpower = 0,
    this.absentManpower = 0,
    this.totalEquipment = 0,
    this.deployedEquipment = 0,
    this.underRepairEquipment = 0,
  });

  factory DashboardMetrics.fromJson(Map<String, dynamic> json) {
    return DashboardMetrics(
      totalManpower: json['totalManpower'] ?? 0,
      presentManpower: json['presentManpower'] ?? 0,
      absentManpower: json['absentManpower'] ?? 0,
      totalEquipment: json['totalEquipment'] ?? 0,
      deployedEquipment: json['deployedEquipment'] ?? 0,
      underRepairEquipment: json['underRepairEquipment'] ?? 0,
    );
  }
}

class DashboardRepository {
  final AuthRepository _authRepository;
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://35.232.29.210';

  DashboardRepository(this._authRepository);

  Future<DashboardMetrics> getMetrics(UserRole role) async {
    final token = _authRepository.token;
    if (token == null) throw Exception('No auth token');

    final endpoint = '/api/dashboard/metrics';
    
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return DashboardMetrics.fromJson(data['data']);
    }
    throw Exception(data['message'] ?? 'Failed to load dashboard metrics');
  }
}
