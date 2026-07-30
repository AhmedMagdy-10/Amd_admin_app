import 'package:amd_admin/feature/home/home_page.dart';
import 'package:flutter/material.dart';
import 'animated_logo.dart';
import 'animated_subtitle.dart';
import 'animated_title.dart';

class SplashViewBody extends StatefulWidget {
  const SplashViewBody({super.key});

  @override
  State<SplashViewBody> createState() => _SplashViewBodyState();
}

class _SplashViewBodyState extends State<SplashViewBody> {
  bool _scaleUp = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _scaleUp = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedLogo(
          scaleUp: _scaleUp,
          onScaleComplete: () {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 600),
                pageBuilder: (context, animation, secondaryAnimation) => const HomePage(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        AnimatedOpacity(
          opacity: _scaleUp ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 300),
          child: const Column(
            children: [
              AnimatedTitle(),
              SizedBox(height: 10),
              AnimatedSubtitle(),
            ],
          ),
        ),
      ],
    );
  }
}
