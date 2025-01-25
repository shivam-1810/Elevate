// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:typed_data';

import 'package:elevate/api.dart';
import 'package:elevate/viewableProfile/components/additional_links.dart';
import 'package:elevate/viewableProfile/components/certifications.dart';
import 'package:elevate/viewableProfile/components/contact_details.dart';

import 'package:elevate/viewableProfile/components/education.dart';
import 'package:elevate/viewableProfile/components/experiences.dart';
import 'package:elevate/viewableProfile/components/projects.dart';
import 'package:elevate/viewableProfile/components/skill_details.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ViewableProfile extends StatefulWidget {
  final int userId;
  final String viewerRole;
  const ViewableProfile(
      {super.key, required this.userId, required this.viewerRole});

  @override
  _ViewableProfileState createState() => _ViewableProfileState();
}

class _ViewableProfileState extends State<ViewableProfile> {
  String? authToken;
  String contactNumber = 'N/A';
  String email = 'N/A';
  String linkedinProfile = 'N/A';
  String portfolio = 'N/A';
  String? fullName;
  String? branch;
  String? rollNo;
  String? gender;
  String? dob;
  String? address;
  String? jobRole;
  String? base64Resume;
  Uint8List? _imageBytes;

  List<Map<String, String>> educationDetails = [];
  List<Map<String, String>> skillDetails = [];
  List<Map<String, String>> certificateDetails = [];
  List<Map<String, String>> projectDetails = [];
  List<Map<String, String>> experienceDetails = [];
  List<String> links = [];
  bool _isRecruitmentConfirmed = false;

