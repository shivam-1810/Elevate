// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:elevate/api.dart';
import 'package:elevate/student/home/base_page.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class AdditionalLinksForm extends StatefulWidget {
  final int userId;
  const AdditionalLinksForm({super.key, required this.userId});

  @override
  _AdditionalLinksFormState createState() => _AdditionalLinksFormState();
}

class _AdditionalLinksFormState extends State<AdditionalLinksForm> {
  bool _isProcessing = false;
  List<TextEditingController> _linkControllers = [TextEditingController()];
  File? _uploadedResume;

  @override
  void dispose() {
    for (var controller in _linkControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _getStudentDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');
    try {
      final response = await http.get(
        Uri.parse('$api/student-details/${widget.userId}'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(
          () {
            _linkControllers = data['additionalDetails'] != null
                ? ((data['additionalDetails']['additionalLinks'] as List?)
                        ?.map((e) => TextEditingController(text: e.toString()))
                        .toList() ??
                    [])
                : [TextEditingController()];
          },
        );
      }
    } catch (e) {
      print("Internal server error: $e");
    }
  }

  Future<void> _saveDetails(BuildContext context) async {
    setState(() {
      _isProcessing = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');
    bool isLinksSaved = false;
    bool isResumeUploaded = false;

    try {
      var linksResponse = await http.put(
        Uri.parse('$api/additional-details/modify/${widget.userId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          _linkControllers.map((controller) => controller.text.trim()).toList(),
        ),
      );

      if (linksResponse.statusCode == 200) {
        isLinksSaved = true;
        print('links passed');
        if (_uploadedResume != null) {
          var request = http.MultipartRequest(
            'POST',
            Uri.parse('$api/additional-details/${widget.userId}/upload-resume'),
          );
          request.headers.addAll({
            'Authorization': 'Bearer $token',
          });
          request.files.add(
            http.MultipartFile.fromBytes(
              'file',
              await _uploadedResume!.readAsBytes(),
              filename: _uploadedResume!.path.split('/').last,
              contentType: MediaType('application', 'pdf'),
            ),
          );

          var resumeResponse = await request.send();

          if (resumeResponse.statusCode == 200) {
            isResumeUploaded = true;
          } else {
            print('file uploaded');
            _showDialog("Error", 'Failed to upload resume. Please try again.');
          }
        } else {
          isResumeUploaded = true;
        }
      } else {
        _showDialog("Error", 'Failed to save links. Please try again.');
      }
    } catch (e) {
      _showDialog("Error", "An unexpected error occurred.");
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
    if (isLinksSaved && isResumeUploaded && context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BasePage(userId: widget.userId),
        ),
      );
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

  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      setState(() {
        _uploadedResume = File(result.files.single.path!);
      });
    }
  }

  void _removeFile() {
    setState(() {
      _uploadedResume = null;
    });
  }

  void _addLinkField() {
    setState(() {
      _linkControllers.add(TextEditingController());
    });
  }

  void _removeLinkField(int index) {
    setState(() {
      _linkControllers.removeAt(index);
    });
  }

  @override
  void initState() {
    super.initState();
    _getStudentDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 50),
          child: Column(
            children: [
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
                  'Additional Links & Resume',
                  style: TextStyle(
                    fontSize: 26.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),
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
                    children: [
                      ..._buildLinkFields(),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: _addLinkField,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 231, 177, 30),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.add, color: Colors.black),
                        label: const Text(
                          'Add Link',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _pickFile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 231, 177, 30),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon:
                            const Icon(Icons.attach_file, color: Colors.black),
                        label: Text(
                          _uploadedResume == null
                              ? 'Upload Resume'
                              : 'Replace Resume',
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                      if (_uploadedResume != null)
                        ListTile(
                          title: Text(
                            _uploadedResume!.path.split('/').last,
                            style: const TextStyle(color: Colors.black),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.close, color: Colors.black),
                            onPressed: _removeFile,
                          ),
                        ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
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
                          ),
                          child: _isProcessing
                              ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                )
                              : const Text(
                                  'Save Details',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.black87),
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

  List<Widget> _buildLinkFields() {
    return List<Widget>.generate(
      _linkControllers.length,
      (index) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _linkControllers[index],
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.link, color: Colors.black87),
                  labelText: 'Link ${index + 1}',
                  labelStyle: const TextStyle(color: Colors.black87),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black87),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black87),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  hintStyle: const TextStyle(color: Colors.black54),
                ),
                keyboardType: TextInputType.url,
                style: const TextStyle(color: Colors.black),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.black87),
              onPressed: () => _removeLinkField(index),
            ),
          ],
        ),
      ),
    );
  }
}
