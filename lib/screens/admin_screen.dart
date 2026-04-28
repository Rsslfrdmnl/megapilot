// lib/screens/admin_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  Future<void> _updateStatus(BuildContext context, String docId, String newStatus) async {
  try {
    await FirebaseFirestore.instance.collection('orders').doc(docId).update({
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Order successfully marked as $newStatus"),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Failed to update status. Please try again."),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed': return Colors.green;
      case 'confirmed': return Colors.blue;
      case 'declined': return Colors.red;
      default: return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 650;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/admin-login'));
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("MEGAPILOT ADMIN", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.white)),
        backgroundColor: const Color(0xFF0F0F1A),
        elevation: 2,
        actions: [
          IconButton(icon: const Icon(Icons.logout),
            style: IconButton.styleFrom(
              foregroundColor: Colors.white,
            ), onPressed: () async {
            await FirebaseAuth.instance.signOut();
            if (context.mounted) context.go('/admin-login');
          }),
        ],
      ),
      body: Container(
        color: const Color(0xFF0A0A0A),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('orders').orderBy('createdAt', descending: true).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.cyan));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No orders yet", style: TextStyle(fontSize: 22, color: Colors.white70)));
            }

            final orders = snapshot.data!.docs;

            return ListView.builder(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final doc = orders[index];
                final data = doc.data() as Map<String, dynamic>;
                final orderId = data['orderId'] ?? doc.id.substring(0, 8).toUpperCase();
                final status = data['status'] ?? 'pending';
                final proofUrl = data['proofOfPaymentUrl'];
                final isCoach = data['serviceType'] == 'Coach';

                return Container(
                  margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.cyan.withOpacity(0.25)),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(isMobile ? 16 : 20),
                    leading: const Icon(Icons.receipt_long, color: Colors.cyan, size: 42),
                    title: Text("Order #$orderId", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text("Customer: ${data['fullName'] ?? '-'}", style: const TextStyle(color: Colors.white, fontSize: 16)),
                        Text("IGN: ${data['ign'] ?? '-'}", style: const TextStyle(color: Colors.white70)),
                        Text("Service: ${data['serviceType'] ?? '-'}", style: const TextStyle(color: Colors.white70)),
                        const SizedBox(height: 6),
                        Text("Total: ₱${data['totalAmount'] ?? 0}", style: const TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(status).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(status.toUpperCase(), style: TextStyle(color: _getStatusColor(status), fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                        const SizedBox(width: 12),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: Colors.white),
                          onSelected: (value) => _updateStatus(context, doc.id, value),
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: "pending", child: Text("Mark as Pending")),
                            const PopupMenuItem(value: "confirmed", child: Text("Mark as Confirmed")),
                            const PopupMenuItem(value: "completed", child: Text("Mark as Completed")),
                            const PopupMenuItem(value: "declined", child: Text("Mark as Declined")),
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: const Color(0xFF1A1A2E),
                          title: Text("Order #$orderId", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          content: SizedBox(
                            width: 500,           // Fixed reasonable width
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("Game: ${data['game'] ?? '-'}", style: const TextStyle(color: Colors.white)),
                                  const SizedBox(height: 12),
                    
                                  Text("Full Name: ${data['fullName'] ?? '-'}", style: const TextStyle(color: Colors.white)),
                                  const SizedBox(height: 8),
                                  Text("IGN: ${data['ign'] ?? '-'}", style: const TextStyle(color: Colors.white)),
                                  const SizedBox(height: 8),
                                  Text("Riot Username: ${data['riotUsername'] ?? '-'}", style: const TextStyle(color: Colors.white)),
                                  const SizedBox(height: 8),
                                  Text("Riot Password: ${data['riotPassword'] ?? '-'}", style: const TextStyle(color: Colors.white)),
                                  const SizedBox(height: 8),
                                  Text("Service: ${data['serviceType'] ?? '-'}", style: const TextStyle(color: Colors.white)),
                                  const SizedBox(height: 8),
                                  Text("Total: ₱${data['totalAmount'] ?? 0}", style: const TextStyle(color: Colors.white)),

                                  const SizedBox(height: 20),

                                  const Text("CURRENT RANK", style: TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold)),
                                  Text("Division: ${data['currentDivision'] ?? '-'}", style: const TextStyle(color: Colors.white)),
                                  Text("Tier: ${data['currentTier'] ?? '-'}", style: const TextStyle(color: Colors.white)),
                                  Text("Marks: ${data['currentMarks'] ?? '-'}", style: const TextStyle(color: Colors.white)),
                                  const SizedBox(height: 12),
                    
                                  const Text("TARGET RANK", style: TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold)),
                                  Text("Division: ${data['targetDivision'] ?? '-'}", style: const TextStyle(color: Colors.white)),
                                  Text("Tier: ${data['targetTier'] ?? '-'}", style: const TextStyle(color: Colors.white)),
                                  Text("Marks: ${data['targetMarks'] ?? '-'}", style: const TextStyle(color: Colors.white)),
                                  const SizedBox(height: 12),
                    
                                  if (data['serviceType'] == 'Coach')
                                    Text("Hours: ${data['hours'] ?? '-'}", style: const TextStyle(color: Colors.white)),
                    
                                  const SizedBox(height: 16),
                                  if (data['proofOfPaymentUrl'] != null) ...[
                                    const Text("Proof of Payment:", style: TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold)),
                                                        const SizedBox(height: 8),
                                    CachedNetworkImage(imageUrl: data['proofOfPaymentUrl']),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Close", style: TextStyle(color: Colors.cyan)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}