  Future<void> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      authToken = prefs.getString('authToken');
    });
  }

  Future<void> _getStudentDetails() async {
    try {
      final response = await http.get(
        Uri.parse('$api/student-details/${widget.userId}'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final imageBytes = data['personalDetails']['image'] != null
            ? base64Decode(data['personalDetails']['image'])
            : null;
        setState(
          () {
            _imageBytes = imageBytes;
            contactNumber = data['personalDetails']['contactNumber'] ?? 'N/A';
            email = data['personalDetails']['email'] ?? 'N/A';
            linkedinProfile =
                data['personalDetails']['linkedInProfile'] ?? 'N/A';
            portfolio = (data['personalDetails']['portfolio'] == "")
                ? 'N/A'
                : data['personalDetails']['portfolio'] ?? 'N/A';
            fullName = data['personalDetails']['fullName'];
            branch = data['personalDetails']['branch'];
            rollNo = data['personalDetails']['rollNo'];
            gender = data['personalDetails']['gender'];
            dob = data['personalDetails']['dob'] != null &&
                    data['personalDetails']['dob'].toString().length >= 10
                ? data['personalDetails']['dob'].toString().substring(0, 10)
                : 'N/A';
            address = data['personalDetails']['address'];
            jobRole = data['personalDetails']['jobRole'];
            _isRecruitmentConfirmed = data['personalDetails']['placed'];

            educationDetails = data['educationDetails'] != null
                ? (data['educationDetails']['educations'] as List)
                    .map<Map<String, String>>((e) => {
                          'degree': e['degree']?.toString() ?? 'N/A',
                          'field': e['fieldOfEducation']?.toString() ?? 'N/A',
                          'startYear': e['startYear']?.toString() ?? 'N/A',
                          'endYear': e['endYear']?.toString() ?? 'N/A',
                          'institute': e['institute']?.toString() ?? 'N/A',
                          'cgpa': e['cgpa']?.toString() ?? 'N/A',
                        })
                    .toList()
                : [];

            experienceDetails = data['experienceDetails'] != null
                ? (data['experienceDetails']['experiences'] as List)
                    .map<Map<String, String>>((e) => {
                          'role': e['role']?.toString() ?? 'N/A',
                          'company': e['companyName']?.toString() ?? 'N/A',
                          'startDate': e['startDate']?.toString() ?? 'N/A',
                          'endDate': e['endDate']?.toString() ?? 'N/A',
                          'description': e['description']?.toString() ?? 'N/A',
                        })
                    .toList()
                : [];

            projectDetails = data['projectDetails'] != null
                ? (data['projectDetails']['projects'] as List)
                    .map<Map<String, String>>((e) => {
                          'title': e['title']?.toString() ?? 'N/A',
                          'description': e['description']?.toString() ?? 'N/A',
                          'completionDate': e['date']?.toString() ?? 'N/A',
                        })
                    .toList()
                : [];

            certificateDetails = data['certificationDetails'] != null
                ? (data['certificationDetails']['certifications'] as List)
                    .map<Map<String, String>>((e) => {
                          'title': e['title']?.toString() ?? 'N/A',
                          'description': e['description']?.toString() ?? 'N/A',
                          'dateOfCertification':
                              e['date']?.toString().substring(0, 10) ?? 'N/A',
                          'link': e['link']?.toString() ?? 'N/A',
                        })
                    .toList()
                : [];

            skillDetails = data['skillDetails'] != null
                ? (data['skillDetails']['skills'] as List)
                    .map<Map<String, String>>((e) => {
                          'skillName': e.toString(),
                        })
                    .toList()
                : [];

            links = data['additionalLinks'] != null
                ? ((data['additionalDetails']['additionalLinks'] as List?)
                        ?.map((e) => e.toString())
                        .toList() ??
                    [])
                : [];
            base64Resume = data['additionalDetails']?['resume'] ?? '';
          },
        );
      }
    } catch (e) {
      print("Internal server error: $e");
    }
  }

  Future<void> onViewResume() async {
    if (base64Resume == null || base64Resume!.isEmpty) {
      _showDialog('Error', 'No resume uploaded by the user..!');
      return;
    }

    try {
      Uint8List bytes = base64Decode(base64Resume!);
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/resume.pdf';
      File file = File(filePath);
      await file.writeAsBytes(bytes);
      await OpenFile.open(filePath);
    } catch (e) {
      print("Error opening resume: $e");
    }
  }

  void _initializePage() async {
    await _getAuthToken();
    await _getStudentDetails();
  }

  Future<void> _togglePlacementStatus() async {
    try {
      final response = await http.put(
        Uri.parse('$api/student-details/isPlaced?userId=${widget.userId}'),
      );

      if (response.statusCode != 200) {
        _showDialog('Error', 'Error, Please try again later!');
      }
    } catch (e) {
      _showDialog('Error', 'Error, Please try again later!');
    }
  }

  @override
  void initState() {
    super.initState();
    _initializePage();
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
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E2C),
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  MainCard(
                    image: _imageBytes,
                    fullName: fullName ?? 'N/A',
                    branch: branch ?? 'N/A',
                    rollNo: rollNo ?? 'N/A',
                    gender: gender ?? 'N/A',
                    dob: dob ?? 'N/A',
                    address: address ?? 'N/A',
                    jobRole: jobRole ?? 'N/A',
                  ),
                  const SizedBox(height: 16),
                  EducationDetailsCard(educationDetails: educationDetails),
                  const SizedBox(height: 16),
                  WorkExperienceDetailsCard(
                      workExperienceDetails: experienceDetails),
                  const SizedBox(height: 16),
                  ProjectDetailsCard(projectDetails: projectDetails),
                  const SizedBox(height: 16),
                  CertificateDetailsCard(
                      certificateDetails: certificateDetails),
                  const SizedBox(height: 16),
                  SkillDetailsCard(skillDetails: skillDetails),
                  const SizedBox(height: 16),
                  ContactDetailsCard(
                    contactNumber: contactNumber,
                    email: email,
                    portfolio: portfolio,
                    linkedinProfile: linkedinProfile,
                  ),
                  AdditionalLinksCard(links: links, onViewResume: onViewResume),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (!_isRecruitmentConfirmed) ...[
              if (widget.viewerRole != 'Student' &&
                  widget.viewerRole != 'Admin')
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Are you recruiting this student?",
                      style: const TextStyle(fontSize: 16.0),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        _showConfirmationDialog(context, () {
                          setState(() {
                            _isRecruitmentConfirmed = true;
                          });
                          _togglePlacementStatus();
                        });
                      },
                      child: Text(
                        "Yes",
                        style: TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
            ] else ...[
              if (widget.viewerRole != 'Student' &&
                  widget.viewerRole != 'Recruiter')
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Showing wrong?",
                      style: const TextStyle(fontSize: 15.0),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        _showConfirmationDialog(context, () {
                          setState(() {
                            _isRecruitmentConfirmed = false;
                          });
                          _togglePlacementStatus();
                        });
                      },
                      child: Text(
                        "Set unplaced",
                        style: TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
            ]
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmation"),
          content: const Text(
            "Are you sure? This action can't be undone.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              child: const Text(
                "Yes",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}

class MainCard extends StatefulWidget {
  final Uint8List? image;
  final String fullName;
  final String branch;
  final String rollNo;
  final String gender;
  final String dob;
  final String address;
  final String jobRole;

  const MainCard(
      {super.key,
      required this.image,
      required this.fullName,
      required this.branch,
      required this.rollNo,
      required this.gender,
      required this.dob,
      required this.address,
      required this.jobRole});

  @override
  State<MainCard> createState() => _MainCardState();
}

class _MainCardState extends State<MainCard> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 164, 219, 232),
              Color.fromARGB(255, 97, 187, 207),
              Color.fromARGB(255, 54, 145, 175),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 75,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: widget.image != null
                        ? MemoryImage(widget.image!)
                        : null,
                    child: widget.image == null
                        ? const Icon(Icons.person,
                            size: 75, color: Colors.black54)
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                widget.fullName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              const Divider(color: Colors.black45, thickness: 1),
              const SizedBox(height: 10),
              _buildField('Branch', widget.branch),
              _buildField('Roll no.', widget.rollNo),
              _buildField('Gender', widget.gender),
              _buildField('D.O.B', widget.dob),
              _buildField('Address', widget.address),
              _buildField(
                'Preferred Job',
                widget.jobRole,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            width: 50,
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
              ),
              textAlign: TextAlign.right,
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }
}
