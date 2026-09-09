import 'package:flutter/material.dart';

import '../models/report.dart';
import '../theme/app_theme.dart';
import '../widgets/spotless_background.dart';

class ReportDetailsScreen extends StatelessWidget {
  final Report report;

  const ReportDetailsScreen({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Report Details",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SpotlessBackground(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              if (report.imageBytes != null)
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(28),
                  child: Image.memory(
                    report.imageBytes!,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                ),

              const SizedBox(height: 20),

              Text(
                report.garbageType,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight:
                      FontWeight.w900,
                  color:
                      AppTheme.darkGreen,
                ),
              ),

              const SizedBox(height: 15),

              _detail(
                Icons.location_on,
                "Location",
                report.location,
              ),

              _detail(
                Icons.description,
                "Description",
                report.description
                    .isEmpty
                    ? "No description provided."
                    : report.description,
              ),

              _detail(
                Icons.calendar_today,
                "Date",
                "${report.date.day}/"
                    "${report.date.month}/"
                    "${report.date.year}",
              ),

              _detail(
                Icons.info_outline,
                "Status",
                report.status,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detail(
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(bottom: 14),
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color:
            Colors.white.withOpacity(.75),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color:
                AppTheme.midnightGreen,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme
                        .darkGreen
                        .withOpacity(.55),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    color:
                        AppTheme.darkGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}