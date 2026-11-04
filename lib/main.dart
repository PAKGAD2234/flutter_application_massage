
import 'package:flutter/material.dart';
import 'package:flutter_application_massage/view/landing_ui.dart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import Pages
import 'package:flutter_application_massage/view/splash_ui.dart';
import 'package:flutter_application_massage/view/login_ui.dart';
import 'package:flutter_application_massage/view/booking_ui.dart';
import 'package:flutter_application_massage/view/ai_chat_ui.dart';
import 'package:flutter_application_massage/view/my_booking_ui.dart';
import 'package:flutter_application_massage/view/profile_ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Connect Supabase
  await Supabase.initialize(
    url: 'https://demo.supabase.co',
    publishableKey: 'sb_publishable_demo',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'MASSAGE AI',

      // Theme
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF426B55),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F6F0),
        textTheme: GoogleFonts.promptTextTheme(),
      ),
      // Routes
      initialRoute: '/',

      routes: {
        '/': (context) => const SplashUi(),
        '/login': (context) => const LoginUi(),
        '/home': (context) => const LandingUi(),
        '/booking': (context) => const BookingUi(),
        '/ai-chat': (context) => const AiChatUi(),
        '/my-booking': (context) => const MyBookingUi(),
        '/profile': (context) => const ProfileUi(),
      },
    );
  }
}
