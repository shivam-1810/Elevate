import 'package:elevate/begin/login_options.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:elevate/api.dart';
import 'package:elevate/recruiter/college_info.dart';
import 'package:elevate/recruiter/recruiter_home.dart';
import 'package:http/http.dart' as http;

class BasePage extends StatefulWidget {
  final String collegeId;
  const BasePage({super.key, required this.collegeId});

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  String collegeName = '';

  Future<void> _getCollegeName() async {
    final String id = widget.collegeId;
    try {
      final response = await http.get(
        Uri.parse('$api/college-details/name?collegeId=$id'),
      );
      if (response.statusCode == 200) {
        collegeName = response.body;
      }
    } catch (e) {
      // ignore: avoid_print
      print("Internal server error");
    }
  }

  int _currentPageIndex = 0;

  List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _initializePages();
  }

  Future<void> _initializePages() async {
    await _getCollegeName();
    setState(() {
      _pages = [
        RecruiterHome(collegeId: widget.collegeId, collegeName: collegeName),
        CollegeInfo(collegeId: widget.collegeId, collegeName: collegeName),
      ];
    });
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
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginOptions()),
                    (route) => false);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
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
                'About College',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )
            : const Text(
                'College DataBase',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
      ),
      body: _pages.isEmpty
          ? const Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 85, 200, 235),
              ),
            )
          : _pages[_currentPageIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: const Color(0xFF1E1E2C),
        color: Colors.black87,
        buttonBackgroundColor: Colors.black45,
        height: 60,
        index: _currentPageIndex,
        items: const [
          Icon(Icons.home, color: Colors.white),
          Icon(Icons.info_outline, color: Colors.white),
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
