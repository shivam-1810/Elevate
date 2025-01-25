// ignore_for_file: avoid_print

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:elevate/api.dart';
import 'package:elevate/begin/login_options.dart';
import 'package:elevate/student/home/pages/college_list.dart';
import 'package:elevate/student/home/pages/main_profile.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class BasePage extends StatefulWidget {
  final int userId;
  const BasePage({super.key, required this.userId});

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  String collegeName = '';
  String collegeId = '';
  String? authToken;
  int _currentPageIndex = 0;
  List<Widget> _pages = [];
  bool _isLoading = true;

  Future<void> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      authToken = prefs.getString('authToken');
    });
  }

  Future<void> _getCollegeName() async {
    try {
      final response = await http.get(
        Uri.parse('$api/college-details/name?collegeId=$collegeId'),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          collegeName = response.body;
        });
      }
    } catch (e) {
      print("Internal server error: $e");
    }
  }

  Future<void> _getCollegeId() async {
    final int id = widget.userId;
    try {
      final response = await http.get(
        Uri.parse('$api/get-collegeId?userId=$id'),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          collegeId = response.body;
        });
      }
    } catch (e) {
      print("Internal server error: $e");
    }
  }

  Future<void> _logout(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    await prefs.remove('userId');
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginOptions()),
          (route) => false);
    }
  }

  Future<void> _showLogoutDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _logout(context);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _initializePages();
  }

  Future<void> _initializePages() async {
    await _getAuthToken();
    await _getCollegeId();
    await _getCollegeName();

    setState(() {
      _pages = [
        MyCollegeMates(
          userId: widget.userId,
          collegeId: collegeId,
          collegeName: collegeName,
        ),
        ProfilePage(userId: widget.userId),
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        backgroundColor: Colors.black45,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: (_currentPageIndex == 1)
            ? const Text(
                'My Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              )
            : const Text(
                'College Mates',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pages[_currentPageIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: const Color(0xFF1E1E2C),
        color: Colors.black87,
        buttonBackgroundColor: Colors.black45,
        height: 60,
        index: _currentPageIndex,
        items: const [
          Icon(Icons.school_rounded, color: Colors.white),
          Icon(Icons.person_rounded, color: Colors.white),
          Icon(Icons.logout, color: Colors.white),
        ],
        onTap: (index) {
          if (index == 2) {
            _showLogoutDialog();
          } else {
            setState(() {
              _currentPageIndex = index;
            });
          }
        },
      ),
    );
  }
}
