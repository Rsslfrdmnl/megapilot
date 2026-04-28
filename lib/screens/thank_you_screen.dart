// lib/screens/thank_you_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../providers/order_provider.dart';

class ThankYouScreen extends StatelessWidget {
  const ThankYouScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OrderProvider>(context);
    final isMobile = MediaQuery.of(context).size.width < 650;
    final orderId = provider.orderId;   // Using the getter we added

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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),

                    // Success Icon
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_outline,
                        size: 110,
                        color: Colors.green,
                      ),
                    ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack),

                    const SizedBox(height: 40),

                    Text(
                      "THANK YOU!",
                      style: TextStyle(
                        fontSize: isMobile ? 42 : 52,
                        fontWeight: FontWeight.w900,
                        color: Colors.cyan,
                        letterSpacing: 3,
                      ),
                    ).animate().fadeIn(duration: 900.ms),

                    const SizedBox(height: 8),
                    Text(
                      "Order ID: $orderId",
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 40),

                    const Text(
                      "Your order is being processed.\nFor the meantime, you can contact us for updates or inquiries.",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 50),

                    // Order Summary
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.cyan.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "ORDER SUMMARY",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.cyan),
                          ),
                          const Divider(height: 30, color: Colors.white24),

                          _buildDetail("Game", provider.selectedGame ?? "-"),
                          _buildDetail("Service", provider.serviceType ?? "-"),
                          _buildDetail("Total", "₱${provider.totalAmount ?? 0}"),
                        ],
                      ),
                    ),

                    const SizedBox(height: 50),

                    // Contact Info
                    const Text(
                      "Need help? Contact us:",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 16),

                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.facebook, color: Colors.white, size: 28),
                        SizedBox(width: 10),
                        Text("Facebook: Manila alinam WR", style: TextStyle(color: Colors.white, fontSize: 17)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.tiktok, color: Colors.white, size: 28),
                        SizedBox(width: 10),
                        Text("TikTok: @manilawr", style: TextStyle(color: Colors.white, fontSize: 17)),
                      ],
                    ),

                    const SizedBox(height: 70),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          provider.clearOrder();
                          context.go('/choose-game');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyan,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text(
                          "BACK TO HOME",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 16)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}