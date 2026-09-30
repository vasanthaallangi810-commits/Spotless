import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/app_data.dart';
import '../services/api_service.dart';
import '../widgets/spotless_background.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker picker = ImagePicker();

  XFile? profileImage;

  // ============================================================
  // REPORT STATISTICS
  // ============================================================

  int totalReports = 0;
  int resolvedReports = 0;

  bool isLoadingStats = true;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    loadReportStats();
  }

  // ============================================================
  // LOAD REPORT STATISTICS FROM MYSQL / API
  // ============================================================

  Future<void> loadReportStats() async {
    try {
      int? userId = AppData.userId;

      // If AppData doesn't have the user ID,
      // get it from SharedPreferences.
      if (userId == null) {
        final prefs = await SharedPreferences.getInstance();

        userId = prefs.getInt('user_id');

        if (userId != null) {
          AppData.userId = userId;
        }
      }

      // No logged-in user
      if (userId == null) {
        if (!mounted) return;

        setState(() {
          isLoadingStats = false;
        });

        return;
      }

      // Get reports from backend
      final result = await ApiService.getMyReports(
        userId: userId,
      );

      final List reports = result['reports'] ?? [];

      int resolved = 0;

      // Count resolved reports
      for (final report in reports) {
        final status =
            report['status']?.toString().toLowerCase().trim();

        if (status == 'resolved') {
          resolved++;
        }
      }

      if (!mounted) return;

      setState(() {
        totalReports = reports.length;
        resolvedReports = resolved;
        isLoadingStats = false;
      });
    } catch (e) {
      debugPrint("PROFILE STATS ERROR: $e");

      if (!mounted) return;

      setState(() {
        isLoadingStats = false;
      });
    }
  }

  // ============================================================
  // CHANGE PROFILE PHOTO
  // ============================================================

  Future<void> changeProfilePicture() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: const Color(0xFFF7F4D5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Change profile picture',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A3323),
                  ),
                ),

                const SizedBox(height: 25),

                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF839958),
                    child: Icon(
                      Icons.camera_alt,
                      color: Color(0xFFF7F4D5),
                    ),
                  ),
                  title: const Text(
                    'Take a photo',
                  ),
                  onTap: () {
                    Navigator.pop(
                      context,
                      ImageSource.camera,
                    );
                  },
                ),

                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFD3968C),
                    child: Icon(
                      Icons.photo,
                      color: Color(0xFFF7F4D5),
                    ),
                  ),
                  title: const Text(
                    'Choose from gallery',
                  ),
                  onTap: () {
                    Navigator.pop(
                      context,
                      ImageSource.gallery,
                    );
                  },
                ),

                if (profileImage != null)
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFF105666),
                      child: Icon(
                        Icons.delete,
                        color: Color(0xFFF7F4D5),
                      ),
                    ),
                    title: const Text(
                      'Remove picture',
                    ),
                    onTap: () {
                      Navigator.pop(
                        context,
                        null,
                      );

                      setState(() {
                        profileImage = null;
                      });
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) {
      return;
    }

    final image = await picker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        profileImage = image;
      });
    }
  }

  // ============================================================
  // PROFILE IMAGE
  // ============================================================

  Widget profilePhoto() {
    if (profileImage == null) {
      return const CircleAvatar(
        radius: 58,
        backgroundColor: Color(0xFF839958),
        child: Icon(
          Icons.person,
          size: 65,
          color: Color(0xFFF7F4D5),
        ),
      );
    }

    return FutureBuilder(
      future: profileImage!.readAsBytes(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircleAvatar(
            radius: 58,
            backgroundColor: Color(0xFF839958),
            child: CircularProgressIndicator(),
          );
        }

        return CircleAvatar(
          radius: 58,
          backgroundImage: MemoryImage(
            snapshot.data!,
          ),
        );
      },
    );
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4D5),

      body: SpotlessBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: loadReportStats,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(22),

              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // =================================================
                  // TITLE
                  // =================================================

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'My Profile',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0A3323),
                      ),
                    ),
                  ),

                  const SizedBox(height: 35),

                  // =================================================
                  // PROFILE IMAGE
                  // =================================================

                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF0A3323),
                        ),
                        child: profilePhoto(),
                      ),

                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: changeProfilePicture,
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration:
                                const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFD3968C),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Color(0xFFF7F4D5),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // =================================================
                  // NAME
                  // =================================================

                  const Text(
                    'Vasantha',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A3323),
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    'Keep your surroundings spotless 🌿',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.55),
                    ),
                  ),

                  const SizedBox(height: 35),

                  // =================================================
                  // STATISTICS
                  // =================================================

                  Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          icon: Icons.delete_outline,
                          title: 'Total Reports',
                          value: isLoadingStats
                              ? '...'
                              : '$totalReports',
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: _statCard(
                          icon: Icons.check_circle_outline,
                          title: 'Resolved',
                          value: isLoadingStats
                              ? '...'
                              : '$resolvedReports',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // =================================================
                  // OPTIONS
                  // =================================================

                  _profileOption(
                    icon: Icons.person_outline,
                    title: 'Personal Information',
                    onTap: () {},
                  ),

                  _profileOption(
                    icon: Icons.notifications_none,
                    title: 'Notifications',
                    onTap: () {},
                  ),

                  _profileOption(
                    icon: Icons.location_on_outlined,
                    title: 'Location Settings',
                    onTap: () {},
                  ),

                  _profileOption(
                    icon: Icons.info_outline,
                    title: 'About Spotless',
                    onTap: () {},
                  ),

                  const SizedBox(height: 20),

                  // =================================================
                  // CHANGE PHOTO BUTTON
                  // =================================================

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton.icon(
                      onPressed: changeProfilePicture,
                      icon: const Icon(
                        Icons.edit,
                      ),
                      label: const Text(
                        'CHANGE PROFILE PICTURE',
                      ),
                      style:
                          OutlinedButton.styleFrom(
                        foregroundColor:
                            const Color(0xFF0A3323),
                        side: const BorderSide(
                          color: Color(0xFF0A3323),
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // STAT CARD
  // ============================================================

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: const Color(0xFF839958)
            .withOpacity(0.22),
        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        children: [
          Icon(
            icon,
            size: 30,
            color: const Color(0xFF0A3323),
          ),

          const SizedBox(height: 10),

          Text(
            value,
            style: const TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0A3323),
            ),
          ),

          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PROFILE OPTION
  // ============================================================

  Widget _profileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),

      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
      ),

      child: ListTile(
        leading: Icon(
          icon,
          color: const Color(0xFF0A3323),
        ),

        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF0A3323),
          ),
        ),

        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),

        onTap: onTap,
      ),
    );
  }
}