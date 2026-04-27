// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'screens/intro_screen.dart';
import 'screens/choose_game_screen.dart';
import 'screens/choose_service_screen.dart';
import 'screens/order_form_screen.dart';
import 'screens/payment_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MegapilotApp());
}

class MegapilotApp extends StatelessWidget {
  const MegapilotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Megapilot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: GoogleFonts.poppins().fontFamily,
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      ),
      routerConfig: _router,
    );
  }
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const IntroScreen()),
    GoRoute(path: '/choose-game', builder: (context, state) => const ChooseGameScreen()),
    GoRoute(
      path: '/choose-service',
      builder: (context, state) => const ChooseServiceScreen(),
    ),
    GoRoute(
      path: '/order-form',
      builder: (context, state) {
        final serviceType = state.extra as String? ?? 'Pilot';
        return OrderFormScreen(serviceType: serviceType);
      },
    ),
    // NEW ROUTE
    GoRoute(
      path: '/payment',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return PaymentScreen(
          serviceType: extra['serviceType'] as String? ?? 'Pilot',
          totalAmount: extra['totalAmount'] as int? ?? 0,
          currentDivision: extra['currentDivision'] as String?,
          currentTier: extra['currentTier'] as String?,
          currentMarks: extra['currentMarks'] as int?,
          targetDivision: extra['targetDivision'] as String?,
          targetTier: extra['targetTier'] as String?,
          targetMarks: extra['targetMarks'] as int?,
          hours: extra['hours'] as int?,
        );
      },
    ),
  ],
);