
import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../services/api_service.dart';
import '../widgets/spotless_background.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool isLoading = true;
  String? errorMessage;

  List<dynamic> reports = [];

  @override
  void initState() {
    super.initState();
    loadReports();
  }

  // ============================================================
  // LOAD REPORTS FROM NODE.JS → MYSQL
  // ============================================================

  Future<void> loadReports() async {
    final int? userId = AppData.userId;

    if (userId == null) {
      setState(() {
        isLoading = false;
        errorMessage =
            'User session not found. Please login again.';
      });
      return;
    }

    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      debugPrint('================================');
      debugPrint('LOADING USER REPORTS');
      debugPrint('USER ID: $userId');
      debugPrint('================================');

      final result = await ApiService.getMyReports(
        userId: userId,
      );

      debugPrint('REPORTS API RESPONSE: $result');

      if (!mounted) return;

      if (result['success'] == true) {
        setState(() {
          reports = result['reports'] ?? [];
          isLoading = false;
        });

        debugPrint(
          'TOTAL REPORTS: ${reports.length}',
        );
      } else {
        setState(() {
          isLoading = false;
          errorMessage =
              result['message'] ??
              'Unable to load reports.';
        });
      }
    } catch (e) {
      debugPrint('GET REPORTS ERROR: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
            'Unable to load reports.\nException: $e';
      });
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refreshReports() async {
    await loadReports();
  }

  // ============================================================
  // REPORT CARD
  // ============================================================

  Widget reportCard(
    Map<String, dynamic> report,
  ) {
    final String garbageType =
        report['garbage_type']?.toString() ?? 'Unknown';

    final String description =
        report['description']?.toString() ?? '';

    final String status =
        report['status']?.toString() ?? 'Pending';

    final String latitude =
        report['latitude']?.toString() ?? '';

    final String longitude =
        report['longitude']?.toString() ?? '';

    final String createdAt =
        report['created_at']?.toString() ?? '';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.88),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          // ====================================================
          // TOP ROW
          // ====================================================

          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF0A3323)
                      .withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFF0A3323),
                  size: 28,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      garbageType,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A3323),
                      ),
                    ),

                    if (createdAt.isNotEmpty)
                      const SizedBox(height: 4),

                    if (createdAt.isNotEmpty)
                      Text(
                        createdAt,
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              Colors.black.withOpacity(0.55),
                        ),
                      ),
                  ],
                ),
              ),

              // ==================================================
              // STATUS
              // ==================================================

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF839958)
                      .withOpacity(0.20),
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A3323),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ====================================================
          // DESCRIPTION
          // ====================================================

          if (description.isNotEmpty)
            Text(
              description,
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
                color: Color(0xFF333333),
              ),
            ),

          const SizedBox(height: 14),

          // ====================================================
          // LOCATION
          // ====================================================

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F4D5),
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: Color(0xFF0A3323),
                  size: 22,
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    'Latitude: $latitude\n'
                    'Longitude: $longitude',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF0A3323),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        title: const Text(
          'My Reports',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor:
            const Color(0xFF0A3323),
        foregroundColor:
            const Color(0xFFF7F4D5),
        actions: [
          IconButton(
            onPressed:
                isLoading ? null : refreshReports,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),

      // ========================================================
      // SPOTLESS FLOATING BACKGROUND 🌱♻️
      // ========================================================

      body: SpotlessBackground(
        child: RefreshIndicator(
          onRefresh: refreshReports,

          child: isLoading

              // ==================================================
              // LOADING
              // ==================================================

              ? const Center(
                  child:
                      CircularProgressIndicator(),
                )

              // ==================================================
              // ERROR
              // ==================================================

              : errorMessage != null
                  ? ListView(
                      physics:
                          const AlwaysScrollableScrollPhysics(),

                      children: [
                        const SizedBox(
                          height: 150,
                        ),

                        const Icon(
                          Icons.error_outline,
                          size: 65,
                          color: Color(0xFF0A3323),
                        ),

                        const SizedBox(
                          height: 20,
                        ),

                        Padding(
                          padding:
                              const EdgeInsets.all(25),
                          child: Text(
                            errorMessage!,
                            textAlign:
                                TextAlign.center,
                            style:
                                const TextStyle(
                              fontSize: 16,
                              color:
                                  Color(0xFF333333),
                            ),
                          ),
                        ),

                        Center(
                          child:
                              ElevatedButton.icon(
                            onPressed:
                                loadReports,
                            icon:
                                const Icon(
                              Icons.refresh,
                            ),
                            label:
                                const Text(
                              'Try Again',
                            ),
                          ),
                        ),
                      ],
                    )

                  // ==================================================
                  // NO REPORTS
                  // ==================================================

                  : reports.isEmpty
                      ? ListView(
                          physics:
                              const AlwaysScrollableScrollPhysics(),

                          children: [
                            const SizedBox(
                              height: 150,
                            ),

                            const Icon(
                              Icons
                                  .delete_sweep_outlined,
                              size: 75,
                              color:
                                  Color(0xFF0A3323),
                            ),

                            const SizedBox(
                              height: 20,
                            ),

                            const Text(
                              'No reports yet',
                              textAlign:
                                  TextAlign.center,
                              style:
                                  TextStyle(
                                fontSize: 22,
                                fontWeight:
                                    FontWeight.bold,
                                color:
                                    Color(0xFF0A3323),
                              ),
                            ),

                            const SizedBox(
                              height: 8,
                            ),

                            Text(
                              'Your submitted garbage reports '
                              'will appear here.',
                              textAlign:
                                  TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black
                                    .withOpacity(0.6),
                              ),
                            ),
                          ],
                        )

                      // ==================================================
                      // REPORT LIST
                      // ==================================================

                      : ListView.builder(
                          physics:
                              const AlwaysScrollableScrollPhysics(),

                          padding:
                              const EdgeInsets.all(20),

                          itemCount:
                              reports.length,

                          itemBuilder:
                              (context, index) {
                            return reportCard(
                              reports[index]
                                  as Map<String,
                                      dynamic>,
                            );
                          },
                        ),
        ),
      ),
    );
  }
}

