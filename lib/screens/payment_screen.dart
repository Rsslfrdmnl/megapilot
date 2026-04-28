// lib/screens/payment_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../providers/order_provider.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isLoading = false;

  Future<void> _proceedToFinalSubmission() async {
    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<OrderProvider>(context, listen: false);

      // Basic validation
      if (provider.totalAmount == null || provider.totalAmount! <= 0) {
        throw Exception("Invalid order amount");
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Please complete your details below"),
            backgroundColor: Colors.cyan,
          ),
        );
        context.push('/final-submission');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Something went wrong. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OrderProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 650;
    final bool isCoach = provider.serviceType == 'Coach';

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
              Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 20,
                    vertical: isMobile ? 20 : 24,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 12),

                        Text(
                          "SCAN TO PAY",
                          style: TextStyle(
                            fontSize: isMobile ? 32 : 42,
                            fontWeight: FontWeight.w900,
                            color: Colors.cyan,
                            letterSpacing: 3,
                          ),
                        ).animate().fadeIn(duration: 800.ms),

                        const SizedBox(height: 6),
                        Text(
                          "via GCash or Maya",
                          style: TextStyle(
                            fontSize: isMobile ? 16 : 18,
                            color: Colors.white70,
                            letterSpacing: 1,
                          ),
                        ),

                        SizedBox(height: isMobile ? 32 : 40),

                        // QR Cards
                        isMobile
                            ? Column(
                                children: [
                                  _buildQRCard(title: "GCash", qrUrl: "https://firebasestorage.googleapis.com/v0/b/megapilot-ffe50.firebasestorage.app/o/images%2FGCash.png?alt=media&token=ccd92851-9b6f-4dda-b7f5-d8412995b066", logoUrl: "https://firebasestorage.googleapis.com/v0/b/megapilot-ffe50.firebasestorage.app/o/images%2FGCash_Logo.png?alt=media&token=168f0c47-5bce-47ad-9632-59a0f92c6b9c"),
                                  const SizedBox(height: 32),
                                  _buildQRCard(title: "Maya", qrUrl: "https://firebasestorage.googleapis.com/v0/b/megapilot-ffe50.firebasestorage.app/o/images%2FMaya.png?alt=media&token=b2a31161-a836-41d1-8702-f9af425dd61c", logoUrl: "https://firebasestorage.googleapis.com/v0/b/megapilot-ffe50.firebasestorage.app/o/images%2Fmaya_logo.png?alt=media&token=15908e17-383f-4013-956c-72f1316d3348"),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildQRCard(title: "GCash", qrUrl: "https://firebasestorage.googleapis.com/v0/b/megapilot-ffe50.firebasestorage.app/o/images%2FGCash.png?alt=media&token=ccd92851-9b6f-4dda-b7f5-d8412995b066", logoUrl: "https://firebasestorage.googleapis.com/v0/b/megapilot-ffe50.firebasestorage.app/o/images%2FGCash_Logo.png?alt=media&token=168f0c47-5bce-47ad-9632-59a0f92c6b9c"),
                                  const SizedBox(width: 40),
                                  _buildQRCard(title: "Maya", qrUrl: "https://firebasestorage.googleapis.com/v0/b/megapilot-ffe50.firebasestorage.app/o/images%2FMaya.png?alt=media&token=b2a31161-a836-41d1-8702-f9af425dd61c", logoUrl: "https://firebasestorage.googleapis.com/v0/b/megapilot-ffe50.firebasestorage.app/o/images%2Fmaya_logo.png?alt=media&token=15908e17-383f-4013-956c-72f1316d3348"),
                                ],
                              ),

                        SizedBox(height: isMobile ? 40 : 50),

                        // Order Summary
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(isMobile ? 20 : 24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.cyan.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("ORDER SUMMARY", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.cyan)),
                              const Divider(color: Colors.white24, height: 30),

                              if (isCoach) ...[
                                _buildDetailRow("Service", "Coaching Session"),
                                _buildDetailRow("Rank", provider.currentDivision ?? "-"),
                                _buildDetailRow("Duration", "${provider.hours} hour${(provider.hours ?? 0) > 1 ? 's' : ''}"),
                              ] else ...[
                                _buildDetailRow("Service", "${provider.serviceType ?? 'Boost'}"),
                                _buildDetailRow("Current", "${provider.currentDivision ?? ''} ${provider.currentTier ?? ''} • ${provider.currentMarks ?? 0} marks"),
                                _buildDetailRow("Target", "${provider.targetDivision ?? ''} ${provider.targetTier ?? ''} • ${provider.targetMarks ?? 0} marks"),
                              ],

                              const Divider(color: Colors.white24, height: 36),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("TOTAL AMOUNT", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white)),
                                  Text("₱${provider.totalAmount ?? 0}", style: TextStyle(fontSize: isMobile ? 32 : 36, fontWeight: FontWeight.bold, color: Colors.cyan)),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: isMobile ? 40 : 50),

                        // Warning Box
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.orange.withOpacity(0.4)),
                          ),
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.info_outline, color: Colors.orange, size: 28),
                              SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  "Before you click NEXT, make sure you paid the exact amount and save a screenshot of your payment that is to be uploaded later for proof!",
                                  style: TextStyle(color: Colors.white, fontSize: 15.5, height: 1.5),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        SizedBox(
                          width: double.infinity,
                          height: isMobile ? 54 : 58,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _proceedToFinalSubmission,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.cyan,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.black, strokeWidth: 3)
                                : const Text("NEXT", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),

              // Navigation Buttons
              Positioned(top: 20, left: 20, child: _buildNavButton(icon: Icons.arrow_back_ios_new, onTap: () => context.pop())),
              Positioned(top: 20, right: 20, child: _buildNavButton(icon: Icons.home, onTap: () => context.go('/choose-game'))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQRCard({required String title, required String qrUrl, required String logoUrl}) {
    return Column(
      children: [
        CachedNetworkImage(
          imageUrl: logoUrl,
          height: 42,
          placeholder: (context, url) => const SizedBox(height: 42, width: 100, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
          errorWidget: (context, url, error) => Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.cyan.withOpacity(0.35), blurRadius: 25, spreadRadius: 3)],
          ),
          child: CachedNetworkImage(
            imageUrl: qrUrl,
            width: 170,
            height: 170,
            fit: BoxFit.contain,
            placeholder: (context, url) => const SizedBox(width: 170, height: 170, child: Center(child: CircularProgressIndicator(color: Colors.cyan))),
            errorWidget: (context, url, error) => const Icon(Icons.qr_code_2, size: 130, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 16))),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _buildNavButton({required IconData icon, required VoidCallback onTap}) {
    return _NavButton(icon: icon, onTap: onTap);
  }
}

// Keep your existing _NavButton class
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
          transform: Matrix4.identity()..scale(_isHovered ? 1.15 : 1.0),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _isHovered ? Colors.white.withOpacity(0.25) : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(widget.icon, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}