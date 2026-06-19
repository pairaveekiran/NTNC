import 'package:flutter/material.dart';
import 'package:ntnc/screen/notices.dart';
import 'package:ntnc/screen/off_checkin.dart';
import 'package:ntnc/screen/qr_scanner.dart';
import 'package:ntnc/screen/sp_checkin.dart';
import 'package:ntnc/screen/userprofile.dart';
import 'package:ntnc/widget/animated_counter.dart';
import 'package:ntnc/widget/app_drawer.dart';
import 'package:ntnc/widget/bottom_navigation.dart';

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF2F2F2),
      extendBody: true,

      /// ✅ DRAWER (Menu)
      drawer: const AppDrawer(),

      /// ✅ CENTER SCAN BUTTON
      floatingActionButton: CustomScanFAB(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const QRScannerScreen(),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      /// ✅ BOTTOM NAVIGATION BAR
      bottomNavigationBar: CustomBottomNavigation(
        onNotificationPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NoticesScreen(),
            ),
          );
        },
        onCheckInPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const OfflineScanScreen(),
            ),
          );
        },
      ),

      body: Column(
        children: [
          /// HEADER with Light → Dark Green Gradient
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xff5BA84A), // light green (top)
                  Color(0xff3F8A30), // medium green
                  Color(0xff2D6B21), // dark green (bottom)
                ],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Top App Bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 16, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        /// ✅ MENU ICON — opens drawer
                        Builder(
                          builder: (context) => IconButton(
                            icon: const Icon(
                              Icons.menu_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: () =>
                                Scaffold.of(context).openDrawer(),
                          ),
                        ),
                        Container(
                          height: 44,
                          width: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: const EdgeInsets.all(2),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.asset(
                              "assets/images/ntnc.jpeg",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "NATIONAL TRUST FOR NATURE CONSERVATION",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "राष्ट्रिय प्रकृति संरक्षण कोष",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// Dashboard Title + Welcome + Profile
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Dashboard",
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              "Welcome, User",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        // GestureDetector(
                        //   onTap: () {
                        //     Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //         builder: (context) => const UserProfile(),
                        //       ),
                        //     );
                        //   },
                        //   child: Container(
                        //     padding: const EdgeInsets.all(2),
                        //     decoration: BoxDecoration(
                        //       shape: BoxShape.circle,
                        //       border: Border.all(
                        //         color: Colors.white.withOpacity(0.4),
                        //         width: 2,
                        //       ),
                        //     ),
                        //     child: const CircleAvatar(
                        //       radius: 24,
                        //       backgroundColor: Colors.white24,
                        //       child: Icon(
                        //         Icons.person_rounded,
                        //         size: 28,
                        //         color: Colors.white,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// CONTENT
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Section: Check-in Details
                  const _SectionHeader(title: "Check-in Details"),
                  const SizedBox(height: 14),
                  Row(
                    children: const [
                      Expanded(
                        child: _StatCard(
                          topBarColor: Color(0xff2E7D32),
                          iconBg: Color(0xffE6F4E8),
                          icon: Icons.check_rounded,
                          iconColor: Color(0xff2E7D32),
                          title: "Today's Check IN",
                          value: 219,
                          valueColor: Color(0xff2D6B21),
                        ),
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: _StatCard(
                          topBarColor: Color(0xffF57C00),
                          iconBg: Color(0xffFFF2E5),
                          icon: Icons.show_chart_rounded,
                          iconColor: Color(0xffF57C00),
                          title: "Today's Check OUT",
                          value: 500,
                          valueColor: Color(0xffF57C00),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 26),

                  /// Section: Permit Issued Details
                  const _SectionHeader(title: "Permit Issued Details"),
                  const SizedBox(height: 14),
                  Row(
                    children: const [
                      Expanded(
                        child: _StatCard(
                          topBarColor: Color(0xff1976D2),
                          iconBg: Color(0xffE3F0FB),
                          icon: Icons.description_rounded,
                          iconColor: Color(0xff1976D2),
                          title: "Total Permits",
                          value: 12000,
                          valueColor: Color(0xff1976D2),
                          formatWithComma: true,
                        ),
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: _StatCard(
                          topBarColor: Color(0xff7B1FA2),
                          iconBg: Color(0xffF3E5F5),
                          icon: Icons.adjust_rounded,
                          iconColor: Color(0xff7B1FA2),
                          title: "Today's Permits",
                          value: 200,
                          valueColor: Color(0xff7B1FA2),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  /// Issue New Permit Button
                  Container(
                    width: double.infinity,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xff4FA044),
                          Color(0xff2D6B21),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xff2D6B21).withOpacity(0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const SinglePostCheckInScreen(),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 36,
                              width: 36,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Text(
                              "Issue New Permit",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ─────────────────────────────────────────────
/// Section Header (no divider line)
/// ─────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: Color(0xff333333),
      ),
    );
  }
}

/// ─────────────────────────────────────────────
/// Stat Card with Animated Counter
/// ─────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final Color topBarColor;
  final Color iconBg;
  final IconData icon;
  final Color iconColor;
  final String title;
  final int value;
  final Color valueColor;
  final bool formatWithComma;

  const _StatCard({
    required this.topBarColor,
    required this.iconBg,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.valueColor,
    this.formatWithComma = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Colored top bar
          Container(
            height: 5,
            decoration: BoxDecoration(
              color: topBarColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
          ),

          /// Content
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      height: 34,
                      width: 34,
                      decoration: BoxDecoration(
                        color: iconBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: iconColor, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xff666666),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: AnimatedCounter(
                    value: value,
                    color: valueColor,
                    formatWithComma: formatWithComma,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}