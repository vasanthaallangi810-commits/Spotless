
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

class _ReportsScreenState extends State<ReportsScreen> {
  List<Map<String, dynamic>> reports = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchReports();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4D5),
      body: SafeArea(
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
                                          padding: const EdgeInsets.all(10),
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
                                                  style: const TextStyle(
                                                    fontSize: 17,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    color:
                                                        Color(0xFF0A3323),
                                                  ),
                                                ),
                                              ),

                                              const Icon(
                                                Icons.chevron_right,
                                                color: Color(0xFF0A3323),
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
    );
  }
}
