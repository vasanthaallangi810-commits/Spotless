import 'dart:typed_data';

class Report {
  final String type;
  final String description;

  final double latitude;
  final double longitude;

  final String imagePath;

  // Image data used by the Reports/Details screens
  final Uint8List? imageBytes;

  // Cloud image URL used for persisted cross-device visibility.
  final String? imageUrl;

  final String status;
  final DateTime date;

  Report({
    required this.type,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.imagePath,
    this.imageBytes,
    this.imageUrl,
    required this.status,
    required this.date,
  });

  // ============================================================
  // COMPATIBILITY GETTERS
  // ============================================================
  //
  // These allow the existing screens to continue using the
  // original names without us having to rewrite them.
  //

  String get garbageType => type;

  String get location =>
      '${latitude.toStringAsFixed(5)}, '
      '${longitude.toStringAsFixed(5)}';
}