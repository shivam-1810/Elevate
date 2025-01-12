// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:elevate/api.dart';
import 'package:elevate/student/detail_forms/education_details.dart';
import 'package:elevate/student/home/base_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:linear_progress_bar/linear_progress_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PersonalDetailsForm extends StatefulWidget {
  final int userId;
  const PersonalDetailsForm({super.key, required this.userId});

  @override
  _PersonalDetailsFormState createState() => _PersonalDetailsFormState();
}

class _PersonalDetailsFormState extends State<PersonalDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dobController = TextEditingController();
  String? _selectedGender;
  String? _selectedBranch;
  bool _isProcessing = false;
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _linkedinController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _rollNumberController = TextEditingController();
  final TextEditingController _jobRoleController = TextEditingController();

  File? _selectedImage;
  Uint8List? _imageBytes;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _imageBytes = null;
      });
    }
  }

  Future<void> _uploadCollegeImage() async {
    if (_selectedImage == null) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('$api/personal-details/add-image'),
    );

    request.fields['userId'] = widget.userId.toString();
    request.files.add(
      await http.MultipartFile.fromPath('file', _selectedImage!.path),
    );
    request.headers['Authorization'] = 'Bearer $token';

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        print("Image uploaded successfully");
      } else {
        print("Failed to upload image");
      }
    } catch (e) {
      print("Error uploading image: $e");
    }
  }

  Future<void> _pickAndUploadImage() async {
    await _pickImage();
    _uploadCollegeImage();
  }

  Future<void> _submitForm(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    try {
      final response = await http.post(
        Uri.parse('$api/personal-details/add'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'user': {
            'userId': widget.userId,
          },
          'fullName': _fullNameController.text.trim(),
          'dob': _dobController.text.trim(),
          'gender': _selectedGender,
          'contactNumber': _contactNumberController.text.trim(),
          'email': _emailController.text.trim(),
          'address': _addressController.text.trim(),
          'linkedInProfile': _linkedinController.text.trim(),
          'portfolio': _websiteController.text.trim(),
          'branch': _selectedBranch,
          'rollNo': _rollNumberController.text.trim(),
          'jobRole': _jobRoleController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        if (_selectedImage != null) {
          await _uploadCollegeImage();
        }

        setState(() {
          _isProcessing = false;
        });

        if (context.mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) =>
                    EducationDetailsForm(userId: widget.userId)),
          );
        }
      } else {
        setState(() {
          _isProcessing = false;
        });
        _showDialog('Error',
            'An error occurred while submitting your details. Please try again later.');
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              LinearProgressBar(
                maxSteps: 7,
                progressType: LinearProgressBar.progressTypeLinear,
                currentStep: 1,
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
                    "1",
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
                  'Personal Details',
                  style: TextStyle(
                    fontSize: 26.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : (_imageBytes != null)
                            ? MemoryImage(_imageBytes!)
                            : null,
                    child: (_selectedImage == null && _imageBytes == null)
                        ? const Icon(Icons.person,
                            size: 70, color: Colors.black54)
                        : null,
                  ),
                  Positioned(
                    bottom: 5,
                    right: 5,
                    child: GestureDetector(
                      onTap: _pickAndUploadImage,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color.fromARGB(255, 215, 167, 105),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.add,
                          size: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ..._buildTextFields(),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_isProcessing) return;
                              _submitForm(context);
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
              )
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTextFields() {
    return [
      _buildTextField('Full Name', _fullNameController, Icons.person),
      _buildDatePicker(),
      _buildGenderDropdown(),
      _buildTextField('Contact Number', _contactNumberController, Icons.phone,
          inputType: TextInputType.phone),
      _buildTextField('Email Address', _emailController, Icons.email,
          inputType: TextInputType.emailAddress),
      _buildTextField('Address', _addressController, Icons.location_on,
          maxLines: 3),
      _buildTextField('LinkedIn Profile', _linkedinController, Icons.link,
          inputType: TextInputType.url),
      _buildTextField(
          'Personal Website or Portfolio URL', _websiteController, Icons.web,
          inputType: TextInputType.url),
      _buildBranchDropdown(),
      _buildTextField(
          'Roll Number', _rollNumberController, Icons.assignment_ind),
      _buildTextField(
          'Preferred Job Role', _jobRoleController, Icons.account_tree_rounded),
    ];
  }

  Widget _buildDatePicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: _dobController,
        readOnly: true,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.cake, color: Colors.black87),
          labelText: 'Date of Birth',
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
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (pickedDate != null) {
            setState(() {
              _dobController.text = "${pickedDate.toLocal()}".split(' ')[0];
            });
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Date of Birth is required';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField<String>(
        value: _selectedGender,
        iconEnabledColor: Colors.black87,
        dropdownColor: const Color.fromARGB(255, 249, 224, 149),
        items: ['Male', 'Female', 'Other']
            .map((gender) => DropdownMenuItem(
                  value: gender,
                  child:
                      Text(gender, style: const TextStyle(color: Colors.black)),
                ))
            .toList(),
        onChanged: (value) {
          setState(() {
            _selectedGender = value;
          });
        },
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.transgender, color: Colors.black87),
          labelText: 'Gender',
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
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Gender is required';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildBranchDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField<String>(
        value: _selectedBranch,
        iconEnabledColor: Colors.black87,
        dropdownColor: const Color.fromARGB(255, 249, 224, 149),
        items: ['CSE', 'ECE', 'EEE', 'Mechanical', 'Civil', 'Biotech']
            .map((branch) => DropdownMenuItem(
                  value: branch,
                  child:
                      Text(branch, style: const TextStyle(color: Colors.black)),
                ))
            .toList(),
        onChanged: (value) {
          setState(() {
            _selectedBranch = value;
          });
        },
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.school, color: Colors.black87),
          labelText: 'Branch',
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
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Branch is required';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon,
      {TextInputType inputType = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
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
          errorStyle: const TextStyle(color: Colors.redAccent),
        ),
        style: const TextStyle(color: Colors.black),
        keyboardType: inputType,
        maxLines: maxLines,
        validator: (value) {
          if (label == 'Personal Website or Portfolio URL') return null;
          if (value == null || value.isEmpty) {
            return '$label is required';
          }
          return null;
        },
      ),
    );
  }

  bool _education = false;
  bool _experience = false;
  bool _certification = false;
  bool _project = false;
  bool _creating = false;
  bool _personal = false;
  bool _skills = false;
  bool _links = false;

  Future<void> _shortcut(BuildContext context) async {
    setState(() {
      _creating = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');
    final List<Map<String, dynamic>> educationDetails = [
      {
        "institute": "N/A",
        "startYear": 0,
        "endYear": 0,
        "degree": "N/A",
        "fieldOfEducation": "N/A",
        "cgpa": 0
      }
    ];
    final List<Map<String, dynamic>> experienceDetails = [
      {
        "role": "N/A",
        "companyName": "N/A",
        "startDate": "N/A",
        "endDate": "N/A",
        "description": "N/A"
      }
    ];
    final List<Map<String, dynamic>> projectDetails = [
      {"title": "N/A", "date": "N/A", "description": "N/A"}
    ];
    final List<Map<String, dynamic>> certificationDetails = [
      {
        "title": "N/A",
        "date": "2025-06-01",
        "description": "N/A",
        "link": "N/A"
      }
    ];
    final List<String> skills = [];
    try {
      final response = await http.post(
        Uri.parse('$api/personal-details/add'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'user': {
            'userId': widget.userId,
          },
        }),
      );

      if (response.statusCode == 200) {
        _personal = true;
      } else {
        setState(() {
          _creating = false;
        });
        _showDialog('Error', 'Error occurred. Please try again later.');
        return;
      }
    } catch (e) {
      setState(() {
        _creating = false;
      });
      _showDialog('Error', 'An unknown error occurred!');
      return;
    }
    try {
      final response = await http.post(
        Uri.parse('$api/education/add-multiple/${widget.userId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(educationDetails),
      );
      if (response.statusCode == 200) {
        _education = true;
      } else {
        setState(() {
          _creating = false;
        });
        _showDialog("Error", 'Error occurred. Please try again later.');
        return;
      }
    } catch (e) {
      setState(() {
        _creating = false;
      });
      _showDialog("Error", "An unexpected error occurred.");
      return;
    }
    try {
      final response = await http.post(
        Uri.parse('$api/experience/add-multiple/${widget.userId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(experienceDetails),
      );
      if (response.statusCode == 200) {
        _experience = true;
      } else {
        setState(() {
          _creating = false;
        });
        _showDialog("Error", 'Error occurred. Please try again later.');
        return;
      }
    } catch (e) {
      setState(() {
        _creating = false;
      });
      _showDialog("Error", "An unexpected error occurred.");
      return;
    }
    try {
      final response = await http.post(
        Uri.parse('$api/project/add-multiple/${widget.userId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(projectDetails),
      );
      if (response.statusCode == 200) {
        _project = true;
      } else {
        setState(() {
          _creating = false;
        });
        _showDialog("Error", 'Error occurred. Please try again later.');
        return;
      }
    } catch (e) {
      setState(() {
        _creating = false;
      });
      _showDialog("Error", "An unexpected error occurred.");
      return;
    }
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
      final response = await http.post(
        Uri.parse('$api/skill-details/add-multiple/${widget.userId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(skills),
      );
      if (response.statusCode == 200) {
        _skills = true;
      } else {
        setState(() {
          _creating = false;
        });
        _showDialog("Error", 'Error occurred. Please try again later.');
        return;
      }
    } catch (e) {
      setState(() {
        _creating = false;
      });
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

    if (_education &&
        _certification &&
        _experience &&
        _project &&
        _personal &&
        _skills &&
        _links &&
        context.mounted) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => BasePage(userId: widget.userId)));
    }
  }
}
