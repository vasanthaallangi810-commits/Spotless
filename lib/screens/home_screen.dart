import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../theme/app_theme.dart';
import '../widgets/spotless_background.dart';
import 'report_garbage_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController pulseController;

  @override
  void initState() {
    super.initState();

    pulseController = AnimationController(
      vsync: this,
      duration:
          const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total =
        AppData.reports.length;

    final resolved = AppData.reports
        .where(
          (r) => r.status == "Resolved",
        )
        .length;

    return Scaffold(
      body: SpotlessBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.fromLTRB(
              20,
              22,
              20,
              35,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                // HEADER
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            "GOOD DAY 👋",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  FontWeight.bold,
                              letterSpacing: 2,
                              color:
                                  AppTheme
                                      .midnightGreen,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            AppData.userName,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight:
                                  FontWeight.w900,
                              color:
                                  AppTheme.darkGreen,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            "Let's keep it spotless.",
                            style: TextStyle(
                              fontSize: 15,
                              color: AppTheme
                                  .darkGreen
                                  .withOpacity(.65),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      width: 55,
                      height: 55,
                      decoration:
                          const BoxDecoration(
                        color:
                            AppTheme.darkGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        color:
                            AppTheme.beige,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // HERO
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(32),
                    gradient:
                        const LinearGradient(
                      begin:
                          Alignment.topLeft,
                      end:
                          Alignment.bottomRight,
                      colors: [
                        AppTheme.darkGreen,
                        AppTheme.midnightGreen,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme
                            .darkGreen
                            .withOpacity(.25),
                        blurRadius: 25,
                        offset:
                            const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                const Text(
                                  "A cleaner world\nstarts with you.",
                                  style: TextStyle(
                                    color:
                                        AppTheme
                                            .beige,
                                    fontSize: 25,
                                    fontWeight:
                                        FontWeight.w900,
                                    height: 1.1,
                                  ),
                                ),

                                const SizedBox(
                                  height: 10,
                                ),

                                Text(
                                  "Spot it. Report it. Keep it clean.",
                                  style: TextStyle(
                                    color:
                                        AppTheme
                                            .beige
                                            .withOpacity(
                                                .72),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          AnimatedBuilder(
                            animation:
                                pulseController,
                            builder:
                                (context, child) {
                              return Transform.scale(
                                scale: 1 +
                                    pulseController
                                            .value *
                                        .08,
                                child:
                                    const Icon(
                                  Icons
                                      .recycling,
                                  size: 90,
                                  color:
                                      AppTheme
                                          .mossGreen,
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      SizedBox(
                        width: double.infinity,
                        child:
                            ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const ReportGarbageScreen(),
                              ),
                            ).then((_) {
                              setState(() {});
                            });
                          },
                          icon: const Icon(
                            Icons
                                .camera_alt_outlined,
                          ),
                          label: const Text(
                            "REPORT GARBAGE",
                          ),
                          style:
                              ElevatedButton
                                  .styleFrom(
                            backgroundColor:
                                AppTheme.beige,
                            foregroundColor:
                                AppTheme.darkGreen,
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              vertical: 16,
                            ),
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(18),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  "YOUR IMPACT",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        FontWeight.bold,
                    letterSpacing: 2,
                    color:
                        AppTheme.midnightGreen,
                  ),
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    _statCard(
                      "$total",
                      "Total Reports",
                      Icons
                          .assignment_outlined,
                    ),

                    const SizedBox(width: 12),

                    _statCard(
                      "$resolved",
                      "Resolved",
                      Icons
                          .check_circle_outline,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Container(
                  padding:
                      const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color:
                        AppTheme.rosyBrown,
                    borderRadius:
                        BorderRadius.circular(25),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons
                            .volunteer_activism,
                        size: 42,
                        color:
                            AppTheme.darkGreen,
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          "Small actions create a big change. Every report helps.",
                          style: TextStyle(
                            color:
                                AppTheme.darkGreen,
                            fontSize: 16,
                            fontWeight:
                                FontWeight.bold,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statCard(
    String number,
    String label,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white
              .withOpacity(.75),
          borderRadius:
              BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color:
                  AppTheme.midnightGreen,
              size: 30,
            ),
            const SizedBox(height: 12),
            Text(
              number,
              style: const TextStyle(
                fontSize: 30,
                fontWeight:
                    FontWeight.w900,
                color:
                    AppTheme.darkGreen,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color:
                    AppTheme.darkGreen
                        .withOpacity(.65),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}