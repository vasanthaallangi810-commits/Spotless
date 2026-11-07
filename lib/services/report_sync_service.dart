import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/report.dart';

class ReportSyncService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  static String? get currentFirebaseUid => FirebaseAuth.instance.currentUser?.uid;

  static Future<String?> uploadReportImage({
    required int userId,
    required String reportType,
    required Uint8List imageBytes,
  }) async {
    try {
      final uid = currentFirebaseUid;
      if (uid == null || uid.isEmpty) {
        return null;
      }

      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${userId}_${reportType.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_')}.jpg';
      final ref = _storage.ref().child('reports/$uid/$fileName');
      await ref.putData(imageBytes, SettableMetadata(contentType: 'image/jpeg'));
      return await ref.getDownloadURL();
    } catch (e) {
      print('REPORT IMAGE UPLOAD ERROR: $e');
      return null;
    }
  }

  static Future<void> saveReportToCloud({
    required int userId,
    required Report report,
    String? imageUrl,
  }) async {
    try {
      final uid = currentFirebaseUid;
      if (uid == null || uid.isEmpty) {
        return;
      }

      final cloudImageUrl = imageUrl ?? report.imageUrl ?? '';
      final docId = '${DateTime.now().millisecondsSinceEpoch}_$userId';

      await _firestore.collection('reports').doc(docId).set({
        'uid': uid,
        'userId': userId,
        'type': report.type,
        'garbage_type': report.type,
        'description': report.description,
        'latitude': report.latitude,
        'longitude': report.longitude,
        'imagePath': report.imagePath,
        'imageUrl': cloudImageUrl,
        'status': report.status,
        'createdAt': Timestamp.fromDate(report.date),
        'date': report.date.toIso8601String(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('REPORT CLOUD SAVE ERROR: $e');
    }
  }

  static Future<List<Report>> getReportsForUser({
    required int userId,
  }) async {
    try {
      final uid = currentFirebaseUid;
      if (uid == null || uid.isEmpty) {
        return const [];
      }

      final snapshot = await _firestore
          .collection('reports')
          .where('uid', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        final imageUrl = data['imageUrl']?.toString();
        final dateValue = data['createdAt'] is Timestamp
            ? (data['createdAt'] as Timestamp).toDate()
            : DateTime.tryParse(data['date']?.toString() ?? '') ?? DateTime.now();

        return Report(
          type: data['garbage_type']?.toString() ?? data['type']?.toString() ?? 'Unknown',
          description: data['description']?.toString() ?? '',
          latitude: (data['latitude'] is num) ? (data['latitude'] as num).toDouble() : 0.0,
          longitude: (data['longitude'] is num) ? (data['longitude'] as num).toDouble() : 0.0,
          imagePath: data['imagePath']?.toString() ?? '',
          imageUrl: imageUrl,
          status: data['status']?.toString() ?? 'Pending',
          date: dateValue,
        );
      }).toList();
    } catch (e) {
      print('REPORT CLOUD LOAD ERROR: $e');
      return const [];
    }
  }
}
