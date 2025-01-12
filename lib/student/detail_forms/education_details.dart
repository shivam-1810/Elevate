import 'dart:convert';

import 'package:elevate/api.dart';
import 'package:elevate/student/detail_forms/experience_details.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:linear_progress_bar/linear_progress_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EducationDetailsForm extends StatefulWidget {
  final int userId;
  const EducationDetailsForm({super.key, required this.userId});

  @override
  _EducationDetailsFormState createState() => _EducationDetailsFormState();
}

class _EducationDetailsFormState extends State<EducationDetailsForm> {
  bool _isProcessing = false;
  final List<Map<String, dynamic>> _educationDetails = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _saveDetails(BuildContext context) async {
    setState(() {
      _isProcessing = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    try {
      final response = await http.post(
        Uri.parse('$api/education/add-multiple/${widget.userId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(_educationDetails),
      );

      setState(() {
        _isProcessing = false;
      });

      if (response.statusCode == 200) {
        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (_) => ExperienceDetailsForm(
                      userId: widget.userId,
                    )),
          );
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
                currentStep: 2,
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
                    "2",
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
                  'Education Details',
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
                        ..._educationDetails
                            .map((education) => _buildEducationCard(education)),
                        const SizedBox(height: 20),
                        _buildEducationForm(),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_educationDetails.isEmpty) {
                                _showDialog('Error',
                                    'You must have at least one education detail!');
                                return;
                              }
                              if (_isProcessing) return;
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

  Widget _buildEducationForm() {
    final TextEditingController instituteController = TextEditingController();
    final TextEditingController startYearController = TextEditingController();
    final TextEditingController endYearController = TextEditingController();
    final TextEditingController degreeController = TextEditingController();
    final TextEditingController fieldController = TextEditingController();
    final TextEditingController cgpaController = TextEditingController();

    return Column(
      children: [
        _buildTextField('Institute', Icons.school,
            controller: instituteController),
        Row(
          children: [
            Expanded(
              child: _buildTextField('Start Year', Icons.date_range,
                  controller: startYearController,
                  inputType: TextInputType.number),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildTextField('End Year', Icons.date_range,
                  controller: endYearController,
                  inputType: TextInputType.number),
            ),
          ],
        ),
        _buildTextField('Degree', Icons.book, controller: degreeController),
        _buildTextField('Field of Education', Icons.category,
            controller: fieldController),
        _buildTextField('CGPA', Icons.grade,
            controller: cgpaController, inputType: TextInputType.number),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                setState(() {
                  _educationDetails.add({
                    'institute': instituteController.text,
                    'startYear': startYearController.text,
                    'endYear': endYearController.text,
                    'degree': degreeController.text,
                    'fieldOfEducation': fieldController.text,
                    'cgpa': cgpaController.text,
                  });
                  instituteController.clear();
                  startYearController.clear();
                  endYearController.clear();
                  degreeController.clear();
                  fieldController.clear();
                  cgpaController.clear();
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 231, 177, 30),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Add Education',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, IconData icon,
      {TextEditingController? controller,
      TextInputType inputType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.black87),
            labelText: label,
            labelStyle: const TextStyle(color: Colors.black87),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black87),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black87),
              borderRadius: BorderRadius.circular(10),
            ),
            errorStyle: const TextStyle(color: Colors.redAccent)),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label is required';
          }
          return null;
        },
        keyboardType: inputType,
        style: const TextStyle(color: Colors.black),
      ),
    );
  }

  Widget _buildEducationCard(Map<String, dynamic> education) {
    return Card(
      color: const Color.fromARGB(255, 250, 229, 150),
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.school, size: 40, color: Colors.amber[800]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${education['degree']} in ${education['fieldOfEducation']}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${education['institute']}\n(${education['startYear']} - ${education['endYear']})',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'CGPA: ${education['cgpa']}',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _educationDetails.remove(education);
                });
              },
              icon: const Icon(Icons.delete, color: Colors.redAccent),
            ),
          ],
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
