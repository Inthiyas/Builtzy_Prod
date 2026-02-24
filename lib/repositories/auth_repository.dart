import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/models.dart';

class AuthRepository {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://35.232.29.210';
  final _storage = const FlutterSecureStorage();
  
  String? _token;
  User? _currentUser;

  String? get token => _token;
  User? get currentUser => _currentUser;

  Future<User?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final userData = data['data'];
        _token = userData['token'];
        
        await _storage.write(key: 'jwt_token', value: _token);

        _currentUser = User(
          id: userData['user']['id'].toString(),
          name: userData['user']['username'],
          role: userData['user']['role'] == 'admin' ? UserRole.admin : UserRole.subcontractor,
        );
        return _currentUser;
      } else {
        throw Exception(data['message'] ?? 'Invalid credentials');
      }
    } on http.ClientException {
      throw Exception('Network error. Please try again.');
    } catch (e) {
      if (e.toString().contains('Failed host lookup')) {
        throw Exception('Unable to connect to server');
      }
      rethrow;
    }
  }

  Future<User?> restoreSession() async {
    try {
      final storedToken = await _storage.read(key: 'jwt_token');
      if (storedToken == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/api/users/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $storedToken',
        },
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final userData = data['data'];
        _token = storedToken;
        _currentUser = User(
          id: userData['id'].toString(),
          name: userData['username'],
          role: userData['role'] == 'admin' ? UserRole.admin : UserRole.subcontractor,
        );
        return _currentUser;
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        await logout();
        throw Exception('Session expired. Please login again.');
      } else {
        await logout();
        return null; // Silent failure for common restoration
      }
    } catch (e) {
      await logout();
      return null;
    }
  }

  Future<void> logout() async {
    _token = null;
    _currentUser = null;
    await _storage.delete(key: 'jwt_token');
  }
}
