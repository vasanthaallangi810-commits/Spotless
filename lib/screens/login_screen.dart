

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/app_data.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/spotless_background.dart';
import 'main_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage("Please enter email and password.");
      return;
    }

    if (!email.contains('@')) {
      _showMessage("Please enter a valid email address.");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final result = await ApiService.login(
        email: email,
        password: password,
      );

      print("LOGIN RESULT: $result");

      if (!mounted) return;

      if (result['success'] == true) {
        // Save logged-in user's information
        AppData.userId = result['userId'];
        AppData.userName = result['name'] ?? '';

        // Save user session permanently
        final prefs = await SharedPreferences.getInstance();

        await prefs.setInt(
          'user_id',
          result['userId'],
        );

        await prefs.setString(
          'user_name',
          result['name'] ?? '',
        );

        await prefs.setString(
          'user_email',
          result['email'] ?? email,
        );

        print("USER ID SAVED: ${result['userId']}");

        _showMessage("Login successful! 🌱");

        await Future.delayed(
          const Duration(milliseconds: 500),
        );

        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const MainScreen(),
          ),
          (route) => false,
        );
      } else {
        _showMessage(
          result['message'] ?? 'Invalid email or password.',
        );
      }
    } catch (e) {
      print("LOGIN ERROR: $e");

      if (mounted) {
        _showMessage("Login failed: $e");
      }
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
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SpotlessBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  const SizedBox(height: 30),

                  Container(
                    width: 95,
                    height: 95,
                    decoration: const BoxDecoration(
                      color: AppTheme.darkGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.eco,
                      color: AppTheme.beige,
                      size: 55,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Welcome to Spotless",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkGreen,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Let's make your surroundings cleaner.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:
                          AppTheme.darkGreen.withOpacity(.65),
                    ),
                  ),

                  const SizedBox(height: 35),

                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.75),
                      borderRadius:
                          BorderRadius.circular(30),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: emailController,
                          keyboardType:
                              TextInputType.emailAddress,
                          decoration:
                              const InputDecoration(
                            labelText: "Email",
                            prefixIcon:
                                Icon(Icons.email),
                          ),
                        ),

                        const SizedBox(height: 15),

                        TextField(
                          controller: passwordController,
                          obscureText: obscurePassword,
                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon:
                                const Icon(Icons.lock),
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
                            onPressed:
                                isLoading ? null : login,
                            style:
                                ElevatedButton.styleFrom(
                              backgroundColor:
                                  AppTheme.darkGreen,
                              foregroundColor:
                                  AppTheme.beige,
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(18),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color:
                                          AppTheme.beige,
                                    ),
                                  )
                                : const Text(
                                    "LOGIN",
                                    style: TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            const Text(
                              "New to Spotless? ",
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const RegisterScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Create account",
                                style: TextStyle(
                                  color:
                                      AppTheme.midnightGreen,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}