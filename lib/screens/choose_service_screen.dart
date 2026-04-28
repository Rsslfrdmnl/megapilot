// lib/screens/choose_service_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

import '../providers/order_provider.dart';

class ChooseServiceScreen extends StatelessWidget {
  const ChooseServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    final buttonWidth = isMobile ? screenWidth * 0.85 : 460.0;
    final titleFontSize = isMobile ? 38.0 : 52.0;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0A0A), Color(0xFF1A1A2E)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Main Content
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Title
                      Text(
                        "CHOOSE YOUR SERVICE",
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 3,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.5, end: 0),

                      SizedBox(height: isMobile ? 60 : 100),

                      // Service Buttons
                      _ServiceButton(
                        title: "PILOT",
                        width: buttonWidth,
                        onTap: () {
                          Provider.of<OrderProvider>(context, listen: false).selectService("Pilot");
                          context.push('/order-form', extra: 'Pilot');
                        },
                      ),
                      const SizedBox(height: 20),

                      _ServiceButton(
                        title: "BOOST",
                        width: buttonWidth,
                        onTap: () {
                          Provider.of<OrderProvider>(context, listen: false).selectService("Boost");
                          context.push('/order-form', extra: 'Boost');
                        },
                      ),
                      const SizedBox(height: 20),

                      _ServiceButton(
                        title: "COACH",
                        width: buttonWidth,
                        onTap: () {
                          Provider.of<OrderProvider>(context, listen: false).selectService("Coach");
                          context.push('/order-form', extra: 'Coach');
                        },
                      ),

                      SizedBox(height: isMobile ? 80 : 140),

                      // Bottom Logo
                      Padding(
                  padding: EdgeInsets.only(bottom: isMobile ? 24 : 40),
                  child: CachedNetworkImage(
                    imageUrl: "https://firebasestorage.googleapis.com/v0/b/megapilot-ffe50.firebasestorage.app/o/images%2Fmegapilot_logo.png?alt=media&token=2106346f-a788-46e9-8ddf-c7fff2ee3859",
                    height: isMobile ? 55 : 65,
                  ),
                ),
                    ],
                  ),
                ),
              ),

              // Top Navigation
              Positioned(
                top: 20,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _NavButton(
                      icon: Icons.arrow_back_ios_new,
                      onTap: () => context.pop(),
                    ),
                    _NavButton(
                      icon: Icons.home,
                      onTap: () => context.go('/choose-game'),
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
}

// Updated Service Button - Responsive Width
class _ServiceButton extends StatefulWidget {
  final String title;
  final double width;
  final VoidCallback onTap;

  const _ServiceButton({
    required this.title,
    required this.width,
    required this.onTap,
    super.key,
  });

  @override
  State<_ServiceButton> createState() => _ServiceButtonState();
}

class _ServiceButtonState extends State<_ServiceButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.06 : 1.0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          child: Container(
            width: widget.width,
            height: 92,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyan.withOpacity(0.4),
                  blurRadius: 25,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Center(
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0A0A0A),
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Navigation Button with Hover Effect (unchanged)
class _NavButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavButton({required this.icon, required this.onTap, super.key});

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()..scale(_isHovered ? 1.15 : 1.0),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _isHovered 
                ? Colors.white.withOpacity(0.25)
                : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            widget.icon, 
            color: Colors.white, 
            size: 28,
          ),
        ),
      ),
    );
  }
}