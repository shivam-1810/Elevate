// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:typed_data';
import 'package:elevate/api.dart';
import 'package:flutter/material.dart';
import 'package:gauge_indicator/gauge_indicator.dart';
import 'package:http/http.dart' as http;

class CollegeInfo extends StatefulWidget {
  final String collegeId;
  final String collegeName;

  const CollegeInfo({
    super.key,
    required this.collegeId,
    required this.collegeName,
  });

  @override
  State<CollegeInfo> createState() => _CollegeInfoState();
}

class _CollegeInfoState extends State<CollegeInfo> {
  Uint8List? _collegeImage;
  String? location;
  int? noOfStudentsAppeared;
  int? noOfStudentsPlaced;
  int? foundationYear;
  String? accreditation;
  int placed = 0;
  int total = 1;

  Future<void> _fetchCollegeDetails() async {
    final String id = widget.collegeId;
    try {
      final response = await http.get(
        Uri.parse('$api/college-details/get?collegeId=$id'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final imageBytes =
            data['image'] != null ? base64Decode(data['image']) : null;
        setState(() {
          if (imageBytes != null) {
            _collegeImage = imageBytes;
          }
          location = data['location'];
          noOfStudentsAppeared = data['noOfStudentsAppeared'];
          noOfStudentsPlaced = data['noOfStudentsPlaced'];
          foundationYear = data['foundationYear'];
          accreditation = data['accreditation'];
        });
      } else {
        print("Error fetching college details");
      }
    } catch (e) {
      print("Internal server error");
    }
  }

  Future<void> _countPlacedStudents() async {
    final String id = widget.collegeId;
    try {
      final response = await http.get(
        Uri.parse('$api/student-details/countPlaced?collegeId=$id'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          placed = data;
        });
        print(placed);
      } else {
        print("Error fetching no of placed students");
      }
    } catch (e) {
      print("Internal server error1");
    }
    try {
      final response = await http.get(
        Uri.parse('$api/student-details/total?collegeId=$id'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          total = data;
        });
        print(total);
      } else {
        print("Error fetching no of total students");
      }
    } catch (e) {
      print("Internal server error2");
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchCollegeDetails();
    _countPlacedStudents();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF4CA1AF),
                  Color(0xFFC4E0E5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              image: _collegeImage != null
                  ? DecorationImage(
                      image: MemoryImage(_collegeImage!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: _collegeImage == null
                ? Center(
                    child: Text(
                      'No Image Available',
                      style: TextStyle(
                        color: Colors.black.withAlpha((0.8 * 255).toInt()),
                        fontSize: 16,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 35),
          Text(
            "Current Placement Stats",
            style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 82, 146, 255)),
          ),
          const SizedBox(height: 22),
          AnimatedRadialGauge(
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOut,
            radius: 100,
            value: (placed / total) * 100,
            axis: GaugeAxis(
              min: 0,
              max: 100,
              degrees: 180,
              style: const GaugeAxisStyle(
                thickness: 20,
                background: Color(0xFF1E1E2C),
                segmentSpacing: 10,
              ),
              pointer: GaugePointer.needle(
                width: 14,
                height: 90,
                borderRadius: 14,
                color: Color.fromARGB(255, 74, 95, 105),
              ),
              progressBar: const GaugeProgressBar.rounded(
                color: Color.fromARGB(255, 74, 95, 105),
              ),
              segments: [
                const GaugeSegment(
                  from: 0,
                  to: 45,
                  color: Color.fromARGB(255, 219, 109, 101),
                  cornerRadius: Radius.circular(9),
                ),
                const GaugeSegment(
                  from: 45,
                  to: 75,
                  color: Color.fromARGB(255, 245, 203, 78),
                  cornerRadius: Radius.circular(9),
                ),
                const GaugeSegment(
                  from: 75,
                  to: 100,
                  color: Color.fromARGB(255, 98, 202, 102),
                  cornerRadius: Radius.circular(9),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "$placed",
                style: TextStyle(
                    color: Colors.amber,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                " out of ",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              Text(
                "$total",
                style: TextStyle(
                    color: Colors.amber,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                " placed",
                style: TextStyle(color: Colors.white, fontSize: 18),
              )
            ],
          ),
          const SizedBox(height: 26),
          _buildInfoCard(
            title: 'College Information',
            details: [
              _DetailItem(
                icon: Icons.location_on,
                label: 'Location',
                value: location ?? 'N/A',
              ),
              _DetailItem(
                icon: Icons.people,
                label: 'Students registered last year',
                value: noOfStudentsAppeared?.toString() ?? 'N/A',
              ),
              _DetailItem(
                icon: Icons.school,
                label: 'Students placed last year',
                value: noOfStudentsPlaced?.toString() ?? 'N/A',
              ),
              _DetailItem(
                icon: Icons.calendar_today,
                label: 'Founded',
                value: foundationYear?.toString() ?? 'N/A',
              ),
              _DetailItem(
                icon: Icons.grade,
                label: 'Accreditation',
                value: accreditation ?? 'N/A',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
      {required String title, required List<Widget> details}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 20, 42, 51),
            Color(0xFF203A43),
            Color(0xFF2C5364),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 94, 105, 102)
                .withAlpha((0.3 * 255).toInt()),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 3),
          const Divider(color: Colors.white54),
          const SizedBox(height: 3),
          ...details,
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 26, color: Colors.white70),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$label: $value',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
