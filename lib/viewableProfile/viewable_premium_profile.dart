// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:typed_data';

import 'package:elevate/api.dart';
import 'package:elevate/viewableProfile/components/certifications.dart';
import 'package:elevate/viewableProfile/components/education.dart';
import 'package:elevate/viewableProfile/components/experiences.dart';
import 'package:elevate/viewableProfile/components/projects.dart';
import 'package:elevate/viewableProfile/components/skill_details.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

class ViewablePremiumProfile extends StatefulWidget {
  final int userId;
  const ViewablePremiumProfile({super.key, required this.userId});

  @override
  _ViewablePremiumProfileState createState() => _ViewablePremiumProfileState();
}

class _ViewablePremiumProfileState extends State<ViewablePremiumProfile> {
  String? authToken;
  String? fullName;
  String? branch;
  String? rollNo;
  String? gender;
  String? dob;
  String? address;
  String? jobRole;
  Uint8List? _imageBytes;

  List<Map<String, String>> educationDetails = [];
  List<Map<String, String>> skillDetails = [];
  List<Map<String, String>> certificateDetails = [];
  List<Map<String, String>> projectDetails = [];
  List<Map<String, String>> experienceDetails = [];
  List<String> links = [];

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
          },
        );
      }
    } catch (e) {
      print("Internal server error: $e");
    }
  }

  void _initializePage() async {
    await _getAuthToken();
    await _getStudentDetails();
  }

  @override
  void initState() {
    super.initState();
    _initializePage();
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
            WorkExperienceDetailsCard(workExperienceDetails: experienceDetails),
            const SizedBox(height: 16),
            ProjectDetailsCard(projectDetails: projectDetails),
            const SizedBox(height: 16),
            CertificateDetailsCard(certificateDetails: certificateDetails),
            const SizedBox(height: 16),
            SkillDetailsCard(skillDetails: skillDetails),
            const SizedBox(height: 16),
          ],
        ),
      ),
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
