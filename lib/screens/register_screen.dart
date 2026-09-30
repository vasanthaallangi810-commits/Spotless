import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../theme/app_theme.dart';
import '../widgets/spotless_background.dart';
import 'main_screen.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    // Empty fields
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showMessage('Please fill in all fields.');
      return;
    }

    // Email validation
    if (!email.contains('@')) {
      _showMessage('Please enter a valid email address.');
      return;
    }

    // Password validation
    if (password.length < 8) {
      _showMessage(
        'Password must be at least 8 characters long.',
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Send user data to Node.js → MySQL
      final result = await ApiService.registerUser(
        name: name,
        email: email,
        password: password,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        // Save current user's name in the app
        AppData.userName = name;

        _showMessage('Account created successfully! 🌱');

        // Go to main screen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const MainScreen(),
          ),
          (route) => false,
        );
      } else {
        _showMessage(
          result['message'] ?? 'Registration failed.',
        );
      }
    } catch (e) {
      _showMessage(
        'Could not connect to the server. Make sure the backend is running.',
      );
      print('Registration error: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SpotlessBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Column(
              children: [
                const SizedBox(height: 25),

                const Text(
                  "Create your account",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkGreen,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Join the movement towards cleaner communities 🌱",
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 30),

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.78),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: "Full Name",
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),

                      const SizedBox(height: 15),

                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          prefixIcon: Icon(Icons.email),
                        ),
                      ),

                      const SizedBox(height: 15),

                      TextField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                obscurePassword =
                                    !obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                AppTheme.darkGreen,
                            foregroundColor:
                                AppTheme.beige,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(18),
                            ),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator()
                              : const Text(
                                  "CREATE ACCOUNT",
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
}
