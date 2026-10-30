import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:3000';
  // ================= REGISTER =================

  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
    String phone = '',
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/register'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
              'phone': phone,
            }),
          )
          .timeout(const Duration(seconds: 10));

      print('REGISTER STATUS: ${response.statusCode}');
      print('REGISTER RESPONSE: ${response.body}');

      return jsonDecode(response.body);
    } catch (e) {
      print('REGISTER CONNECTION ERROR: $e');

      return {
        'success': false,
        'message': 'Could not connect to server: $e',
      };
    }
  }

  // ================= LOGIN =================

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/login'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 10));

      print('LOGIN STATUS: ${response.statusCode}');
      print('LOGIN RESPONSE: ${response.body}');

      return jsonDecode(response.body);
    } catch (e) {
      print('LOGIN CONNECTION ERROR: $e');

      return {
        'success': false,
        'message': 'Could not connect to server: $e',
      };
    }
  }

  // Keep this because some screens may still call loginUser()
  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    return login(
      email: email,
      password: password,
    );
  }

  // ================= SUBMIT REPORT =================

  static Future<Map<String, dynamic>> submitReport({
    required int userId,
    required String garbageType,
    required String description,
    required double latitude,
    required double longitude,
    String imagePath = '',
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/reports'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'user_id': userId,
              'garbage_type': garbageType,
              'description': description,
              'latitude': latitude,
              'longitude': longitude,
              'image_path': imagePath,
            }),
          )
          .timeout(const Duration(seconds: 10));

      print('REPORT STATUS: ${response.statusCode}');
      print('REPORT RESPONSE: ${response.body}');

      return jsonDecode(response.body);
    } catch (e) {
      print('REPORT CONNECTION ERROR: $e');

      return {
        'success': false,
        'message': 'Could not connect to server: $e',
      };
    }
  }

  // ================= GET USER REPORTS =================

  static Future<Map<String, dynamic>> getMyReports({
    required int userId,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/reports/$userId'),
          )
          .timeout(const Duration(seconds: 10));

      print('REPORTS STATUS: ${response.statusCode}');
      print('REPORTS RESPONSE: ${response.body}');

      return jsonDecode(response.body);
    } catch (e) {
      print('GET REPORTS CONNECTION ERROR: $e');

      return {
        'success': false,
        'message': 'Could not connect to server: $e',
      };
    }
  }

  // Keep this because some screens may still call getUserReports()
  static Future<Map<String, dynamic>> getUserReports(int userId) async {
    return getMyReports(userId: userId);
  }
}