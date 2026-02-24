import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class AuthRepository {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://35.232.29.210';
  
  String? _token;
  User? _currentUser;

  String? get token => _token;
  User? get currentUser => _currentUser;

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
    _token = token;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt_token');
    return _token;
  }

  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    _token = null;
    _currentUser = null;
  }

  Future<User?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final userData = data['data'];
        final token = userData['token'];
        
        await saveToken(token);

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

  Future<User?> getCurrentUser(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final userData = data['data'];
        _currentUser = User(
          id: userData['id'].toString(),
          name: userData['username'],
          role: userData['role'] == 'admin' ? UserRole.admin : UserRole.subcontractor,
        );
        return _currentUser;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<User?> restoreSession() async {
    final storedToken = await getToken();
    if (storedToken == null) return null;
    
    final user = await getCurrentUser(storedToken);
    if (user == null) {
      await deleteToken();
    }
    return user;
  }

  Future<void> logout() async {
    await deleteToken();
  }
}
