import 'package:elevate/student/editable_forms/certification_details.dart';
import 'package:flutter/material.dart';

class CertificateCard extends StatelessWidget {
  final String title;
  final String dateOfCertification;
  final String description;
  final String link;
  final VoidCallback onEdit;

  const CertificateCard({
    super.key,
    required this.title,
    required this.dateOfCertification,
    required this.description,
    required this.link,
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
                Expanded(
                  child: Text(
                    title,
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
            _buildField('Certification Date', dateOfCertification),
            _buildField('Description', description),
            _buildField('Link', link),
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

class CertificateDetailsCard extends StatelessWidget {
  final List<Map<String, String>> certificateDetails;
  final int userId;

  const CertificateDetailsCard({
    super.key,
    required this.userId,
    required this.certificateDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 186, 225, 255),
              Color.fromARGB(255, 142, 190, 255),
              Color.fromARGB(255, 109, 156, 255),
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
              children: [
                const Text(
                  'Certification Details',
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
                        builder: (context) =>
                            CertificationsDetailsForm(userId: userId)));
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...certificateDetails.map(
              (details) => CertificateCard(
                title: details['title'] ?? 'N/A',
                dateOfCertification: details['dateOfCertification'] ?? 'N/A',
                description: details['description'] ?? 'N/A',
                link: details['link'] ?? 'N/A',
                onEdit: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
