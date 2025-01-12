import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:elevate/begin/login_options.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, -2.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    Timer(const Duration(seconds: 2), () {
      _controller.forward();
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginOptions()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SlideTransition(
        position: _offsetAnimation,
        child: Column(
          children: <Widget>[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset('assets/images/icon1.png', height: 200),
                    const SizedBox(height: 40),
                    AnimatedTextKit(
                      animatedTexts: [
                        ColorizeAnimatedText(
                          'Elevate',
                          textStyle: const TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                          ),
                          colors: [
                            Colors.white,
                            Colors.lightGreen,
                            Colors.lightBlue,
                            Colors.lime,
                          ],
                        ),
                      ],
                      isRepeatingAnimation: false,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
