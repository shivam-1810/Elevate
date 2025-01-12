// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:typed_data';
import 'package:elevate/administrator/pages/update_credentials.dart';
import 'package:elevate/api.dart';
import 'package:flutter/material.dart';
import 'package:gauge_indicator/gauge_indicator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyCollegePage extends StatefulWidget {
  final String collegeId;
  final String collegeName;
  const MyCollegePage({
    super.key,
    required this.collegeId,
    required this.collegeName,
  });

  @override
  State<MyCollegePage> createState() => _MyCollegePageState();
}

class _MyCollegePageState extends State<MyCollegePage> {
  File? _collegeImage;
  Uint8List? _collegeImageBytes;
  String? location;
  int? noOfStudentsAppeared;
  int? noOfStudentsPlaced;
  int? foundationYear;
  String? accreditation;
  int placed = 0;
  int total = 1;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _collegeImage = File(image.path);
        _collegeImageBytes = null;
      });
    }
  }

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
            _collegeImage = null;
            _collegeImageBytes = imageBytes;
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

  Future<void> _uploadCollegeImage() async {
    if (_collegeImage == null) return;
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$api/college-details/add-image'),
    );

    request.fields['collegeId'] = widget.collegeId;
    request.files.add(
      await http.MultipartFile.fromPath('file', _collegeImage!.path),
    );

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        print("Image uploaded successfully");
        _showDialog('Success', 'Image upload successful!');
      } else {
        print("Failed to upload image");
        _showDialog('Error', 'Failed to upload image!!');
      }
    } catch (e) {
      print("Error uploading image: $e");
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

  Future<void> _pickAndUploadImage() async {
    await _pickImage();
    _uploadCollegeImage();
  }

  @override
  void initState() {
    super.initState();
    _fetchCollegeDetails();
    _countPlacedStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    GestureDetector(
                      onTap: _pickAndUploadImage,
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 34, 78, 136),
                              Color.fromARGB(255, 58, 95, 135),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          image: _collegeImage != null
                              ? DecorationImage(
                                  image: FileImage(_collegeImage!),
                                  fit: BoxFit.cover,
                                )
                              : _collegeImageBytes != null
                                  ? DecorationImage(
                                      image: MemoryImage(_collegeImageBytes!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                        ),
                        child: (_collegeImage == null &&
                                _collegeImageBytes == null)
                            ? Center(
                                child: Text(
                                  'No Image Available',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: _pickAndUploadImage,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFF33658A),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
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
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        Container(
          width: double.infinity,
          margin: EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      UpdateCredentialsPage(collegeId: widget.collegeId)));
            },
            icon: const Icon(
              Icons.lock_reset,
              color: Colors.white,
            ),
            label: const Text(
              'Change Admin Credentials',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 20, 123, 179),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 10,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> details,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 43, 107, 189),
            Color.fromARGB(255, 64, 165, 199),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
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
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 3),
          const Divider(color: Colors.black45),
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
          Icon(icon, size: 26, color: Colors.black87),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$label: $value',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
