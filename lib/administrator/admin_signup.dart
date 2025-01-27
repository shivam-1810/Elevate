// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:elevate/administrator/base_page.dart';
import 'package:elevate/administrator/new_account.dart';
import 'package:elevate/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminSignup extends StatefulWidget {
  const AdminSignup({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AdminSignupState createState() => _AdminSignupState();
}

class _AdminSignupState extends State<AdminSignup> {
  bool _obscurePassword = true;
  bool _isProcessing = false;
  final TextEditingController _collegeIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> login() async {
    final String collegeId = _collegeIdController.text;
    final String adminPassword = _passwordController.text;

    setState(() {
      _isProcessing = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$api/college/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'collegeId': collegeId,
          'adminPassWord': adminPassword,
        }),
      );

      setState(() {
        _isProcessing = false;
      });

      if (response.statusCode == 202) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BasePage(collegeId: collegeId),
          ),
        );
      } else {
        _showDialog('Error', 'Incorrect College ID or Password!');
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showDialog('Error', 'Unknown error occured!');
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Image(
                image: AssetImage('assets/images/8.png'),
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 20),
              AnimatedTextKit(
                animatedTexts: [
                  TyperAnimatedText(
                    'Glad to see you back!',
                    textStyle: TextStyle(
                      fontSize: 26.0,
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                        ..shader = const LinearGradient(
                          colors: <Color>[
                            Colors.blueAccent,
                            Color.fromARGB(255, 119, 238, 223),
                            Color.fromARGB(255, 183, 139, 253)
                          ],
                        ).createShader(
                            const Rect.fromLTWH(0.0, 0.0, 500.0, 0.0)),
                    ),
                    speed: const Duration(milliseconds: 50),
                  ),
                ],
                totalRepeatCount: 1,
                pause: const Duration(milliseconds: 1000),
                displayFullTextOnTap: true,
              ),
              const SizedBox(height: 30),
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.shade200,
                        Colors.green.shade300,
                        Colors.green.shade400,
                        const Color.fromARGB(255, 43, 208, 112),
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
                      TextField(
                        controller: _collegeIdController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.account_balance,
                              color: Colors.black87),
                          labelText: 'College ID',
                          labelStyle: const TextStyle(color: Colors.black87),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black87),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black87),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                        keyboardType: TextInputType.text,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
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
                          labelText: 'Admin Password',
                          labelStyle: const TextStyle(color: Colors.black87),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black87),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black87),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_isProcessing) return;
                            if (_collegeIdController.text.isEmpty ||
                                _passwordController.text.isEmpty) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Alert"),
                                  content: const Text(
                                      "Enter both the fields for logging in!"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("OK"),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              login();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isProcessing
                                ? const Color.fromARGB(255, 4, 131, 57)
                                : const Color.fromARGB(255, 7, 137, 61),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            shadowColor: Colors.black,
                            side: const BorderSide(
                                width: 1.0,
                                color: Color.fromARGB(255, 7, 130, 58)),
                            elevation: 8,
                          ),
                          child: _isProcessing
                              ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                )
                              : Text(
                                  'Login',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.grey[50]),
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
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const NewAccount()),
                      );
                    },
                    child: const Text(
                      'Click here',
                      style: TextStyle(
                        color: Colors.lightBlueAccent,
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
    );
  }
}
