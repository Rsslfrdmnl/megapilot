// lib/screens/choose_game_screen.dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/order_provider.dart';

class ChooseGameScreen extends StatefulWidget {
  const ChooseGameScreen({super.key});

  @override
  State<ChooseGameScreen> createState() => _ChooseGameScreenState();
}

class _ChooseGameScreenState extends State<ChooseGameScreen> {
  VideoPlayerController? _hoverVideoController;
  String? _currentHoverGame;
  bool _showVideo = false;

  final String wildRiftVideoUrl = "https://firebasestorage.googleapis.com/v0/b/megapilot-ffe50.firebasestorage.app/o/videos%2Fwild_rift_gameplay.mp4?alt=media&token=8ef36178-80b8-49c4-948a-7b9545b59075";

  @override
  void initState() {
    super.initState();
    _initVideoController();
  }

  void _initVideoController() {
    _hoverVideoController = VideoPlayerController.networkUrl(Uri.parse(wildRiftVideoUrl))
      ..initialize().then((_) {
        if (mounted) setState(() {});
      });
  }

  void _onHover(String gameKey, bool isHovering) async {
    if (isHovering) {
      if (_currentHoverGame != gameKey) {
        setState(() => _currentHoverGame = gameKey);

        await Future.delayed(const Duration(milliseconds: 300));

        if (_currentHoverGame == gameKey && gameKey == 'wildrift') {
          final controller = _hoverVideoController;
          if (controller != null && controller.value.isInitialized) {
            await controller.setLooping(true);
            await controller.setVolume(0.0);
            await controller.play();
            setState(() => _showVideo = true);
          }
        }
      }
    } else {
      if (_currentHoverGame == gameKey) {
        setState(() => _showVideo = false);
        await Future.delayed(const Duration(milliseconds: 400));
        _hoverVideoController?.pause();
        setState(() => _currentHoverGame = null);
      }
    }
  }

  @override
  void dispose() {
    _hoverVideoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;
    final cardWidth = isMobile ? (screenWidth - 60) / 2 : 230.0; // 2 cards per row on small screens

    final bool isHoveringWildRift = _currentHoverGame == 'wildrift';

    return Scaffold(
      body: Stack(
        children: [
          Container(color: const Color(0xFF0A0A0A)),

          // Video Background
          AnimatedOpacity(
            opacity: (_showVideo && isHoveringWildRift && _hoverVideoController?.value.isInitialized == true) ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            child: SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: _hoverVideoController?.value.isInitialized == true
                    ? SizedBox(
                        width: _hoverVideoController!.value.size?.width ?? 1280,
                        height: _hoverVideoController!.value.size?.height ?? 720,
                        child: VideoPlayer(_hoverVideoController!),
                      )
                    : const SizedBox(),
              ),
            ),
          ),

          // Dark overlay
          AnimatedOpacity(
            opacity: _showVideo && isHoveringWildRift ? 0.45 : 0.0,
            duration: const Duration(milliseconds: 600),
            child: Container(color: Colors.black),
          ),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),

                Text(
                  "CHOOSE A GAME",
                  style: TextStyle(
                    fontSize: isMobile ? 42 : 58,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 4,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 900.ms).slideY(begin: -0.8, end: 0),

                SizedBox(height: isMobile ? 32 : 70),

                // Game Cards
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 28,
                        runSpacing: 28,
                        children: [
                          _buildGameCard(
                            keyName: 'wildrift',
                            imageUrl: "https://firebasestorage.googleapis.com/v0/b/megapilot-ffe50.firebasestorage.app/o/images%2Fwildrift.jpg?alt=media&token=01fca6d0-dd0c-4f8c-b86f-f7443b4de579",
                            title: "League of Legends\nWild Rift",
                            isActive: true,
                            cardWidth: isMobile ? (screenWidth - 72) / 2 : 230,
                          ),
                          _buildGameCard(
                            keyName: 'mobile_legends',
                            imageUrl: "https://firebasestorage.googleapis.com/v0/b/megapilot-ffe50.firebasestorage.app/o/images%2Fmobile_legends.jpg?alt=media&token=64172c85-72c5-415f-be6f-da6d9059c413",
                            title: "Mobile Legends",
                            isActive: false,
                            cardWidth: isMobile ? (screenWidth - 72) / 2 : 230,
                          ),
                          _buildGameCard(
                            keyName: 'hok',
                            imageUrl: "https://firebasestorage.googleapis.com/v0/b/megapilot-ffe50.firebasestorage.app/o/images%2Fhonor_of_kings.png?alt=media&token=f6746c34-3e9b-4021-b7f1-5676ec3bc87e",
                            title: "Honor of Kings",
                            isActive: false,
                            cardWidth: isMobile ? (screenWidth - 72) / 2 : 230,
                          ),
                          _buildGameCard(
                            keyName: 'valorant',
                            imageUrl: "https://firebasestorage.googleapis.com/v0/b/megapilot-ffe50.firebasestorage.app/o/images%2Fvalorant.jpg?alt=media&token=89302108-ac38-49cd-ad95-3f05099f6fd0",
                            title: "Valorant",
                            isActive: false,
                            cardWidth: isMobile ? (screenWidth - 72) / 2 : 230,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Logo at bottom - no Spacer
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
        ],
      ),
    );
  }

  Widget _buildGameCard({
  required String keyName,
  required String imageUrl,
  required String title,
  required bool isActive,
  required double cardWidth,
}) {
  final bool isHovered = _currentHoverGame == keyName;

  return MouseRegion(
    onEnter: (_) => _onHover(keyName, true),
    onExit: (_) => _onHover(keyName, false),
    hitTestBehavior: HitTestBehavior.opaque,
    cursor: isActive ? SystemMouseCursors.click : SystemMouseCursors.basic,
    child: GestureDetector(
      onTap: isActive ? () {
        // Save selected game using Provider
        final provider = Provider.of<OrderProvider>(context, listen: false);
        provider.selectGame("Wild Rift");

        context.push('/choose-service');
      } : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        transform: Matrix4.identity()..scale(isHovered ? 1.06 : 1.0),
        child: Container(
          width: cardWidth,
          height: cardWidth * 1.48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: isHovered
                ? [BoxShadow(color: isActive ? Colors.cyan.withOpacity(0.75) : Colors.white24, blurRadius: 35, spreadRadius: 6)]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  color: isActive ? null : Colors.grey[700],
                  colorBlendMode: isActive ? null : BlendMode.saturation,
                ),
                if (!isActive)
                  Container(
                    color: Colors.black.withOpacity(0.78),
                    child: const Center(
                      child: Text(
                        "COMING SOON",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 40, 16, 20),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87],
                      ),
                    ),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                if (isHovered)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isActive ? Colors.cyan : Colors.white70,
                          width: 3.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}