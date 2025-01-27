import 'dart:convert';

import 'package:elevate/api.dart';
import 'package:elevate/student/detail_forms/personal_details.dart';
import 'package:elevate/student/student_login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class StudentSignup extends StatefulWidget {
  const StudentSignup({super.key});

  @override
  _StudentSignupState createState() => _StudentSignupState();
}

class _StudentSignupState extends State<StudentSignup> {
  bool _isProcessing = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passWordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _collegeIdController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _handleSignup(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$api/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userName': _userNameController.text.trim(),
          'passWord': _passWordController.text.trim(),
          'college': {'collegeId': _collegeIdController.text.trim()}
        }),
      );

      if (response.statusCode == 202) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        int userId = responseData['userId'];
        String token = responseData['token'];

        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('authToken', token);
          await prefs.setInt('userId', userId);
        } catch (e) {
          // ignore: avoid_print
          print('Failed to save authentication token: $e');
          setState(() {
            _isProcessing = false;
          });
          return;
        }

        try {
          final response1 = await http.post(
            Uri.parse('$api/student-details/create?userId=$userId'),
          );
          setState(() {
            _isProcessing = false;
          });

          if (response1.statusCode == 200) {
            if (context.mounted) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PersonalDetailsForm(userId: userId),
                ),
              );
            }
          } else {
            _showDialog('Error', 'Error creating user!');
          }
        } catch (e) {
          setState(() {
            _isProcessing = false;
          });
          _showDialog(
              'Error', 'An unknown error occurred during user creation!');
        }
      } else {
        setState(() {
          _isProcessing = false;
        });
        _showDialog('Error',
            'Either the user already exists or the username or college ID is invalid!');
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showDialog('Error', 'An unknown error occurred!');
    }
  }

  void _showDialog(String title, String message, {VoidCallback? onClose}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (onClose != null) {
                onClose();
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 65),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Image(
                  image: AssetImage('assets/images/12.png'),
                  width: 220,
                  height: 220,
                ),
                const SizedBox(height: 35),
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      Colors.white70,
                      Colors.orangeAccent.shade100,
                      Colors.yellow.shade200,
                    ],
                  ).createShader(
                      Rect.fromLTWH(0.0, 0.0, bounds.width, bounds.height)),
                  child: const Text(
                    'Still waiting, just signup!',
                    style: TextStyle(
                      fontSize: 26.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 25),
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromARGB(255, 255, 235, 176),
                          Color.fromARGB(255, 244, 218, 140),
                          Color.fromARGB(255, 240, 206, 125),
                          Color.fromARGB(255, 243, 198, 93),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.white.withAlpha((0.3 * 255).toInt()),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _collegeIdController,
                          decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.account_balance,
                                  color: Colors.black87),
                              labelText: 'College ID',
                              labelStyle:
                                  const TextStyle(color: Colors.black87),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.black87),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.black87),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              errorStyle:
                                  const TextStyle(color: Colors.redAccent)),
                          style: const TextStyle(color: Colors.black),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'College ID is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _userNameController,
                          decoration: InputDecoration(
                            prefixIcon:
                                const Icon(Icons.person, color: Colors.black87),
                            labelText: 'Username',
                            labelStyle: const TextStyle(color: Colors.black87),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: Colors.black87),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: Colors.black87),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            errorStyle:
                                const TextStyle(color: Colors.redAccent),
                          ),
                          style: const TextStyle(color: Colors.black),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Username is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _passWordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            prefixIcon:
                                const Icon(Icons.lock, color: Colors.black87),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.black87,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            labelText: 'Password',
                            labelStyle: const TextStyle(color: Colors.black87),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: Colors.black87),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: Colors.black87),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            errorStyle:
                                const TextStyle(color: Colors.redAccent),
                          ),
                          style: const TextStyle(color: Colors.black),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Password is required';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_outline,
                                color: Colors.black87),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.black87,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                            labelText: 'Confirm Password',
                            labelStyle: const TextStyle(color: Colors.black87),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: Colors.black87),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: Colors.black87),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            errorStyle:
                                const TextStyle(color: Colors.redAccent),
                          ),
                          style: const TextStyle(color: Colors.black),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Confirm Password is required';
                            }
                            if (value != _passWordController.text.trim()) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_isProcessing) return;
                              _handleSignup(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isProcessing
                                  ? const Color.fromARGB(255, 221, 168, 23)
                                  : const Color.fromARGB(255, 231, 177, 30),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              shadowColor: Colors.black,
                              side: const BorderSide(
                                  width: 1.0,
                                  color: Color.fromARGB(255, 212, 150, 15)),
                              elevation: 8,
                            ),
                            child: _isProcessing
                                ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  )
                                : const Text(
                                    'Signup',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.black87),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(color: Colors.white70),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (_) => const StudentLogin()),
                        );
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
