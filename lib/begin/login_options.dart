import 'package:elevate/administrator/admin_signup.dart';
import 'package:elevate/recruiter/recruiter_login.dart';
import 'package:elevate/student/student_login.dart';
import 'package:flutter/material.dart';

class LoginOptions extends StatelessWidget {
  const LoginOptions({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 35.0),
              child: Image(
                image: AssetImage('assets/images/6.png'),
                width: 280,
                height: 280,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 30.0),
              child: Text(
                'You are a :',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RecruiterLogin()),
                  );
                },
                icon: const Icon(Icons.business, size: 26, color: Colors.black),
                label: const Text(
                  'Recruiter',
                  style: TextStyle(fontSize: 22),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[400],
                  foregroundColor: Colors.black,
                  minimumSize: const Size(280, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const StudentLogin()),
                  );
                },
                icon: const Icon(Icons.school, size: 26, color: Colors.black),
                label: const Text(
                  'Student',
                  style: TextStyle(fontSize: 22),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[400],
                  foregroundColor: Colors.black,
                  minimumSize: const Size(280, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AdminSignup()),
                  );
                },
                icon: const Icon(Icons.admin_panel_settings,
                    size: 26, color: Colors.black),
                label: const Text(
                  'College Administrator',
                  style: TextStyle(fontSize: 22),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent[700],
                  foregroundColor: Colors.black,
                  minimumSize: const Size(280, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
