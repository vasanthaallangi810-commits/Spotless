import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../data/app_data.dart';
import '../database/database_helper.dart';
import '../models/report.dart';
import '../services/api_service.dart';
import '../services/report_sync_service.dart';

class ReportGarbageScreen extends StatefulWidget {
  const ReportGarbageScreen({super.key});

  @override
  State<ReportGarbageScreen> createState() =>
      _ReportGarbageScreenState();
}

class _ReportGarbageScreenState
    extends State<ReportGarbageScreen> {
  final ImagePicker picker = ImagePicker();

  final TextEditingController descriptionController =
      TextEditingController();

  final MapController mapController = MapController();

  String selectedType = 'Plastic';

  XFile? selectedImage;

  LatLng selectedLocation =
      const LatLng(20.5937, 78.9629);

  bool gettingLocation = false;
  bool submitting = false;

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  // ============================================================
  // PICK IMAGE
  // ============================================================

  Future<void> pickImage(ImageSource source) async {
    try {
      final image = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          selectedImage = image;
        });
      }
    } catch (e) {
      _showMessage('Could not select image.');
    }
  }

  // ============================================================
  // GET CURRENT LOCATION
  // ============================================================

  Future<void> getCurrentLocation() async {
    setState(() {
      gettingLocation = true;
    });

    try {
      final serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        _showMessage(
          'Please turn on location services.',
        );

        setState(() {
          gettingLocation = false;
        });

        return;
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission =
            await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showMessage(
          'Location permission is required.',
        );

        setState(() {
          gettingLocation = false;
        });

        return;
      }

      final position =
          await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final newLocation = LatLng(
        position.latitude,
        position.longitude,
      );

      setState(() {
        selectedLocation = newLocation;
        gettingLocation = false;
      });

      mapController.move(
        newLocation,
        17,
      );
    } catch (e) {
      setState(() {
        gettingLocation = false;
      });

      _showMessage(
        'Could not get your location.',
      );
    }
  }

  // ============================================================
  // SUBMIT REPORT TO NODE.JS → MYSQL
  // ============================================================

  Future<void> submitReport() async {
    // Check description
    if (descriptionController.text.trim().isEmpty) {
      _showMessage(
        'Please describe the garbage problem.',
      );
      return;
    }

    // IMPORTANT:
    // Get the logged-in user's ID directly from AppData.
    // LoginScreen stores it here after successful login.
    final int? userId = AppData.userId;

    if (userId == null) {
      _showMessage(
        'User session not found. Please login again.',
      );
      return;
    }

    setState(() {
      submitting = true;
    });

    try {
      // Get image path
      String imagePath = '';

      if (selectedImage != null) {
        imagePath = selectedImage!.path;
      }

      debugPrint('==============================');
      debugPrint('SUBMITTING REPORT');
      debugPrint('User ID: $userId');
      debugPrint('Type: $selectedType');
      debugPrint(
        'Description: ${descriptionController.text.trim()}',
      );
      debugPrint(
        'Latitude: ${selectedLocation.latitude}',
      );
      debugPrint(
        'Longitude: ${selectedLocation.longitude}',
      );
      debugPrint('Image: $imagePath');
      debugPrint('==============================');

      // Send report to Node.js → MySQL
      final result = await ApiService.submitReport(
        userId: userId,
        garbageType: selectedType,
        description:
            descriptionController.text.trim(),
        latitude: selectedLocation.latitude,
        longitude: selectedLocation.longitude,
        imagePath: imagePath,
      );

      if (!mounted) return;

      debugPrint('API RESPONSE: $result');

      Uint8List? imageBytes;

      if (selectedImage != null) {
        imageBytes = await selectedImage!.readAsBytes();
      }

      String? imageUrl;
      if (imageBytes != null) {
        imageUrl = await ReportSyncService.uploadReportImage(
          userId: userId,
          reportType: selectedType,
          imageBytes: imageBytes,
        );
      }

      final report = Report(
        type: selectedType,
        description: descriptionController.text.trim(),
        latitude: selectedLocation.latitude,
        longitude: selectedLocation.longitude,
        imagePath: imagePath,
        imageBytes: imageBytes,
        imageUrl: imageUrl,
        status: 'Pending',
        date: DateTime.now(),
      );

      AppData.reports.add(report);
      await DatabaseHelper.instance.insertReport(
        userId: userId,
        type: selectedType,
        description: descriptionController.text.trim(),
        latitude: selectedLocation.latitude,
        longitude: selectedLocation.longitude,
        imagePath: imagePath,
        imageUrl: imageUrl,
        imageBytes: imageBytes,
        status: 'Pending',
        date: DateTime.now(),
      );

      await ReportSyncService.saveReportToCloud(
        userId: userId,
        report: report,
        imageUrl: imageUrl,
      );

      if (result['success'] == true) {
        _showMessage(
          'Report submitted successfully! 🌿',
        );

        await Future.delayed(
          const Duration(milliseconds: 500),
        );

        if (!mounted) return;

        Navigator.pop(context);
      } else {
        _showMessage(
          result['message'] ??
              'Report submitted locally. Server sync may still be pending.',
        );
      }
    } catch (e) {
      debugPrint('REPORT API ERROR: $e');

      if (!mounted) return;

      _showMessage(
        'Could not connect to the server.',
      );
    } finally {
      if (mounted) {
        setState(() {
          submitting = false;
        });
      }
    }
  }

  // ============================================================
  // SHOW MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF7F4D5),

      appBar: AppBar(
        title: const Text(
          'Report Garbage',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor:
            const Color(0xFF0A3323),
        foregroundColor:
            const Color(0xFFF7F4D5),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // ==================================================
            // IMAGE
            // ==================================================

            const Text(
              'Add a photo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A3323),
              ),
            ),

            const SizedBox(height: 12),

            Container(
              height: 180,
              width: double.infinity,

              decoration: BoxDecoration(
                color: const Color(0xFF839958)
                    .withValues(alpha: 0.18),

                borderRadius:
                    BorderRadius.circular(20),

                border: Border.all(
                  color:
                      const Color(0xFF839958),
                ),
              ),

              child: selectedImage == null
                  ? Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,

                      children: [

                        const Icon(
                          Icons.camera_alt_outlined,
                          size: 50,
                          color:
                              Color(0xFF0A3323),
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,

                          children: [

                            ElevatedButton.icon(
                              onPressed: () =>
                                  pickImage(
                                ImageSource.camera,
                              ),

                              icon:
                                  const Icon(
                                Icons.camera_alt,
                              ),

                              label:
                                  const Text(
                                'Camera',
                              ),
                            ),

                            const SizedBox(
                              width: 12,
                            ),

                            OutlinedButton.icon(
                              onPressed: () =>
                                  pickImage(
                                ImageSource.gallery,
                              ),

                              icon:
                                  const Icon(
                                Icons.photo,
                              ),

                              label:
                                  const Text(
                                'Gallery',
                              ),
                            ),
                          ],
                        ),
                      ],
                    )

                  : FutureBuilder<Uint8List>(
                      future:
                          selectedImage!
                              .readAsBytes(),

                      builder: (
                        context,
                        snapshot,
                      ) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child:
                                CircularProgressIndicator(),
                          );
                        }

                        return ClipRRect(
                          borderRadius:
                              BorderRadius.circular(
                            20,
                          ),

                          child: Image.memory(
                            snapshot.data!,
                            fit: BoxFit.cover,
                            width:
                                double.infinity,
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 30),

            // ==================================================
            // GARBAGE TYPE
            // ==================================================

            const Text(
              'Garbage type',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A3323),
              ),
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              initialValue: selectedType,

              decoration:
                  InputDecoration(
                filled: true,

                fillColor:
                    Colors.white
                        .withValues(alpha: 0.75),

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),

                  borderSide:
                      BorderSide.none,
                ),
              ),

              items: const [

                DropdownMenuItem(
                  value: 'Plastic',
                  child: Text('Plastic'),
                ),

                DropdownMenuItem(
                  value: 'Food Waste',
                  child:
                      Text('Food Waste'),
                ),

                DropdownMenuItem(
                  value: 'Paper',
                  child: Text('Paper'),
                ),

                DropdownMenuItem(
                  value:
                      'Electronic Waste',
                  child:
                      Text('Electronic Waste'),
                ),

                DropdownMenuItem(
                  value:
                      'Construction Waste',
                  child:
                      Text('Construction Waste'),
                ),

                DropdownMenuItem(
                  value: 'Other',
                  child: Text('Other'),
                ),
              ],

              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedType = value;
                  });
                }
              },
            ),

            const SizedBox(height: 30),

            // ==================================================
            // DESCRIPTION
            // ==================================================

            const Text(
              'Describe the problem',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A3323),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller:
                  descriptionController,

              maxLines: 4,

              decoration:
                  InputDecoration(
                hintText:
                    'Example: Garbage has been dumped near the road...',

                filled: true,

                fillColor:
                    Colors.white
                        .withValues(alpha: 0.75),

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),

                  borderSide:
                      BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ==================================================
            // LOCATION
            // ==================================================

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

              children: [

                const Text(
                  'Location',

                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Color(0xFF0A3323),
                  ),
                ),

                TextButton.icon(
                  onPressed:
                      gettingLocation
                          ? null
                          : getCurrentLocation,

                  icon: gettingLocation
                      ? const SizedBox(
                          width: 16,
                          height: 16,

                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )

                      : const Icon(
                          Icons.my_location,
                        ),

                  label:
                      const Text(
                    'Use my location',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ==================================================
            // MAP
            // ==================================================

            Container(
              height: 320,
              width: double.infinity,

              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(22),

                boxShadow: [

                  BoxShadow(
                    color: Colors.black
                        .withValues(alpha: 0.15),

                    blurRadius: 15,

                    offset:
                        const Offset(0, 5),
                  ),
                ],
              ),

              clipBehavior:
                  Clip.antiAlias,

              child: FlutterMap(
                mapController:
                    mapController,

                options: MapOptions(
                  initialCenter:
                      selectedLocation,

                  initialZoom: 5.5,

                  onTap:
                      (_, point) {

                    setState(() {
                      selectedLocation =
                          point;
                    });
                  },
                ),

                children: [

                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',

                    userAgentPackageName:
                        'com.spotless.app',

                    maxZoom: 19,
                  ),

                  MarkerLayer(
                    markers: [

                      Marker(
                        point:
                            selectedLocation,

                        width: 55,
                        height: 55,

                        child:
                            const Icon(
                          Icons.location_pin,

                          size: 55,

                          color:
                              Color(0xFFD3968C),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Tap anywhere on the map to select the garbage location.',

              style: TextStyle(
                fontSize: 13,

                color: Colors.black
                    .withValues(alpha: 0.6),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Latitude: ${selectedLocation.latitude.toStringAsFixed(5)}\n'
              'Longitude: ${selectedLocation.longitude.toStringAsFixed(5)}',

              style: const TextStyle(
                fontSize: 12,
                color:
                    Color(0xFF0A3323),
              ),
            ),

            const SizedBox(height: 35),

            // ==================================================
            // SUBMIT BUTTON
            // ==================================================

            SizedBox(
              width: double.infinity,
              height: 58,

              child:
                  ElevatedButton.icon(

                onPressed:
                    submitting
                        ? null
                        : submitReport,

                icon: submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.send,
                      ),

                label: Text(
                  submitting
                      ? 'SUBMITTING...'
                      : 'SUBMIT REPORT',

                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),

                style:
                    ElevatedButton.styleFrom(

                  backgroundColor:
                      const Color(
                    0xFF0A3323,
                  ),

                  foregroundColor:
                      const Color(
                    0xFFF7F4D5,
                  ),

                  shape:
                      RoundedRectangleBorder(

                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}