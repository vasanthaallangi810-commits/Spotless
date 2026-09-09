import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/report.dart';
import '../theme/app_theme.dart';
import '../widgets/spotless_background.dart';
import 'report_details_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late Future<List<Report>> _reportsFuture;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  // ============================================================
  // LOAD REPORTS FROM SQLITE
  // ============================================================

  void _loadReports() {
    _reportsFuture = DatabaseHelper.instance.getReports();
  }

  // ============================================================
  // BUILD SCREEN
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Reports",
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SpotlessBackground(
        child: FutureBuilder<List<Report>>(
          future: _reportsFuture,
          builder: (context, snapshot) {
            // ----------------------------------------------------
            // LOADING
            // ----------------------------------------------------

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.mossGreen,
                ),
              );
            }

            // ----------------------------------------------------
            // ERROR
            // ----------------------------------------------------

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 70,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        "Unable to load reports",
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkGreen,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${snapshot.error}",
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _loadReports();
                          });
                        },
                        child: const Text("Try Again"),
                      ),
                    ],
                  ),
                ),
              );
            }

            // ----------------------------------------------------
            // GET REPORTS FROM SQLITE
            // ----------------------------------------------------

            final reports = snapshot.data ?? [];

            // ----------------------------------------------------
            // NO REPORTS
            // ----------------------------------------------------

            if (reports.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.assignment_outlined,
                      size: 80,
                      color: AppTheme.mossGreen,
                    ),
                    SizedBox(height: 15),
                    Text(
                      "No reports yet",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkGreen,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Your garbage reports will appear here.",
                    ),
                  ],
                ),
              );
            }

            // ----------------------------------------------------
            // DISPLAY REPORTS
            // ----------------------------------------------------

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];

                return TweenAnimationBuilder<double>(
                  duration: Duration(
                    milliseconds: 350 + index * 100,
                  ),
                  tween: Tween<double>(
                    begin: 0,
                    end: 1,
                  ),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(
                          0,
                          30 * (1 - value),
                        ),
                        child: child,
                      ),
                    );
                  },
                  child: GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReportDetailsScreen(
                            report: report,
                          ),
                        ),
                      );

                      // Refresh reports when coming back
                      // from the details screen.
                      if (!mounted) return;

                      setState(() {
                        _loadReports();
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(
                        bottom: 15,
                      ),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.78),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          // ------------------------------------------------
                          // GARBAGE ICON
                          // ------------------------------------------------

                          Container(
                            width: 55,
                            height: 55,
                            decoration: BoxDecoration(
                              color: AppTheme.mossGreen.withOpacity(.25),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.delete_outline,
                              color: AppTheme.darkGreen,
                            ),
                          ),

                          const SizedBox(width: 15),

                          // ------------------------------------------------
                          // REPORT INFORMATION
                          // ------------------------------------------------

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  report.garbageType,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                    color: AppTheme.darkGreen,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                Text(
                                  report.location,
                                  style: TextStyle(
                                    color: AppTheme.darkGreen.withOpacity(.6),
                                  ),
                                ),

                                const SizedBox(height: 8),

                                _status(report.status),
                              ],
                            ),
                          ),

                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // STATUS LABEL
  // ============================================================

  Widget _status(String status) {
    Color background;
    Color text;

    switch (status) {
      case "Resolved":
        background = AppTheme.mossGreen;
        text = AppTheme.darkGreen;
        break;

      case "In Progress":
        background = AppTheme.midnightGreen;
        text = AppTheme.beige;
        break;

      default:
        background = AppTheme.rosyBrown;
        text = AppTheme.darkGreen;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: text,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}