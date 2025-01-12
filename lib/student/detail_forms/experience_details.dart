import 'dart:convert';

import 'package:elevate/api.dart';
import 'package:elevate/student/detail_forms/project_details.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:linear_progress_bar/linear_progress_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExperienceDetailsForm extends StatefulWidget {
  final int userId;
  const ExperienceDetailsForm({super.key, required this.userId});

  @override
  _ExperienceDetailsFormState createState() => _ExperienceDetailsFormState();
}

class _ExperienceDetailsFormState extends State<ExperienceDetailsForm> {
  bool _isProcessing = false;
  final List<Map<String, dynamic>> _experienceDetails = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _saveDetails(BuildContext context) async {
    setState(() {
      _isProcessing = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    try {
      final response = await http.post(
        Uri.parse('$api/experience/add-multiple/${widget.userId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(_experienceDetails),
      );

      setState(() {
        _isProcessing = false;
      });

      if (response.statusCode == 200) {
        if (context.mounted) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (_) => ProjectsDetailsForm(
                    userId: widget.userId,
                  )));
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
                currentStep: 3,
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
                    "3",
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
                  'Experience Details',
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
                        ..._experienceDetails.map(
                            (experience) => _buildExperienceCard(experience)),
                        const SizedBox(height: 20),
                        _buildExperienceForm(),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_experienceDetails.isEmpty) {
                                _showDialog('Error',
                                    'You must have at least one experience detail!');
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

  final TextEditingController roleController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController startMonthYearController =
      TextEditingController();
  final TextEditingController endMonthYearController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final ValueNotifier<bool> presentlyWorking = ValueNotifier<bool>(false);

  Widget _buildExperienceForm() {
    return Column(
      children: [
        _buildTextField('Role', Icons.work, controller: roleController),
        _buildTextField('Institution/Company Name', Icons.business,
            controller: companyController),
        Row(
          children: [
            Expanded(
              child: _buildTextField('Start (MM/YYYY)', Icons.date_range,
                  controller: startMonthYearController,
                  inputType: TextInputType.datetime),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ValueListenableBuilder<bool>(
                valueListenable: presentlyWorking,
                builder: (context, value, child) {
                  return value
                      ? const Text('Presently Working',
                          style: TextStyle(fontSize: 16, color: Colors.black))
                      : _buildTextField('End (MM/YYYY)', Icons.date_range,
                          controller: endMonthYearController,
                          inputType: TextInputType.datetime);
                },
              ),
            ),
          ],
        ),
        Row(
          children: [
            Checkbox(
              value: presentlyWorking.value,
              onChanged: (value) {
                setState(() {
                  presentlyWorking.value = value ?? false;
                  if (value == true) {
                    endMonthYearController.clear();
                  } else {
                    endMonthYearController.text = '';
                  }
                });
              },
            ),
            const Text(
              'Presently Working',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          ],
        ),
        _buildTextField('Description', Icons.description,
            controller: descriptionController,
            inputType: TextInputType.multiline),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                setState(() {
                  _experienceDetails.add({
                    'role': roleController.text,
                    'companyName': companyController.text,
                    'startDate': startMonthYearController.text,
                    'endDate': presentlyWorking.value
                        ? 'Present'
                        : endMonthYearController.text,
                    'description': descriptionController.text,
                  });
                  roleController.clear();
                  companyController.clear();
                  startMonthYearController.clear();
                  endMonthYearController.clear();
                  descriptionController.clear();
                  presentlyWorking.value = false;
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
              'Add Experience',
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
        keyboardType: inputType,
        style: const TextStyle(color: Colors.black),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label is required';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildExperienceCard(Map<String, dynamic> experience) {
    return Card(
      color: const Color.fromARGB(255, 255, 202, 122),
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.ads_click, size: 40, color: Colors.amber[800]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    experience['role'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${experience['companyName']}\n(${experience['startDate']} - ${experience['endDate']})\n${experience['description']}',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _experienceDetails.remove(experience);
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
