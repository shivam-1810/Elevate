import 'package:elevate/student/editable_forms/experience_details.dart';
import 'package:flutter/material.dart';

class ExperienceCard extends StatelessWidget {
  final String role;
  final String company;
  final String startDate;
  final String endDate;
  final String description;
  final VoidCallback onEdit;

  const ExperienceCard({
    super.key,
    required this.role,
    required this.company,
    required this.startDate,
    required this.endDate,
    required this.description,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  role,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildField('Company', company),
            _buildField('Start Date', startDate),
            _buildField('End Date', endDate),
            _buildField('Description', description),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            width: 30,
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WorkExperienceDetailsCard extends StatefulWidget {
  final List<Map<String, String>> workExperienceDetails;
  final int userId;
  const WorkExperienceDetailsCard({
    super.key,
    required this.userId,
    required this.workExperienceDetails,
  });

  @override
  State<WorkExperienceDetailsCard> createState() =>
      _WorkExperienceDetailsCardState();
}

class _WorkExperienceDetailsCardState extends State<WorkExperienceDetailsCard> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 197, 238, 255),
              Color.fromARGB(255, 159, 221, 255),
              Color.fromARGB(255, 108, 201, 255),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Text(
                  'Work Experience Details',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.black54),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ExperienceDetailsForm(
                              userId: widget.userId,
                            )));
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...widget.workExperienceDetails.map(
              (details) => ExperienceCard(
                role: details['role'] ?? 'N/A',
                company: details['company'] ?? 'N/A',
                startDate: details['startDate'] ?? 'N/A',
                endDate: details['endDate'] ?? 'N/A',
                description: details['description'] ?? 'N/A',
                onEdit: () {
                  // Define your edit logic here
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
