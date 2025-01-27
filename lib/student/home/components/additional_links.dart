import 'package:elevate/student/editable_forms/additional_links.dart';
import 'package:flutter/material.dart';

class AdditionalLinksCard extends StatelessWidget {
  final List<String> links;
  final int userId;
  final VoidCallback onViewResume;

  const AdditionalLinksCard({
    super.key,
    required this.links,
    required this.userId,
    required this.onViewResume,
  });

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
              Color.fromARGB(255, 255, 204, 188),
              Color.fromARGB(255, 255, 128, 109),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
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
                    'Additional Links & Resume',
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
                          builder: (context) =>
                              AdditionalLinksForm(userId: userId)));
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...links.map((link) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      children: [
                        const Icon(Icons.link, color: Colors.black),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            link,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: onViewResume,
                icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                label: const Text('View Resume'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 87, 87),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
