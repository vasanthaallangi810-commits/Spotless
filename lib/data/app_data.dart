import 'package:shared_preferences/shared_preferences.dart';

import '../database/database_helper.dart';
import '../models/report.dart';

class AppData {
  static int? userId;
  static String? firebaseUid;
  static String userName = "Vasantha";
  static final List<Report> reports = [];

  static Future<void> clearSession() async {
    userId = null;
    firebaseUid = null;
    reports.clear();
    userName = 'Vasantha';

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('firebase_uid');
  }

  static Future<void> loadSavedReports({int? forUserId}) async {
    reports.clear();

    final targetUserId = forUserId ?? userId;
    final savedReports = targetUserId == null
        ? <Report>[]
        : await DatabaseHelper.instance.getReports(userId: targetUserId);

    reports.addAll(savedReports);
  }
}