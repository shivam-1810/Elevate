// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:elevate/api.dart';
import 'package:elevate/student/home/base_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
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
        final imageBytes = data['personalDetails']['image'] != null
            ? base64Decode(data['personalDetails']['image'])
            : null;
        setState(
          () {
            if (imageBytes != null) {
              _selectedImage = null;
              _imageBytes = imageBytes;
            }
            _contactNumberController.text =
                data['personalDetails']['contactNumber'] ?? 'N/A';
            _emailController.text = data['personalDetails']['email'] ?? 'N/A';
            _linkedinController.text =
                data['personalDetails']['linkedInProfile'] ?? 'N/A';
            _websiteController.text =
                (data['personalDetails']['portfolio'] == "")
                    ? 'N/A'
                    : data['personalDetails']['portfolio'] ?? 'N/A';
            _fullNameController.text = data['personalDetails']['fullName'];
            _selectedBranch = data['personalDetails']['branch'];
            _rollNumberController.text = data['personalDetails']['rollNo'];
            _selectedGender = data['personalDetails']['gender'];
            _dobController.text =
                data['personalDetails']['dob'].toString().substring(0, 10);
            _addressController.text = data['personalDetails']['address'];
            _jobRoleController.text = data['personalDetails']['jobRole'];
          },
        );
      }
    } catch (e) {
      print("Internal server error: $e");
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
      final response = await http.put(
        Uri.parse('$api/personal-details/modify/${widget.userId}'),
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
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (context) => BasePage(userId: widget.userId)),
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
            mainAxisAlignment: MainAxisAlignment.center,
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
                              color:
                                  Colors.black.withAlpha((0.3 * 255).toInt()),
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
                        color: Colors.white.withAlpha((0.3 * 255).toInt()),
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
                                    'Save details',
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
        items: [
          'CSE',
          'ECE',
          'EEE',
          'Mechanical',
          'Civil',
          'Biotech',
        ]
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
}
