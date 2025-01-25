import 'package:flutter/material.dart';

class EducationCard extends StatelessWidget {
  final String institute;
  final String startYear;
  final String endYear;
  final String degree;
  final String field;
  final String cgpa;
  final VoidCallback onEdit;

  const EducationCard({
    super.key,
    required this.institute,
    required this.startYear,
    required this.endYear,
    required this.degree,
    required this.field,
    required this.cgpa,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    institute,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    softWrap: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildField('Degree', degree),
            _buildField('Field of Education', field),
            _buildField('Start Year', startYear),
            _buildField('End Year', endYear),
            _buildField('CGPA', cgpa),
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

class EducationDetailsCard extends StatelessWidget {
  final List<Map<String, String>> educationDetails;

  const EducationDetailsCard({
    super.key,
    required this.educationDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 255, 223, 186),
              Color.fromARGB(255, 255, 179, 142),
              Color.fromARGB(255, 255, 139, 109),
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
            const Text(
              'Educational Details',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            ...educationDetails.map(
              (details) => EducationCard(
                institute: details['institute'] ?? 'N/A',
                startYear: details['startYear'] ?? 'N/A',
                endYear: details['endYear'] ?? 'N/A',
                degree: details['degree'] ?? 'N/A',
                field: details['field'] ?? 'N/A',
                cgpa: details['cgpa'] ?? 'N/A',
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
