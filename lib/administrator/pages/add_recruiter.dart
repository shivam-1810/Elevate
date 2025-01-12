import 'dart:convert';
import 'package:elevate/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RecruiterManagementPage extends StatefulWidget {
  final String collegeId;
  final String collegeName;
  const RecruiterManagementPage(
      {super.key, required this.collegeId, required this.collegeName});

  @override
  State<RecruiterManagementPage> createState() =>
      _RecruiterManagementPageState();
}

class _RecruiterManagementPageState extends State<RecruiterManagementPage> {
  final TextEditingController _recruiterIdController = TextEditingController();
  final List<String> _recruiters = [];

  @override
  void initState() {
    super.initState();
    _fetchRecruiters();
  }

  Future<void> _fetchRecruiters() async {
    final String id = widget.collegeId;

    try {
      final response = await http.get(
        Uri.parse('$api/recruiters/get?collegeId=$id'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> recruiterList = json.decode(response.body);

        if (mounted) {
          setState(() {
            _recruiters.clear();
            _recruiters.addAll(
              recruiterList.map((e) => e.toString()),
            );
          });
        }
      } else {
        _showError(
          'Failed to load recruiters. Status Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      _showError('Error fetching recruiters');
    }
  }

  Future<void> _addRecruiter() async {
    final recruiterId = _recruiterIdController.text.trim();
    if (recruiterId.isEmpty || _recruiters.contains(recruiterId)) {
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$api/recruiters/add'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'recruiterId': recruiterId,
          'college': {'collegeId': widget.collegeId},
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _recruiters.add(recruiterId);
          _recruiterIdController.clear();
        });
      } else {
        _showError('Failed to add recruiter');
      }
    } catch (e) {
      _showError('Error adding recruiter');
    }
  }

  Future<void> _removeRecruiter(int index) async {
    final recruiterId = _recruiters[index];

    try {
      final response = await http.delete(
        Uri.parse('$api/recruiters/delete?recruiterId=$recruiterId'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _recruiters.removeAt(index);
        });
      } else {
        _showError('Failed to remove recruiter');
      }
    } catch (e) {
      _showError('Error removing recruiter');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildRecruiterCard(String recruiterId, int index) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: const Color(0xFF1F1F1F),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF56CCF2),
          child: Text(
            recruiterId[0].toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          recruiterId,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close, color: Colors.red),
          onPressed: () => _confirmRemoveRecruiter(index),
        ),
      ),
    );
  }

  void _confirmRemoveRecruiter(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F1F1F),
        title: const Text(
          'Confirm Removal',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to remove "${_recruiters[index]}"?',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              _removeRecruiter(index);
              Navigator.pop(context);
            },
            child: const Text(
              'Remove',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF56CCF2), Color(0xFF2F80ED)],
                  ).createShader(bounds),
                  child: Text(
                    widget.collegeName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: const Color(0xFF1F1F1F),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      controller: _recruiterIdController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Enter Recruiter ID',
                        hintStyle:
                            TextStyle(color: Colors.grey[400], fontSize: 16),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F80ED),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: _addRecruiter,
                  child: const Text(
                    'Add Recruiter',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                _recruiters.isEmpty
                    ? const Center(
                        child: Text(
                          'No Recruiters Added Yet!',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _recruiters.length,
                        itemBuilder: (context, index) {
                          return _buildRecruiterCard(_recruiters[index], index);
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
