import 'package:flutter/material.dart';

const Color spotlessGreen = Color(0xFF0A3323);
const Color spotlessLightGreen = Color(0xFFE1F0E5);
const Color spotlessYellow = Color(0xFFFFD54F);
const Color spotlessCream = Color(0xFFF7F4D5);
const Color spotlessWhite = Color(0xFFFFFFFF);
const Color spotlessText = Color(0xFF26332B);

// ============================================================
// 1. PERSONAL INFORMATION SCREEN
// ============================================================

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController =
      TextEditingController(text: 'Vasantha');

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _phoneController =
      TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveInformation() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Information saved for this session.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
   return Scaffold(
    backgroundColor: spotlessCream,
    appBar: AppBar(
      backgroundColor: spotlessGreen,
      foregroundColor: spotlessWhite,
      elevation: 0,
        title: const Text('Personal Information'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: CircleAvatar(
                  radius: 45,
                  child: Icon(
                    Icons.person,
                    size: 50,
                  ),
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                'Your Details',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                          .hasMatch(value.trim())) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveInformation,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Information'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
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

// ============================================================
// 2. NOTIFICATIONS SCREEN
// ============================================================

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool reportUpdates = true;
  bool statusUpdates = true;
  bool environmentalTips = false;

  Widget _notificationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: SwitchListTile(
        secondary: Icon(icon),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: spotlessCream,
    appBar: AppBar(
      backgroundColor: spotlessGreen,
      foregroundColor: spotlessWhite,
      elevation: 0,
        title: const Text('Notifications'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Notification Preferences',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose which updates you want to receive from Spotless.',
          ),
          const SizedBox(height: 20),

          _notificationTile(
            icon: Icons.add_a_photo_outlined,
            title: 'Report Updates',
            subtitle: 'Updates related to your submitted reports',
            value: reportUpdates,
            onChanged: (value) {
              setState(() => reportUpdates = value);
            },
          ),

          _notificationTile(
            icon: Icons.track_changes,
            title: 'Status Updates',
            subtitle: 'Know when a report status changes',
            value: statusUpdates,
            onChanged: (value) {
              setState(() => statusUpdates = value);
            },
          ),

          _notificationTile(
            icon: Icons.eco_outlined,
            title: 'Environmental Tips',
            subtitle: 'Tips for keeping your surroundings clean',
            value: environmentalTips,
            onChanged: (value) {
              setState(() => environmentalTips = value);
            },
          ),

          const SizedBox(height: 16),

          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'These switches currently control preferences '
                      'within this screen. Push notifications require '
                      'additional notification-service integration.',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 3. LOCATION SETTINGS SCREEN
// ============================================================

class LocationSettingsScreen extends StatefulWidget {
  const LocationSettingsScreen({super.key});

  @override
  State<LocationSettingsScreen> createState() =>
      _LocationSettingsScreenState();
}

class _LocationSettingsScreenState
    extends State<LocationSettingsScreen> {
  bool useLocation = true;
  bool confirmLocationBeforeReport = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: spotlessCream,
      appBar: AppBar(
        backgroundColor: spotlessGreen,
        foregroundColor: spotlessWhite,
        elevation: 0,
        title: const Text('Location Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Center(
            child: Icon(
              Icons.location_on,
              size: 75,
            ),
          ),

          const SizedBox(height: 16),

          const Center(
            child: Text(
              'Location Preferences',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Location helps Spotless identify where garbage '
            'has been reported.',
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.my_location),
              title: const Text('Use Location'),
              subtitle: const Text(
                'Enable location use as an app preference',
              ),
              value: useLocation,
              onChanged: (value) {
                setState(() => useLocation = value);
              },
            ),
          ),

          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.map_outlined),
              title: const Text('Confirm Location'),
              subtitle: const Text(
                'Review the location before submitting a report',
              ),
              value: confirmLocationBeforeReport,
              onChanged: (value) {
                setState(
                  () => confirmLocationBeforeReport = value,
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          Card(
            child: ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Location Privacy'),
              subtitle: const Text(
                'Location coordinates may be included in '
                'your garbage reports.',
              ),
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'Note: These switches currently update the screen only. '
            'Connecting them to your report form and Android location '
            'permissions requires additional code.',
            style: TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 4. ABOUT SPOTLESS SCREEN
// ============================================================

class AboutSpotlessScreen extends StatelessWidget {
  const AboutSpotlessScreen({super.key});

  Widget _featureTile({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, size: 30),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(description),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: spotlessCream,
      appBar: AppBar(
        backgroundColor: spotlessGreen,
        foregroundColor: spotlessWhite,
        elevation: 0,
        title: const Text('About Spotless'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

      const CircleAvatar(
        radius: 55,
        backgroundColor: Color(0xFF0A3323), // Dark green
        child: Icon(
          Icons.eco,
          size: 65,
          color: Color(0xFFFFFDD0), // Yellow
        ),
      ),

//Color(0xFFFFD54F)
            const SizedBox(height: 16),

            const Text(
              'Spotless',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'A cleaner environment starts with us.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 30),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'About the Application',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Spotless is a garbage-reporting application designed '
              'to help people report waste in their surroundings. '
              'Users can submit reports with photographs, '
              'descriptions, garbage categories, and location '
              'coordinates to support cleaner communities.',
              style: TextStyle(fontSize: 15, height: 1.6),
              textAlign: TextAlign.justify,
            ),

            const SizedBox(height: 24),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Key Features',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 12),

            _featureTile(
              icon: Icons.camera_alt_outlined,
              title: 'Garbage Reporting',
              description:
                  'Report waste with photographs and descriptions.',
            ),

            _featureTile(
              icon: Icons.location_on_outlined,
              title: 'Location Tracking',
              description:
                  'Associate reports with geographical coordinates.',
            ),

            _featureTile(
              icon: Icons.assignment_outlined,
              title: 'Report Tracking',
              description:
                  'View submitted reports and their statuses.',
            ),

            _featureTile(
              icon: Icons.eco_outlined,
              title: 'Environmental Awareness',
              description:
                  'Encourage responsible waste management.',
            ),

            const SizedBox(height: 24),

            const Text(
              'Version 1.0.0',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),

            const Text(
              'Together for a cleaner tomorrow. 🌿',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}