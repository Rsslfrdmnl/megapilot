// lib/screens/payment_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PaymentScreen extends StatelessWidget {
  final String serviceType;
  final int totalAmount;
  final String? currentDivision;
  final String? currentTier;
  final int? currentMarks;
  final String? targetDivision;
  final String? targetTier;
  final int? targetMarks;
  final int? hours;

  const PaymentScreen({
    super.key,
    required this.serviceType,
    required this.totalAmount,
    this.currentDivision,
    this.currentTier,
    this.currentMarks,
    this.targetDivision,
    this.targetTier,
    this.targetMarks,
    this.hours,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCoach = serviceType == 'Coach';
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 700;

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
              // Main Content - Non-scrollable, centered layout
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 20),

                        Text(
                          "SCAN TO PAY",
                          style: TextStyle(
                            fontSize: isMobile ? 34 : 42,
                            fontWeight: FontWeight.w900,
                            color: Colors.cyan,
                            letterSpacing: 3,
                          ),
                        ).animate().fadeIn(duration: 800.ms),

                        const SizedBox(height: 6),
                        Text(
                          "via GCash or Maya",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                            letterSpacing: 1,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // QR Codes
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildQRCard(
                              title: "GCash",
                              qrUrl: "https://firebasestorage.googleapis.com/v0/b/megapilot-ffe50.firebasestorage.app/o/images%2FGCash.png?alt=media&token=ccd92851-9b6f-4dda-b7f5-d8412995b066", // ← Update token
                            ),
                            const SizedBox(width: 30),
                            _buildQRCard(
                              title: "Maya",
                              qrUrl: "https://firebasestorage.googleapis.com/v0/b/megapilot-ffe50.firebasestorage.app/o/images%2FMaya.png?alt=media&token=b2a31161-a836-41d1-8702-f9af425dd61c", // ← Update token
                            ),
                          ],
                        ),

                        const SizedBox(height: 50),

                        // Order Summary Card
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
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.cyan,
                                ),
                              ),
                              const Divider(color: Colors.white24, height: 30),

                              if (isCoach) ...[
                                _buildDetailRow("Service", "Coaching Session"),
                                _buildDetailRow("Rank", currentDivision ?? "-"),
                                _buildDetailRow("Duration", "$hours hour${(hours ?? 0) > 1 ? 's' : ''}"),
                              ] else ...[
                                _buildDetailRow("Service", "$serviceType Service"),
                                _buildDetailRow(
                                  "Current",
                                  "${currentDivision ?? ''} ${currentTier ?? ''} • ${currentMarks ?? 0} marks",
                                ),
                                _buildDetailRow(
                                  "Target",
                                  "${targetDivision ?? ''} ${targetTier ?? ''} • ${targetMarks ?? 0} marks",
                                ),
                              ],

                              const Divider(color: Colors.white24, height: 40),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "TOTAL AMOUNT",
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
                                  ),
                                  Text(
                                    "₱$totalAmount",
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.cyan,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 50),

                        // Next Button
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: ElevatedButton(
                            onPressed: () {
                              // TODO: Later connect to Firebase
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Proceeding to next step..."),
                                  backgroundColor: Colors.cyan,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.cyan,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              "NEXT",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),

              // Top Navigation - Same style as other screens
              Positioned(
                top: 20,
                left: 20,
                child: _buildNavButton(
                  icon: Icons.arrow_back_ios_new,
                  onTap: () => context.pop(),
                ),
              ),
              Positioned(
                top: 20,
                right: 20,
                child: _buildNavButton(
                  icon: Icons.home,
                  onTap: () => context.go('/choose-game'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQRCard({required String title, required String qrUrl}) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.cyan.withOpacity(0.35),
                blurRadius: 25,
                spreadRadius: 3,
              ),
            ],
          ),
          child: CachedNetworkImage(
            imageUrl: qrUrl,
            width: 190,
            height: 190,
            fit: BoxFit.contain,
            placeholder: (context, url) => const SizedBox(
              width: 190,
              height: 190,
              child: Center(child: CircularProgressIndicator(color: Colors.cyan)),
            ),
            errorWidget: (context, url, error) => const Icon(Icons.qr_code_2, size: 140, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Reusable Nav Button (same as other screens)
  Widget _buildNavButton({required IconData icon, required VoidCallback onTap}) {
    return _NavButton(icon: icon, onTap: onTap);
  }
}

// Navigation Button (copy from your other screens)
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