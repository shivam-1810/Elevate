import 'package:elevate/student/editable_forms/project_details.dart';
import 'package:flutter/material.dart';

class ProjectCard extends StatelessWidget {
  final String title;
  final String completionDate;
  final String description;
  final VoidCallback onEdit;

  const ProjectCard({
    super.key,
    required this.title,
    required this.completionDate,
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
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildField('Completion Date', completionDate),
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

class ProjectDetailsCard extends StatefulWidget {
  final List<Map<String, String>> projectDetails;
  final int userId;
  const ProjectDetailsCard({
    super.key,
    required this.userId,
    required this.projectDetails,
  });

  @override
  State<ProjectDetailsCard> createState() => _ProjectDetailsCardState();
}

class _ProjectDetailsCardState extends State<ProjectDetailsCard> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 186, 255, 201),
              Color.fromARGB(255, 142, 255, 174),
              Color.fromARGB(255, 109, 255, 153),
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
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
                  'Projects Details',
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
                        builder: (context) => ProjectsDetailsForm(
                              userId: widget.userId,
                            )));
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...widget.projectDetails.map(
              (details) => ProjectCard(
                title: details['title'] ?? 'N/A',
                completionDate: details['completionDate'] ?? 'N/A',
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
