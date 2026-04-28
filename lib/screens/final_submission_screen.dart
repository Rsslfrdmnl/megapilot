// lib/screens/final_submission_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../providers/order_provider.dart';

class FinalSubmissionScreen extends StatefulWidget {
  const FinalSubmissionScreen({super.key});

  @override
  State<FinalSubmissionScreen> createState() => _FinalSubmissionScreenState();
}

class _FinalSubmissionScreenState extends State<FinalSubmissionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ignController = TextEditingController();
  final _riotUserController = TextEditingController();
  final _riotPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  XFile? _proofImage;
  Uint8List? _webImageBytes;
  bool _isLoading = false;
  String _statusMessage = "";
  String _uploadProgress = "";

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (image == null) return;

      setState(() {
        _proofImage = image;
        _statusMessage = "";
        _uploadProgress = "";
      });

      if (kIsWeb) {
        _webImageBytes = await image.readAsBytes();
      }
    } catch (e) {
      setState(() => _statusMessage = "❌ Failed to pick image");
    }
  }

  Future<String?> _uploadProofImage() async {
    if (_proofImage == null) return null;

    setState(() {
      _statusMessage = "Uploading proof of payment...";
      _uploadProgress = "0%";
    });

    try {
      final fileName = "proof_${DateTime.now().millisecondsSinceEpoch}.jpg";
      final ref = FirebaseStorage.instance.ref().child('proofs/$fileName');

      UploadTask uploadTask;

      if (kIsWeb && _webImageBytes != null) {
        uploadTask = ref.putData(_webImageBytes!);
      } else if (!kIsWeb) {
        uploadTask = ref.putFile(File(_proofImage!.path));
      } else {
        return null;
      }

      // Show upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        if (mounted) {
          final progress = (snapshot.bytesTransferred / snapshot.totalBytes * 100).toStringAsFixed(0);
          setState(() => _uploadProgress = "$progress%");
        }
      });

      await uploadTask;
      final url = await ref.getDownloadURL();

      setState(() {
        _statusMessage = "✅ Proof uploaded successfully";
        _uploadProgress = "";
      });
      return url;
    } catch (e) {
      setState(() {
        _statusMessage = "❌ Upload failed. Please try again.";
        _uploadProgress = "";
      });
      return null;
    }
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    if (_proofImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload proof of payment"), backgroundColor: Colors.red),
      );
      return;
    }

    if (_riotPassController.text != _confirmPassController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    final provider = Provider.of<OrderProvider>(context, listen: false);

    try {
      final proofUrl = await _uploadProofImage();
      if (proofUrl == null) throw Exception("Failed to upload proof");

      provider.updateFinalDetails(
        name: _nameController.text.trim(),
        ignName: _ignController.text.trim(),
        riotUser: _riotUserController.text.trim(),
        riotPass: _riotPassController.text.trim(),
        proofUrl: proofUrl,
      );

      await FirebaseFirestore.instance.collection('orders').add(provider.toMap());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Order submitted successfully!", style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/thank-you');
      }
    } catch (e) {
      String errorMsg = "Submission failed. Please try again.";

      if (e.toString().contains("permission-denied")) {
        errorMsg = "Permission error. Please check your connection.";
      } else if (e.toString().contains("network")) {
        errorMsg = "No internet connection.";
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 650;

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
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Text("FINAL DETAILS", 
                            style: TextStyle(fontSize: isMobile ? 32 : 42, fontWeight: FontWeight.w900, color: Colors.cyan))
                              .animate().fadeIn(),

                          const SizedBox(height: 40),

                          _buildTextField("Full Name", _nameController, "Enter your full name"),
                          const SizedBox(height: 20),
                          _buildTextField("In-Game Name (IGN)", _ignController, "Your in-game name"),
                          const SizedBox(height: 20),
                          _buildTextField("Riot Username", _riotUserController, "username#tag"),
                          const SizedBox(height: 20),
                          _buildTextField("Riot Password", _riotPassController, "Enter password", obscureText: true),
                          const SizedBox(height: 20),
                          _buildTextField("Confirm Password", _confirmPassController, "Confirm password", obscureText: true),

                          const SizedBox(height: 40),

                          const Text("Proof of Payment (Screenshot)", 
                              style: TextStyle(color: Colors.white70, fontSize: 17)),
                          const SizedBox(height: 12),

                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              height: 180,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.cyan.withOpacity(0.4)),
                              ),
                              child: _proofImage != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: kIsWeb 
                                          ? (_webImageBytes != null ? Image.memory(_webImageBytes!, fit: BoxFit.cover) : const CircularProgressIndicator())
                                          : Image.file(File(_proofImage!.path), fit: BoxFit.cover),
                                    )
                                  : const Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.cloud_upload_outlined, size: 60, color: Colors.cyan),
                                        SizedBox(height: 12),
                                        Text("Tap to upload screenshot", style: TextStyle(color: Colors.white70)),
                                      ],
                                    ),
                            ),
                          ),

                          if (_statusMessage.isNotEmpty || _uploadProgress.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(
                                _uploadProgress.isNotEmpty ? "Uploading: $_uploadProgress" : _statusMessage,
                                style: TextStyle(
                                  color: _statusMessage.contains("✅") ? Colors.green : Colors.orange,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                          const SizedBox(height: 30),

                          // Warning Message
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
                                    "Double check every information you input before you submit order!",
                                    style: TextStyle(color: Colors.white, fontSize: 15.5, height: 1.5),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),

                          SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _submitOrder,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.cyan,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.black)
                                  : const Text("SUBMIT ORDER", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Navigation Buttons
              Positioned(
                top: 20,
                left: 20,
                child: _buildNavButton(icon: Icons.arrow_back_ios_new, onTap: () => context.pop()),
              ),
              Positioned(
                top: 20,
                right: 20,
                child: _buildNavButton(icon: Icons.home, onTap: () => context.go('/choose-game')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Keep your existing _buildTextField and _buildNavButton widgets...
  Widget _buildTextField(String label, TextEditingController controller, String hint, {bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 16)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          validator: (value) => value == null || value.trim().isEmpty ? "This field is required" : null,
        ),
      ],
    );
  }

  Widget _buildNavButton({required IconData icon, required VoidCallback onTap}) {
    return _NavButton(icon: icon, onTap: onTap);
  }
}

// Keep your _NavButton class unchanged
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