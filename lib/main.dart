import 'package:flutter/material.dart';
import 'package:flutter_application_massage/view/landing_ui.dart.dart';
import 'package:flutter_application_massage/theme/app_theme.dart';

// Import Pages
import 'package:flutter_application_massage/view/splash_ui.dart';
import 'package:flutter_application_massage/view/booking_ui.dart';
import 'package:flutter_application_massage/view/ai_chat_ui.dart';
import 'package:flutter_application_massage/view/my_booking_ui.dart';
import 'package:flutter_application_massage/view/profile_ui.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'MASSAGE AI',

      theme: ZenTouchTheme.light,
      // Routes
      initialRoute: '/',

      routes: {
        '/': (context) => const SplashUi(),
        '/home': (context) => const LandingUi(),
        '/booking': (context) => const BookingUi(),
        '/ai-chat': (context) => const AiChatUi(),
        '/my-booking': (context) => const MyBookingUi(),
        '/profile': (context) => const ProfileUi(),
      },
    );
  }
}
