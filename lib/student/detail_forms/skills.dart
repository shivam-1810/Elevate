import 'dart:convert';

import 'package:elevate/api.dart';
import 'package:elevate/student/detail_forms/certification_details.dart';
import 'package:flutter/material.dart';
import 'package:linear_progress_bar/linear_progress_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SkillsDetailsForm extends StatefulWidget {
  final int userId;
  const SkillsDetailsForm({super.key, required this.userId});

  @override
  _SkillsDetailsFormState createState() => _SkillsDetailsFormState();
}

class _SkillsDetailsFormState extends State<SkillsDetailsForm> {
  final List<String> _skills = [];
  bool _isProcessing = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController skillController = TextEditingController();

  Future<void> _saveDetails(BuildContext context) async {
    setState(() {
      _isProcessing = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    try {
      final response = await http.post(
        Uri.parse('$api/skill-details/add-multiple/${widget.userId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(_skills),
      );

      setState(() {
        _isProcessing = false;
      });

      if (response.statusCode == 200) {
        if (context.mounted) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => CertificationsDetailsForm(
              userId: widget.userId,
            ),
          ));
        }
      } else {
        _showDialog("Error", 'Error occurred. Please try again later.');
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showDialog("Error", "An unexpected error occurred.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              LinearProgressBar(
                maxSteps: 7,
                progressType: LinearProgressBar.progressTypeLinear,
                currentStep: 5,
                progressColor: Colors.amber,
                backgroundColor: Colors.grey,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Page ", style: TextStyle(fontSize: 15)),
                  const Text(
                    "5",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber),
                  ),
                  const Text(" of ", style: TextStyle(fontSize: 15)),
                  const Text(
                    "7",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber),
                  )
                ],
              ),
              const SizedBox(height: 28),
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
                  'Skills Details',
                  style: TextStyle(
                    fontSize: 26.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),
              Form(
                key: _formKey,
                child: ClipRRect(
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
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildSkillForm(),
                        const SizedBox(height: 20),
                        ..._skills.map((skill) => _buildSkillChip(skill)),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState?.validate() ?? false) {
                                setState(() {
                                  _skills.add(skillController.text);
                                  skillController.clear();
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 231, 177, 30),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Add Skill',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.black),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_skills.isEmpty) {
                                _showDialog('Error',
                                    'You must have at least one skill!');
                                return;
                              }
                              _saveDetails(context);
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
                                    'Submit',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.black87),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkillForm() {
    return TextFormField(
      controller: skillController,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.code, color: Colors.black87),
        labelText: 'Skill',
        hintText: 'Enter your skill',
        hintStyle: const TextStyle(fontSize: 14, color: Colors.black54),
        labelStyle: const TextStyle(color: Colors.black87),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black87),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black87),
          borderRadius: BorderRadius.circular(10),
        ),
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
      keyboardType: TextInputType.text,
      style: const TextStyle(color: Colors.black),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Skill is required';
        }
        return null;
      },
    );
  }

  Widget _buildSkillChip(String skill) {
    return Card(
      color: const Color.fromARGB(255, 255, 202, 122),
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(Icons.computer, color: Colors.black87),
        title: Text(
          skill,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () {
            setState(() {
              _skills.remove(skill);
            });
          },
        ),
      ),
    );
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
}
