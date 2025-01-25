// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:elevate/administrator/components/student_row.dart';
import 'package:elevate/api.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AdminHome extends StatefulWidget {
  final String collegeId;
  final String collegeName;
  const AdminHome(
      {super.key, required this.collegeId, required this.collegeName});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  String? authToken;
  String? selectedSearchBy;
  String? selectedCriteria;
  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> branchedStudents = [];
  List<Map<String, dynamic>> jobStudents = [];
  String? selectedSortBy;

  final TextEditingController _jobRoleController = TextEditingController();
  final List<String> searchOptions = ['Branch', 'Preferred Job Role'];
  final Map<String, List<String>> criteriaOptions = {
    'Branch': ['CSE', 'ECE', 'EEE', 'Mechanical', 'Civil', 'Biotech'],
  };

  Future<void> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      authToken = prefs.getString('authToken');
    });
  }

  Future<void> _getAllStudents() async {
    try {
      final response = await http.get(
        Uri.parse(
            '$api/student-details/college/verified?collegeId=${widget.collegeId}'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          students = (data as List)
              .where((student) =>
                  student != null &&
                  student['personalDetails'] != null &&
                  student['skillDetails'] != null)
              .map<Map<String, dynamic>>((student) => {
                    'userId': student['personalDetails']['user']['userId'] ?? 0,
                    'name': student['personalDetails']['fullName'] ?? 'N/A',
                    'branch': student['personalDetails']['branch'] ?? 'N/A',
                    'atsScore': student['personalDetails']['atsScore'] ?? 'N/A',
                    'jobRole': student['personalDetails']['jobRole'] ?? 'N/A',
                    'rollNo': student['personalDetails']['rollNo'] ?? 'N/A',
                    'skillCount': student['skillDetails']['skills'] != null
                        ? (student['skillDetails']['skills'] as List).length
                        : 0,
                    'maxCgpa': student['educationDetails']?['educations'] !=
                            null
                        ? (student['educationDetails']['educations'] as List)
                            .where((education) => education['cgpa'] != null)
                            .map((education) => education['cgpa'] as double)
                            .fold<double>(
                                0.0, (max, cgpa) => cgpa > max ? cgpa : max)
                        : 0.0,
                    'placed': student['personalDetails']['placed'],
                  })
              .toList();
        });
      } else {
        print("Failed to fetch students: ${response.statusCode}");
      }
    } catch (e) {
      print("Failed to fetch students: $e");
    }
  }

  Future<void> _getStudentsByBranch() async {
    try {
      final response = await http.get(
        Uri.parse(
            '$api/student-details/collegeAndBranch?collegeId=${widget.collegeId}&branch=$selectedCriteria'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          branchedStudents = (data as List)
              .where((student) =>
                  student != null &&
                  student['personalDetails'] != null &&
                  student['personalDetails'] != null &&
                  student['educationDetails'] != null)
              .map<Map<String, dynamic>>((student) => {
                    'userId': student['personalDetails']['user']['userId'] ?? 0,
                    'name': student['personalDetails']['fullName'] ?? 'N/A',
                    'branch': student['personalDetails']['branch'] ?? 'N/A',
                    'atsScore': student['personalDetails']['atsScore'] ?? 'N/A',
                    'jobRole': student['personalDetails']['jobRole'] ?? 'N/A',
                    'rollNo': student['personalDetails']['rollNo'] ?? 'N/A',
                    'skillCount': student['skillDetails']['skills'] != null
                        ? (student['skillDetails']['skills'] as List).length
                        : 0,
                    'maxCgpa': student['educationDetails']?['educations'] !=
                            null
                        ? (student['educationDetails']['educations'] as List)
                            .where((education) => education['cgpa'] != null)
                            .map((education) => education['cgpa'] as double)
                            .fold<double>(
                                0.0, (max, cgpa) => cgpa > max ? cgpa : max)
                        : 0.0,
                    'placed': student['personalDetails']['placed'],
                  })
              .toList();
        });
        print(students);
      } else {
        print("Failed to fetch students: ${response.statusCode}");
      }
    } catch (e) {
      print("Failed to fetch students: $e");
    }
  }

  Future<void> _getStudentsByjobRole() async {
    try {
      final response = await http.get(
        Uri.parse(
            '$api/student-details/collegeAndJobRole?collegeId=${widget.collegeId}&jobRole=${_jobRoleController.text}'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          jobStudents = (data as List)
              .where((student) =>
                  student != null &&
                  student['personalDetails'] != null &&
                  student['personalDetails'] != null)
              .map<Map<String, dynamic>>((student) => {
                    'userId': student['personalDetails']['user']['userId'] ?? 0,
                    'name': student['personalDetails']['fullName'] ?? 'N/A',
                    'branch': student['personalDetails']['branch'] ?? 'N/A',
                    'atsScore': student['personalDetails']['atsScore'] ?? 'N/A',
                    'jobRole': student['personalDetails']['jobRole'] ?? 'N/A',
                    'rollNo': student['personalDetails']['rollNo'] ?? 'N/A',
                    'skillCount': student['skillDetails']['skills'] != null
                        ? (student['skillDetails']['skills'] as List).length
                        : 0,
                    'maxCgpa': student['educationDetails']?['educations'] !=
                            null
                        ? (student['educationDetails']['educations'] as List)
                            .where((education) => education['cgpa'] != null)
                            .map((education) => education['cgpa'] as double)
                            .fold<double>(
                                0.0, (max, cgpa) => cgpa > max ? cgpa : max)
                        : 0.0,
                    'placed': student['personalDetails']['placed'],
                  })
              .toList();
        });
        print(students);
      } else {
        print("Failed to fetch students: ${response.statusCode}");
      }
    } catch (e) {
      print("Failed to fetch students: $e");
    }
  }

  void _sortByAts(List<Map<String, dynamic>> students) {
    students.sort((a, b) => (b['atsScore'] ?? 0).compareTo(a['atsScore'] ?? 0));
  }

  void _sortByRollNo(List<Map<String, dynamic>> students) {
    students.sort((a, b) => (a['rollNo'] ?? 0).compareTo(b['rollNo'] ?? 0));
  }

  void _sortByNoOfSkills(List<Map<String, dynamic>> students) {
    students
        .sort((a, b) => (b['skillCount'] ?? 0).compareTo(a['skillCount'] ?? 0));
  }

  void _sortByMaxCgpa(List<Map<String, dynamic>> students) {
    students.sort((a, b) => (b['maxCgpa'] ?? 0).compareTo(a['maxCgpa'] ?? 0));
  }

  void _rebuildStudentsbyBranch() async {
    await _getStudentsByBranch();
    students = branchedStudents;
  }

  void _rebuildStudentsbyjobRole() async {
    await _getStudentsByjobRole();
    students = jobStudents;
  }

  void resetSearch() {
    setState(() {
      selectedSearchBy = null;
      selectedCriteria = null;
      selectedSortBy = null;
      branchedStudents.clear();
      jobStudents.clear();
      _getAllStudents();
    });
  }

  @override
  void initState() {
    super.initState();
    _getAuthToken().then((_) {
      _getAllStudents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Color(0xFF00C6FF),
                  Color(0xFF0072FF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                widget.collegeName,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                _buildDropdown(
                  hint: 'Search by',
                  value: selectedSearchBy,
                  items: searchOptions,
                  onChanged: (value) {
                    setState(() {
                      if (value == null) {
                        resetSearch();
                      } else {
                        selectedSearchBy = value;
                        selectedCriteria = null;
                      }
                    });
                  },
                ),
                const SizedBox(height: 10),
                if (selectedSearchBy != null &&
                    selectedSearchBy != 'Preferred Job Role')
                  _buildDropdown(
                    hint: 'Select Branch',
                    value: selectedCriteria,
                    items: criteriaOptions[selectedSearchBy]!,
                    onChanged: (value) {
                      setState(() {
                        if (value == null) {
                          resetSearch();
                        } else {
                          selectedCriteria = value;
                          _rebuildStudentsbyBranch();
                        }
                      });
                    },
                  ),
                if (selectedSearchBy == 'Preferred Job Role')
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: TextField(
                      controller: _jobRoleController,
                      decoration: InputDecoration(
                        hintText: 'Type job role...',
                        prefixIcon: Icon(Icons.search, color: Colors.white70),
                        filled: true,
                        fillColor: const Color(0xFF2C2C3E),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none,
                        ),
                        hintStyle: const TextStyle(color: Colors.white54),
                      ),
                      style: const TextStyle(color: Colors.white),
                      onChanged: (text) {
                        _rebuildStudentsbyjobRole();
                      },
                    ),
                  ),
                const SizedBox(height: 12),
                _buildDropdown(
                  hint: 'Sort by',
                  value: selectedSortBy,
                  items: ['Max CGPA', 'No. of Skills', 'ATS Score', 'Roll No.'],
                  onChanged: (value) {
                    setState(() {
                      selectedSortBy = value;
                      if (value == 'ATS Score') {
                        _sortByAts(students);
                      } else if (value == 'Roll No.') {
                        _sortByRollNo(students);
                      } else if (value == 'No. of Skills') {
                        _sortByNoOfSkills(students);
                      } else if (value == 'Max CGPA') {
                        _sortByMaxCgpa(students);
                      } else {
                        resetSearch();
                      }
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: students.isEmpty
                ? const Center(
                    child: Text(
                      'No students found..!',
                      style: TextStyle(
                          color: Colors.white54,
                          fontStyle: FontStyle.italic,
                          fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, idx) {
                      final student = students[idx];
                      int ats = (student['atsScore']);
                      double maxCgpa = student['maxCgpa'];
                      return StudentRow(
                        name: student['name'],
                        branch: student['branch'],
                        atsScore: ats,
                        jobRole: student['jobRole'],
                        maxCgpa: maxCgpa,
                        placed: student['placed'],
                        userId: student['userId'],
                        gradientColors: (idx % 2 == 0)
                            ? [
                                Color.fromARGB(255, 242, 177, 190),
                                Color.fromARGB(255, 170, 88, 132)
                              ]
                            : [
                                Color.fromARGB(255, 69, 193, 193),
                                Color.fromARGB(255, 128, 208, 213)
                              ],
                      );
                    },
                  ),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF6A89CC)),
        borderRadius: BorderRadius.circular(30),
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        value: value,
        borderRadius: BorderRadius.circular(20),
        underline: const SizedBox(),
        dropdownColor: const Color(0xFF1E1E2C),
        hint: Text(
          hint,
          style: const TextStyle(color: Color(0xFF6A89CC)),
        ),
        items: items
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(color: Colors.white),
                  ),
                ))
            .toList(),
        onChanged: (selectedValue) {
          if (value == selectedValue) {
            onChanged(null);
          } else {
            onChanged(selectedValue);
          }
        },
      ),
    );
  }
}
