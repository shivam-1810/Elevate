// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:elevate/api.dart';
import 'package:elevate/recruiter/base_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

bool viewOnly = false;

class RecruiterLogin extends StatefulWidget {
  const RecruiterLogin({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RecruiterLoginState createState() => _RecruiterLoginState();
}

class _RecruiterLoginState extends State<RecruiterLogin> {
  final TextEditingController _collegeIdController = TextEditingController();
  final TextEditingController _recruiterIdController = TextEditingController();

  void _showMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Alert"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _doesCollegeExist(BuildContext context) async {
    String collegeId = _collegeIdController.text;
    try {
      final response = await http.get(
        Uri.parse('$api/college/exists?collegeId=$collegeId'),
      );
      if (response.statusCode == 200) {
        viewOnly = true;
        if (context.mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BasePage(collegeId: _collegeIdController.text),
            ),
          );
        }
      } else {
        _showMessage('No college exists with entered College ID!');
        print("Error ${response.statusCode}");
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _handleLogin(BuildContext context) async {
    String collegeId = _collegeIdController.text;
    String recruiterId = _recruiterIdController.text;
    try {
      final response = await http.post(
        Uri.parse('$api/recruiter/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'college': {"collegeId": collegeId},
          'recruiterId': recruiterId,
        }),
      );

      if (response.statusCode == 202) {
        viewOnly = false;
        if (context.mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BasePage(
                collegeId: collegeId,
              ),
            ),
          );
        }
      } else {
        _showMessage("Error : ${response.body}");
      }
    } catch (e) {
      _showMessage('Unknown error occured!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 65),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Image(
                image: AssetImage('assets/images/13.png'),
                width: 240,
                height: 240,
              ),
              const SizedBox(height: 45),
              AnimatedTextKit(
                animatedTexts: [
                  TyperAnimatedText(
                    'Hey there, Welcome!',
                    textStyle: TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                        ..shader = LinearGradient(
                          colors: <Color>[
                            Colors.blueAccent.shade100,
                            Colors.deepPurple.shade200,
                            Colors.purpleAccent.shade100
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
              const SizedBox(height: 25),
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 176, 200, 255),
                        Color.fromARGB(255, 140, 163, 244),
                        Color.fromARGB(255, 125, 145, 240),
                        Color.fromARGB(255, 93, 123, 243),
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
                          prefixIcon:
                              const Icon(Icons.school, color: Colors.black87),
                          labelText: 'Enter College ID',
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
                        controller: _recruiterIdController,
                        decoration: InputDecoration(
                          prefixIcon:
                              const Icon(Icons.person, color: Colors.black87),
                          labelText: 'Enter Recruiter ID',
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
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_collegeIdController.text.isEmpty ||
                                _recruiterIdController.text.isEmpty) {
                              _showMessage(
                                  'Both fields are required for login.');
                            } else {
                              _handleLogin(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 84, 113, 230),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            shadowColor: Colors.black,
                            side: const BorderSide(
                                width: 1.0,
                                color: Color.fromARGB(255, 76, 100, 220)),
                            elevation: 8,
                          ),
                          child: const Text(
                            'Login',
                            style:
                                TextStyle(fontSize: 18, color: Colors.black87),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_collegeIdController.text.isEmpty) {
                              _showMessage(
                                  'Please enter a College ID to view details.');
                            } else {
                              _doesCollegeExist(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 84, 113, 230),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            shadowColor: Colors.black,
                            side: const BorderSide(
                                width: 1.0,
                                color: Color.fromARGB(255, 76, 100, 220)),
                            elevation: 8,
                          ),
                          child: const Text(
                            'View Without Login',
                            style:
                                TextStyle(fontSize: 18, color: Colors.black87),
                          ),
                        ),
                      ),
                    ],
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
