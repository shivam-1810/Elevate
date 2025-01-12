import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NewAccount extends StatelessWidget {
  const NewAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Image(
                image: AssetImage('assets/images/9.png'),
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 20),
              const Text(
                'No worries!',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Contact us and we will add your college to our database.',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade800.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.grey.shade400,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildContactDetail(
                      icon: FontAwesomeIcons.whatsapp,
                      text: 'WhatsApp: 7033303100',
                      color: Colors.green,
                    ),
                    const SizedBox(height: 1),
                    const Divider(color: Colors.grey),
                    const SizedBox(height: 1),
                    _buildContactDetail(
                      icon: FontAwesomeIcons.instagram,
                      text: 'Instagram: @me_shivam04',
                      color: Colors.pinkAccent,
                    ),
                    const SizedBox(height: 1),
                    const Divider(color: Colors.grey),
                    const SizedBox(height: 1),
                    _buildContactDetail(
                      icon: FontAwesomeIcons.envelope,
                      text: 'Email: shivamkumar147369@gmail.com',
                      color: Colors.redAccent,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactDetail({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24.0),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16.0, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
