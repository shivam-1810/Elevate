import 'package:elevate/viewableProfile/viewable_profile.dart';
import 'package:flutter/material.dart';

class StudentRow extends StatelessWidget {
  final String name;
  final String branch;
  final int atsScore;
  final int userId;
  final String jobRole;
  final double maxCgpa;
  final bool placed;
  final List<Color> gradientColors;

  const StudentRow({
    required this.name,
    required this.branch,
    required this.atsScore,
    required this.userId,
    required this.jobRole,
    required this.maxCgpa,
    required this.placed,
    required this.gradientColors,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ViewableProfile(
                  userId: userId,
                  viewerRole: 'Student',
                )));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withOpacity(0.6),
              offset: const Offset(0, 2),
              blurRadius: 5,
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      if (placed) ...[
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.check_circle,
                          color: Color.fromARGB(255, 62, 232, 67),
                          size: 28,
                        ),
                      ],
                    ],
                  ),
                  Text(
                    jobRole,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Branch: $branch',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Max CGPA: $maxCgpa',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    value: atsScore / 100,
                    backgroundColor: Colors.grey[800],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF00C6FF),
                    ),
                    strokeWidth: 6,
                  ),
                ),
                Text(
                  '$atsScore%',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
