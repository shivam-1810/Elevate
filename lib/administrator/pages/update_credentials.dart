// ignore_for_file: use_build_context_synchronously

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:elevate/administrator/base_page.dart';
import 'package:elevate/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UpdateCredentialsPage extends StatefulWidget {
  final String collegeId;
  const UpdateCredentialsPage({super.key, required this.collegeId});

  @override
  _UpdateCredentialsPageState createState() => _UpdateCredentialsPageState();
}

class _UpdateCredentialsPageState extends State<UpdateCredentialsPage> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isProcessing = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  void _updateCredentials() async {
    if (_newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: const Text("All fields are required!"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else if (_newPasswordController.text != _confirmPasswordController.text) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: const Text("Passwords do not match!"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else {
      setState(() {
        _isProcessing = true;
      });
      try {
        final response = await http.put(
          Uri.parse(
              '$api/college/update?collegeId=${widget.collegeId}&adminPassWord=${_confirmPasswordController.text}'),
        );
        setState(() {
          _isProcessing = false;
        });
        if (response.statusCode == 200) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Success"),
              content: const Text("Congrats! Password changed successfully!"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            ),
          );
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => BasePage(collegeId: widget.collegeId)));
        } else {
          // ignore: avoid_print
          print('Error: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        setState(() {
          _isProcessing = false;
        });
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Error"),
            content: const Text("Unable to update password!"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedTextKit(
              animatedTexts: [
                TyperAnimatedText(
                  'Update Credentials',
                  textStyle: TextStyle(
                    fontSize: 26.0,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: <Color>[
                          Colors.blueAccent,
                          Color.fromARGB(255, 119, 238, 223),
                          Color.fromARGB(255, 183, 139, 253)
                        ],
                      ).createShader(const Rect.fromLTWH(0.0, 0.0, 500.0, 0.0)),
                  ),
                  speed: const Duration(milliseconds: 50),
                ),
              ],
              totalRepeatCount: 1,
              pause: const Duration(milliseconds: 1000),
              displayFullTextOnTap: true,
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color.fromARGB(255, 84, 162, 199),
                        const Color.fromARGB(255, 60, 114, 158),
                        const Color.fromARGB(255, 84, 162, 199),
                        const Color.fromARGB(255, 60, 114, 158),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _newPasswordController,
                        obscureText: _obscureNewPassword,
                        decoration: InputDecoration(
                          prefixIcon:
                              const Icon(Icons.lock, color: Colors.black),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureNewPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureNewPassword = !_obscureNewPassword;
                              });
                            },
                          ),
                          labelText: 'New Password',
                          labelStyle: const TextStyle(color: Colors.black54),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black54),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black54),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline,
                              color: Colors.black),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                          labelText: 'Confirm Password',
                          labelStyle: const TextStyle(color: Colors.black54),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black54),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black54),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        style: const TextStyle(color: Colors.black),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _updateCredentials,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isProcessing
                                ? const Color.fromARGB(255, 14, 104, 188)
                                : const Color.fromARGB(255, 18, 104, 185),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            shadowColor: Colors.black,
                            side: const BorderSide(
                                width: 1.0,
                                color: Color.fromARGB(255, 7, 130, 58)),
                            elevation: 8,
                          ),
                          child: _isProcessing
                              ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                )
                              : Text(
                                  'Update',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white70),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
