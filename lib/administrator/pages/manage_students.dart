// ignore_for_file: avoid_print

import 'package:elevate/api.dart';
import 'package:elevate/viewableProfile/viewable_profile.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StudentVerificationPage extends StatefulWidget {
  final String collegeId;
  const StudentVerificationPage({super.key, required this.collegeId});

  @override
  _StudentVerificationPageState createState() =>
      _StudentVerificationPageState();
}

class _StudentVerificationPageState extends State<StudentVerificationPage> {
  List<Map<String, dynamic>> students = [];

  @override
  void initState() {
    super.initState();
    _getAllStudents();
  }

  Future<void> _getAllStudents() async {
    try {
      final response = await http.get(
        Uri.parse(
            '$api/student-details/college/un-verified?collegeId=${widget.collegeId}'),
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
                    'userId':
                        student['personalDetails']['user']?['userId'] ?? 0,
                    'name': student['personalDetails']['fullName'] ?? 'N/A',
                    'branch': student['personalDetails']['branch'] ?? 'N/A',
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

  Future<void> _verifyUser(int userId) async {
    try {
      final response = await http.put(
        Uri.parse('$api/verify?userId=$userId'),
      );
      if (response.statusCode != 200) {
        print("Failed to verify student: ${response.statusCode}");
      }
    } catch (e) {
      print("Failed to verify student: $e");
    }
  }

  Future<void> _blockUser(int userId) async {
    try {
      final response = await http.put(
        Uri.parse('$api/block?userId=$userId'),
      );
      if (response.statusCode != 200) {
        print("Failed to block student: ${response.statusCode}");
      }
    } catch (e) {
      print("Failed to block student: $e");
    }
  }

  Future<void> _confirmAction(
      {required String title,
      required String message,
      required VoidCallback onConfirm}) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            child: Text(
              title == "Verify Student" ? "Confirm" : "Delete",
              style: TextStyle(
                  color: title == "Verify Student" ? Colors.green : Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _verifyStudent(int index, bool isVerified, int userId) {
    _confirmAction(
      title: isVerified ? "Verify Student" : "Delete Student",
      message: isVerified
          ? "Are you sure you want to verify this student?"
          : "Are you sure you want to block this student?\nThis action can't be undone.",
      onConfirm: isVerified
          ? () {
              _verifyUser(userId);
              setState(() {
                students.removeAt(index);
              });
            }
          : () {
              _blockUser(userId);
              setState(() {
                students.removeAt(index);
              });
            },
    );
  }

  void _navigateToStudentDetails(int userId) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ViewableProfile(
              userId: userId,
              viewerRole: 'Admin',
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shield_sharp,
                    color: Color(0xFF2F80ED), size: 28),
                const SizedBox(width: 10),
                const Text(
                  'Verify Student Details',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2F80ED),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            students.isEmpty
                ? const Expanded(
                    child: Center(
                      child: Text(
                        "No unverified students found.",
                        style: TextStyle(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          color: Colors.white60,
                        ),
                      ),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final student = students[index];
                        return GestureDetector(
                          onTap: () =>
                              _navigateToStudentDetails(student['userId']),
                          child: Card(
                            color: const Color(0xFF2A2D3E),
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundColor: Colors.blueAccent,
                                        child: Text(
                                          "${index + 1}",
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            student['name'],
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            student['branch'],
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () => _verifyStudent(
                                            index, true, student['userId']),
                                        icon: const Icon(Icons.check_circle,
                                            color: Colors.green),
                                        tooltip: 'Verify Student',
                                      ),
                                      IconButton(
                                        onPressed: () => _verifyStudent(
                                            index, false, student['userId']),
                                        icon: const Icon(Icons.cancel,
                                            color: Colors.red),
                                        tooltip: 'Block Student',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
