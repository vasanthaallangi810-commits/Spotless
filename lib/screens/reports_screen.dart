
import 'dart:math';

import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../services/api_service.dart';
import '../models/report.dart';
import 'report_details_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> reports = [];
  bool isLoading = true;
  String? errorMessage;
  late final AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    fetchReports();
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  Future<void> fetchReports() async {
    try {
      final userId = AppData.userId;

if (userId == null) {
  setState(() {
    errorMessage = 'User session not found. Please login again.';
    isLoading = false;
  });
  return;
}

      final result = await ApiService.getMyReports(
        userId: userId,
      );

      if (!mounted) return;

      setState(() {
        reports = List<Map<String, dynamic>>.from(
          result['reports'] ?? [],
        );
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'Unable to load reports. Please try again.';
        isLoading = false;
      });
    }
  }

  DateTime parseDate(dynamic value) {
    if (value == null) return DateTime.now();

    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return DateTime.now();
    }
  }

  Widget buildReportImage(Map<String, dynamic> report) {
    // Find the locally stored image bytes for this report.
    // Reports loaded from the backend may not have image bytes.
    final matchingReport = AppData.reports.cast<Report?>().firstWhere(
      (localReport) =>
          localReport != null &&
          localReport.type == report['garbage_type'] &&
          localReport.description == report['description'],
      orElse: () => null,
    );

    if (matchingReport?.imageBytes != null) {
      return Image.memory(
        matchingReport!.imageBytes!,
        width: 75,
        height: 75,
        fit: BoxFit.cover,
      );
    }

    return Container(
      width: 75,
      height: 75,
      color: Colors.green.shade50,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Colors.green.shade700,
        size: 30,
      ),
    );
  }

  void openReportDetails(Map<String, dynamic> report) {
    final matchingReport = AppData.reports.cast<Report?>().firstWhere(
      (localReport) =>
          localReport != null &&
          localReport.type == report['garbage_type'] &&
          localReport.description == report['description'],
      orElse: () => null,
    );

    final reportDetails = Report(
      type: report['garbage_type']?.toString() ?? 'Unknown',
      description: report['description']?.toString() ?? '',
      latitude: double.tryParse(
            report['latitude']?.toString() ?? '',
          ) ??
          0.0,
      longitude: double.tryParse(
            report['longitude']?.toString() ?? '',
          ) ??
          0.0,
      imagePath: matchingReport?.imagePath ?? '',
      imageBytes: matchingReport?.imageBytes,
      status: report['status']?.toString() ?? 'Pending',
      date: parseDate(report['created_at']),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportDetailsScreen(
          report: reportDetails,
        ),
      ),
    );
  }

  Widget _floatingReportIcon({
    required IconData icon,
    required double left,
    required double top,
    required double size,
    required int phase,
  }) {
    final wave = sin((_floatController.value * 2 * pi) + phase) * 10;
    final drift = cos((_floatController.value * 2 * pi) + phase) * 8;

    return Positioned(
      left: left + wave,
      top: top + drift,
      child: Opacity(
        opacity: 0.8,
        child: Icon(
          icon,
          size: size,
          color: const Color(0xFF839958),
          shadows: [
            Shadow(
              color: const Color(0xFF839958).withValues(alpha: 0.3),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4D5),
      body: AnimatedBuilder(
        animation: _floatController,
        builder: (context, _) {
          return Stack(
            children: [
              _floatingReportIcon(
                icon: Icons.delete_outline,
                left: 20,
                top: 80,
                size: 34,
                phase: 0,
              ),
              _floatingReportIcon(
                icon: Icons.recycling,
                left: 120,
                top: 150,
                size: 33,
                phase: 1,
              ),
              _floatingReportIcon(
                icon: Icons.location_on_outlined,
                right: 30,
                top: 120,
                size: 30,
                phase: 2,
              ),
              _floatingReportIcon(
                icon: Icons.cleaning_services,
                left: 60,
                top: 240,
                size: 32,
                phase: 3,
              ),
              _floatingReportIcon(
                icon: Icons.checklist_rtl,
                right: 50,
                top: 220,
                size: 31,
                phase: 4,
              ),
              _floatingReportIcon(
                icon: Icons.eco,
                left: 180,
                top: 300,
                size: 30,
                phase: 5,
              ),
              _floatingReportIcon(
                icon: Icons.local_florist,
                right: 140,
                top: 310,
                size: 29,
                phase: 6,
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A3323),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'My Reports',
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF0A3323),
                                ),
                              )
                            : errorMessage != null
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          errorMessage!,
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 12),
                                        ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              isLoading = true;
                                              errorMessage = null;
                                            });
                                            fetchReports();
                                          },
                                          child: const Text('Retry'),
                                        ),
                                      ],
                                    ),
                                  )
                                : reports.isEmpty
                                    ? const Center(
                                        child: Text(
                                          'No reports found.',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      )
                                    : RefreshIndicator(
                                        onRefresh: fetchReports,
                                        child: ListView.builder(
                                          itemCount: reports.length,
                                          itemBuilder: (context, index) {
                                            final report = reports[index];

                                            return Card(
                                              margin: const EdgeInsets.only(
                                                bottom: 14,
                                              ),
                                              elevation: 2,
                                              color: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                              ),
                                              child: InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                onTap: () {
                                                  openReportDetails(report);
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  child: Row(
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(10),
                                                        child: buildReportImage(
                                                          report,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 16),
                                                      Expanded(
                                                        child: Text(
                                                          report['garbage_type']
                                                                  ?.toString() ??
                                                              'Unknown',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 17,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Color(
                                                                0xFF0A3323),
                                                          ),
                                                        ),
                                                      ),
                                                      const Icon(
                                                        Icons.chevron_right,
                                                        color: Color(
                                                            0xFF0A3323),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
