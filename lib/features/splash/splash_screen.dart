import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  void _navigateToHome() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 3500));
      if (mounted) {
        context.go('/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xff4c3a7a), Color(0xff09142c)],
                stops: [0.0, 0.8],
              ),
            ),
          ),

          ..._buildSparkles(context),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff8a79b8).withOpacity(0.20),
                        blurRadius: 120,
                        spreadRadius: 60,
                      ),
                    ],
                  ),
                  child: Lottie.asset(
                    'assets/animations/Reading Quran.json',
                    width: 280,
                    height: 280,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'إحسان',
                  style: GoogleFonts.amiri(
                    color: Colors.white,
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
          .animate()
          .fadeIn(duration: 1200.ms, curve: Curves.easeOut)
          .slideY(
            begin: 0.2,
            duration: 900.ms,
            curve: Curves.easeOutCubic,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSparkles(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return List.generate(30, (index) {
      final top = (_random.nextDouble() * size.height * 0.5);
      final left = (_random.nextDouble() * size.width);
      final starSize = _random.nextDouble() * 2.5 + 0.5;
      final duration = (800 + _random.nextInt(1200)).ms;
      final delay = (_random.nextInt(1500)).ms;

      return Positioned(
        top: top,
        left: left,
        child: Container(
          width: starSize,
          height: starSize,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
        )
        .animate(
          onPlay: (controller) => controller.repeat(),
        )
        .fade(
          begin: 0.2,
          end: 1.0,
          duration: duration,
          delay: delay,
        )
        .then()
        .fade(
          begin: 1.0,
          end: 0.2,
          duration: duration,
        ),
      );
    });
  }

  final _random = Random();
}