import 'package:flutter/material.dart';
import 'package:ntnc/screen/userprofile.dart';
import 'package:ntnc/widget/animated_counter.dart';
import 'package:ntnc/widget/dashboard_cart.dart';


class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xff1E5E2F);
    const buttonGreen = Color(0xff6F947C);

    return Scaffold(
      backgroundColor: const Color(0xffE5E5E5),
       /// ✅ CENTER SCAN BUTTON
  floatingActionButton: FloatingActionButton(
    backgroundColor: Colors.white,
    elevation: 6,
    shape: const CircleBorder(
      side: BorderSide(color: Colors.black, width: 2),
    ),
    onPressed: () {},
    child: const Icon(
      Icons.qr_code_scanner,
      color: Colors.black,
      size: 28,
    ),
  ),
  floatingActionButtonLocation:
      FloatingActionButtonLocation.centerDocked,

  /// ✅ BOTTOM NAVIGATION BAR (Like Image)
  bottomNavigationBar: BottomAppBar(
    shape: const CircularNotchedRectangle(),
    notchMargin: 8,
    color: const Color(0xff1E5E2F),
    child: SizedBox(
      height: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [

          /// Left Icon (Check icon like image)
          Icon(
            Icons.check_box_outlined,
            color: Colors.white,
            size: 30,
          ),

          SizedBox(width: 40), // Space for center FAB

          /// Right Icon (Notification bell)
          Icon(
            Icons.notifications_none,
            color: Colors.white,
            size: 30,
          ),
        ],
      ),
    ),
  ),
      body: Column(
        children: [

          /// HEADER
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 40),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: primaryGreen,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Dashboard",
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Welcome, User",
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.white70),
                    ),
                  ],
                ),
                GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UserProfile(),
      ),
    );
  },
  child: const CircleAvatar(
    radius: 28,
    backgroundColor: Colors.white24,
    child: Icon(
      Icons.person,
      size: 30,
      color: Colors.white,
    ),
  ),
),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Check in details:",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),

                  Row(
                    children: const [
                      Expanded(
                        child: DashboardCard(
                          title: "Today’s Total\nCheck IN:",
                          child: AnimatedCounter(value: 219),
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: DashboardCard(
                          title: "Today’s Total\nCheck Out:",
                          child: AnimatedCounter(value: 500),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "Permit Issued details:",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),

                  Row(
                    children: const [
                      Expanded(
                        child: DashboardCard(
                          title: "Total Permit\nIssued:",
                          child: AnimatedCounter(value: 12000),
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: DashboardCard(
                          title: "Today’s Total\nPermit:",
                          child: AnimatedCounter(value: 200),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.add,
                          color: Colors.white),
                      label: const Text(
                        "Issue New Permit",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
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