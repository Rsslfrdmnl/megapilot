// lib/screens/intro_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  // ← PASTE YOUR LOGO DOWNLOAD URL HERE
  final String logoUrl = "https://firebasestorage.googleapis.com/v0/b/megapilot-ffe50.firebasestorage.app/o/images%2Fmegapilot_logo.png?alt=media&token=2106346f-a788-46e9-8ddf-c7fff2ee3859";

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) context.go('/choose-game');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0A0A), Color(0xFF1A1A2E)],
          ),
        ),
        child: Center(
          child: CachedNetworkImage(
            imageUrl: logoUrl,
            width: 650,
            fit: BoxFit.contain,
            placeholder: (context, url) => const CircularProgressIndicator(color: Colors.cyan),
            errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.red, size: 80),
          ).animate()
              .fadeIn(duration: 900.ms)
              .scale(begin: const Offset(0.4, 0.4), end: const Offset(1.0, 1.0), duration: 1800.ms, curve: Curves.easeOutCubic)
              .then(delay: 300.ms)
              .fadeOut(duration: 700.ms),
        ),
      ),
    );
  }
}