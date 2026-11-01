import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _baseUrlPreferenceKey = 'api_base_url';

  static String get baseUrl {
    const envBaseUrl = String.fromEnvironment('API_BASE_URL');
    if (envBaseUrl.isNotEmpty) {
      return _normalizeBaseUrl(envBaseUrl);
    }

    if (kIsWeb) {
      return 'http://localhost:3000';
    }

    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    }

    if (Platform.isIOS) {
      return 'http://localhost:3000';
    }

    return 'http://127.0.0.1:3000';
  }

  static Future<String> getBaseUrl() async {
    const envBaseUrl = String.fromEnvironment('API_BASE_URL');
    if (envBaseUrl.isNotEmpty) {
      return _normalizeBaseUrl(envBaseUrl);
    }

    final savedBaseUrl = await _readSavedBaseUrl();
    if (savedBaseUrl != null && savedBaseUrl.isNotEmpty) {
      return _normalizeBaseUrl(savedBaseUrl);
    }

    if (kIsWeb) {
      return 'http://localhost:3000';
    }

    if (Platform.isAndroid) {
      final detectedLanUrl = await _detectLanBaseUrl();
      if (detectedLanUrl != null) {
        return detectedLanUrl;
      }
      return 'http://10.0.2.2:3000';
    }

    if (Platform.isIOS) {
      return 'http://localhost:3000';
    }

    return 'http://127.0.0.1:3000';
  }

  static Future<void> setBaseUrl(String newBaseUrl) async {
    final normalizedUrl = _normalizeBaseUrl(newBaseUrl);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_baseUrlPreferenceKey, normalizedUrl);
  }

  static Future<void> clearBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_baseUrlPreferenceKey);
  }

  static String _normalizeBaseUrl(String rawUrl) {
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) {
      return 'http://localhost:3000';
    }
    return trimmed.replaceAll(RegExp(r'\/$'), '');
  }

  static Future<String?> _readSavedBaseUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedBaseUrl = prefs.getString(_baseUrlPreferenceKey);
      if (savedBaseUrl == null || savedBaseUrl.trim().isEmpty) {
        return null;
      }
      return savedBaseUrl.trim();
    } catch (_) {
      return null;
    }
  }

  static Future<String?> _detectLanBaseUrl() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
      );

      final lanIps = <String>[];
      for (final interface in interfaces) {
        for (final address in interface.addresses) {
          final ip = address.address;
          if (ip.startsWith('127.') ||
              ip.startsWith('169.254.') ||
              ip.startsWith('0.')) {
            continue;
          }

          if (ip.startsWith('192.168.') ||
              ip.startsWith('10.') ||
              ip.startsWith('172.')) {
            lanIps.add(ip);
          }
        }
      }

      if (lanIps.isEmpty) {
        return null;
      }

      final preferredLanIp = lanIps.firstWhere(
        (ip) => !ip.startsWith('10.0.2.'),
        orElse: () => lanIps.first,
      );

      return 'http://$preferredLanIp:3000';
    } catch (_) {
      return null;
    }
  }

  // ================= REGISTER =================

  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
    String phone = '',
  }) async {
    try {
      final baseUrl = await getBaseUrl();
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
      final baseUrl = await getBaseUrl();
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
      final baseUrl = await getBaseUrl();
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
      final baseUrl = await getBaseUrl();
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