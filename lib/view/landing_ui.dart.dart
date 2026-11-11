import 'package:flutter/material.dart';
import 'package:flutter_application_massage/theme/app_theme.dart';

class LandingUi extends StatelessWidget {
  const LandingUi({super.key});

  static const Color primaryGreen = ZenTouchColors.primary;
  static const Color backgroundColor = ZenTouchColors.background;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      // App Bar
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MASSAGE AI',
              style: TextStyle(
                color: primaryGreen,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              'SPA & WELLNESS',
              style: TextStyle(
                color: ZenTouchColors.textSecondary,
                fontSize: 10,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none,
              color: primaryGreen,
              size: 27,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),

      // Body
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            const Text(
              'สวัสดี 👋',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: ZenTouchColors.primaryDark,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              'วันนี้คุณอยากผ่อนคลายแบบไหน?',
              style: TextStyle(
                fontSize: 15,
                color: ZenTouchColors.textSecondary,
              ),
            ),

            const SizedBox(height: 25),

            // AI Booking Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primaryGreen,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: ZenTouchColors.primaryDark.withValues(alpha: 0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.smart_toy_outlined,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),

                      const SizedBox(width: 12),

                      const Expanded(
                        child: Text(
                          'AI Booking Assistant',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    'ให้ AI ช่วยค้นหาเวลาว่าง แนะนำบริการ '
                    'และเลือกพนักงานนวดที่เหมาะสมกับคุณ',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/ai-chat');
                      },
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text(
                        'เริ่มจองผ่าน AI',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Service Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'บริการของเรา',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ZenTouchColors.primaryDark,
                  ),
                ),

                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'ดูทั้งหมด',
                    style: TextStyle(color: primaryGreen),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Service List
            ServiceCard(
              icon: Icons.spa,
              name: 'นวดแผนไทย',
              description: 'ผ่อนคลายกล้ามเนื้อทั่วร่างกาย',
              duration: '60 นาที',
              price: '300 บาท',
              onTap: () {
                Navigator.pushNamed(context, '/booking');
              },
            ),

            ServiceCard(
              icon: Icons.water_drop_outlined,
              name: 'นวดอโรม่า',
              description: 'ผ่อนคลายด้วยน้ำมันหอมระเหย',
              duration: '90 นาที',
              price: '600 บาท',
              onTap: () {
                Navigator.pushNamed(context, '/booking');
              },
            ),

            ServiceCard(
              icon: Icons.accessibility_new,
              name: 'นวดเท้า',
              description: 'ผ่อนคลายความเมื่อยล้าบริเวณเท้า',
              duration: '60 นาที',
              price: '250 บาท',
              onTap: () {
                Navigator.pushNamed(context, '/booking');
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryGreen,
        unselectedItemColor: ZenTouchColors.textSecondary,
        backgroundColor: ZenTouchColors.surface,
        elevation: 8,
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.pushNamed(context, '/my-booking');
              break;
            case 2:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'หน้าหลัก',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'การจอง',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'โปรไฟล์',
          ),
        ],
      ),
    );
  }
}

// ==========================================
// SERVICE CARD
// ==========================================

class ServiceCard extends StatelessWidget {
  final IconData icon;
  final String name;
  final String description;
  final String duration;
  final String price;
  final VoidCallback onTap;

  const ServiceCard({
    super.key,
    required this.icon,
    required this.name,
    required this.description,
    required this.duration,
    required this.price,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: ZenTouchColors.surface,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: ZenTouchColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Service Icon
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: ZenTouchColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: ZenTouchColors.primary, size: 30),
              ),

              const SizedBox(width: 14),

              // Service Information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      description,
                      style: const TextStyle(
                        color: ZenTouchColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      duration,
                      style: const TextStyle(
                        color: ZenTouchColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: const TextStyle(
                      color: ZenTouchColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: ZenTouchColors.textSecondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// MENU CARD
// ==========================================

class MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const MenuCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 10),
        decoration: BoxDecoration(
          color: ZenTouchColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ZenTouchColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: ZenTouchColors.primary, size: 32),

            const SizedBox(height: 10),

            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
