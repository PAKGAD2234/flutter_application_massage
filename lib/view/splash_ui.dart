import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_application_massage/view/landing_ui.dart.dart';


class SplashUi extends StatefulWidget {
  const SplashUi({super.key});

  @override
  State<SplashUi> createState() => _SplashUiState();
}

class _SplashUiState extends State<SplashUi>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    // รอ 3 วินาทีแล้วไปหน้าถัดไป
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      // TODO: เปลี่ยนเป็นหน้าที่ต้องการไป

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LandingUi(), // เปลี่ยนเป็นหน้าที่ต้องการไป
        ),  
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/splash.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: _buildWaveDots(),
            ),
          ),
        ),
      ),
    );
  }

  /// จุด 3 จุดเด้งเป็นคลื่นสลับกัน
  Widget _buildWaveDots() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            // เลื่อนเฟสของแต่ละจุดให้เด้งไม่พร้อมกัน
            final phase = (_controller.value + index * 0.2) % 1.0;
            final dy = -math.sin(phase * math.pi) * 14;
            final scale = 0.8 + math.sin(phase * math.pi) * 0.4;

            return Transform.translate(
              offset: Offset(0, dy),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}