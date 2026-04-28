// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'providers/order_provider.dart';

import 'screens/intro_screen.dart';
import 'screens/choose_game_screen.dart';
import 'screens/choose_service_screen.dart';
import 'screens/order_form_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/final_submission_screen.dart';
import 'screens/thank_you_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/admin_login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => OrderProvider(),
      child: const MegapilotApp(),
    ),
  );
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
    
    GoRoute(
      path: '/choose-game',
      builder: (context, state) => const ChooseGameScreen(),
    ),
    
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
    
    GoRoute(
      path: '/payment',
      builder: (context, state) => const PaymentScreen(),
    ),
    
    GoRoute(
      path: '/final-submission',
      builder: (context, state) => const FinalSubmissionScreen(),
    ),
    
    GoRoute(
      path: '/thank-you',
      builder: (context, state) => const ThankYouScreen(),
    ),

    GoRoute(
      path: '/admin-login',
      builder: (context, state) => const AdminLoginScreen(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminScreen(),
    ),
  ],
);