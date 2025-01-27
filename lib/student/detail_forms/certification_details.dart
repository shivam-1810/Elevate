import 'dart:convert';
import 'package:elevate/student/home/base_page.dart';
import 'package:intl/intl.dart';
import 'package:elevate/api.dart';
import 'package:elevate/student/detail_forms/additional_links.dart';
import 'package:flutter/material.dart';
import 'package:linear_progress_bar/linear_progress_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CertificationsDetailsForm extends StatefulWidget {
  final int userId;
  const CertificationsDetailsForm({super.key, required this.userId});

  @override
  _CertificationsDetailsFormState createState() =>
      _CertificationsDetailsFormState();
}

class _CertificationsDetailsFormState extends State<CertificationsDetailsForm> {
  final List<Map<String, dynamic>> _certificationsDetails = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController linkController = TextEditingController();

  Future<void> _saveDetails(BuildContext context) async {
    setState(() {
      _isProcessing = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    try {
      final response = await http.post(
        Uri.parse('$api/certification/add-multiple/${widget.userId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(_certificationsDetails),
      );

      setState(() {
        _isProcessing = false;
      });

      if (response.statusCode == 200) {
        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => AdditionalLinksForm(
                userId: widget.userId,
              ),
            ),
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

  String formatDate(String inputDate) {
    final inputFormat = DateFormat('MM/dd/yyyy');
    final outputFormat = DateFormat('yyyy-MM-dd');
    final date = inputFormat.parse(inputDate);
    return outputFormat.format(date);
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
                currentStep: 6,
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
                    "6",
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
                  'Certifications Details',
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
                        color: Colors.white.withAlpha((0.3 * 255).toInt()),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        ..._certificationsDetails.map((certification) =>
                            _buildCertificationCard(certification)),
                        const SizedBox(height: 20),
                        _buildCertificationForm(),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_certificationsDetails.isEmpty) {
                                _showDialog('Error',
                                    'You must have at least one certification!');
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
              const SizedBox(height: 20),
              const Text(
                "Wanna fill the details later?",
                style: TextStyle(color: Colors.white60, fontSize: 15),
              ),
              GestureDetector(
                onTap: () {
                  _shortcut(context);
                },
                child: _creating
                    ? const CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                      )
                    : const Text(
                        "Click here to skip!",
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCertificationForm() {
    return Column(
      children: [
        _buildTextField('Certification Title', Icons.title,
            controller: titleController),
        _buildDatePickerField(),
        _buildTextField(
          'Description',
          Icons.description,
          controller: descriptionController,
          inputType: TextInputType.multiline,
        ),
        _buildTextField(
          'Link (Optional)',
          Icons.link,
          controller: linkController,
          inputType: TextInputType.url,
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                setState(() {
                  _certificationsDetails.add({
                    'title': titleController.text,
                    'date': formatDate(dateController.text),
                    'description': descriptionController.text,
                    'link': linkController.text.isNotEmpty
                        ? linkController.text
                        : 'N/A',
                  });
                  titleController.clear();
                  dateController.clear();
                  descriptionController.clear();
                  linkController.clear();
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
              'Add Certification',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, IconData icon,
      {TextEditingController? controller,
      TextInputType inputType = TextInputType.text,
      String? hintText}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black87),
          labelText: label,
          hintText: hintText,
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
        keyboardType: inputType,
        style: const TextStyle(color: Colors.black),
        validator: (value) {
          if (label != 'Link (Optional)' && (value == null || value.isEmpty)) {
            return '$label is required';
          }
          return null;
        },
        maxLines: inputType == TextInputType.multiline ? 3 : 1,
      ),
    );
  }

  Widget _buildDatePickerField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: dateController,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.calendar_today, color: Colors.black87),
          labelText: 'Date',
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
        style: const TextStyle(color: Colors.black),
        onTap: () async {
          FocusScope.of(context).requestFocus(FocusNode());
          final selectedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (selectedDate != null) {
            dateController.text =
                "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Date is required';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildCertificationCard(Map<String, dynamic> certification) {
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
            Icon(Icons.badge, size: 40, color: Colors.amber[800]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    certification['title'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${certification['date']}\n${certification['description']}\nLink: ${certification['link']}',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _certificationsDetails.remove(certification);
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

  bool _certification = false;
  bool _creating = false;
  bool _links = false;

  Future<void> _shortcut(BuildContext context) async {
    setState(() {
      _creating = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');
    final List<Map<String, dynamic>> certificationDetails = [
      {
        "title": "N/A",
        "date": "2025-06-01",
        "description": "N/A",
        "link": "N/A"
      }
    ];

    try {
      final response = await http.post(
        Uri.parse('$api/certification/add-multiple/${widget.userId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(certificationDetails),
      );
      if (response.statusCode == 200) {
        _certification = true;
      } else {
        _showDialog("Error", 'Error occurred. Please try again later.');
        return;
      }
    } catch (e) {
      _showDialog("Error", "An unexpected error occurred.");
      return;
    }
    try {
      var linksResponse = await http.post(
        Uri.parse('$api/additional-details/add/${widget.userId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          [],
        ),
      );

      if (linksResponse.statusCode == 200) {
        _links = true;
      } else {
        _showDialog("Error", "Error occurred. Please try again later.");
      }
    } catch (e) {
      _showDialog("Error", "An unexpected error occurred.");
    }
    setState(() {
      _creating = false;
    });

    if (_certification && _links && context.mounted) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => BasePage(userId: widget.userId)));
    }
  }
}
