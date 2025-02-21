import 'package:flutter/material.dart';

class SkillCard extends StatelessWidget {
  final String skillName;
  final VoidCallback onEdit;

  const SkillCard({
    super.key,
    required this.skillName,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                skillName,
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
      ),
    );
  }
}

class SkillDetailsCard extends StatelessWidget {
  final List<Map<String, String>> skillDetails;

  const SkillDetailsCard({
    super.key,
    required this.skillDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 255, 245, 186),
              Color.fromARGB(255, 255, 236, 142),
              Color.fromARGB(255, 255, 217, 109),
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.3 * 255).toInt()),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            const Text(
              'Skill Details',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            ...skillDetails.map(
              (details) => SkillCard(
                skillName: details['skillName'] ?? 'N/A',
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
