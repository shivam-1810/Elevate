import 'dart:convert';

import 'package:elevate/api.dart';
import 'package:elevate/student/home/base_page.dart';
import 'package:elevate/student/student_signup.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class StudentLogin extends StatefulWidget {
  const StudentLogin({super.key});

  @override
  _StudentLoginState createState() => _StudentLoginState();
}

class _StudentLoginState extends State<StudentLogin> {
  bool _obscurePassword = true;
  bool _isProcessing = false;
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passWordController = TextEditingController();
  final TextEditingController _collegeIdController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _handleLogin(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userName': _userNameController.text.trim(),
          'passWord': _passWordController.text.trim(),
          'college': {'collegeId': _collegeIdController.text.trim()},
        }),
      );

      if (response.statusCode == 202) {
        final responseData = jsonDecode(response.body);
        final userId = responseData['userId'];
        final token = responseData['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', token);
        await prefs.setInt('userId', userId);
        setState(() {
          _isProcessing = false;
        });
        if (context.mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BasePage(userId: userId),
            ),
          );
        }
      } else {
        setState(() {
          _isProcessing = false;
        });
        _showDialog('Error', 'Incorrect Username, College ID, or Password!');
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
                  image: AssetImage('assets/images/11.png'),
                  width: 220,
                  height: 220,
                ),
                const SizedBox(height: 45),
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
                    'Welcome back, let\'s continue!',
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
                              return 'Please enter your College ID.';
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
                              return 'Please enter your Username.';
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
                              return 'Please enter your Password.';
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
                              _handleLogin(context);
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
                                    'Login',
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
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.white70),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (_) => const StudentSignup()),
                        );
                      },
                      child: const Text(
                        'Signup',
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
