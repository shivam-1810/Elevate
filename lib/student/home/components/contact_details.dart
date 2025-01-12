import 'package:elevate/student/editable_forms/personal_details.dart';
import 'package:flutter/material.dart';

class ContactDetailsCard extends StatefulWidget {
  final int userId;
  final String contactNumber;
  final String email;
  final String portfolio;
  final String linkedinProfile;

  const ContactDetailsCard({
    super.key,
    required this.userId,
    required this.contactNumber,
    required this.email,
    required this.portfolio,
    required this.linkedinProfile,
  });

  @override
  State<ContactDetailsCard> createState() => _ContactDetailsCardState();
}

class _ContactDetailsCardState extends State<ContactDetailsCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 209, 250, 216),
              Color.fromARGB(255, 107, 215, 140),
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Contact Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.black54),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => PersonalDetailsForm(
                                userId: widget.userId,
                              )));
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailRow(
                  Icons.phone, 'Contact Number', widget.contactNumber),
              _buildDetailRow(Icons.email, 'Email', widget.email),
              _buildDetailRow(Icons.link, 'LinkedIn', widget.linkedinProfile),
              _buildDetailRow(Icons.portrait, 'Portfolio', widget.portfolio),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.black),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
