import 'package:flutter/material.dart';
import 'package:ntnc/screen/login.dart';

class UserProfile extends StatelessWidget {
  const UserProfile({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xff1E5E2F);
    const backgroundColor = Color(0xffEEF2F0);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [

            /// ✅ TOP HEADER
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 25),
              decoration: const BoxDecoration(
                color: primaryGreen,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back,
                        color: Colors.white),
                  ),
                  const SizedBox(width: 15),
                  const Text(
                    "Profile",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// ✅ PROFILE SECTION
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 70,
                    color: Colors.grey,
                  ),
                ),

                Positioned(
                  bottom: 5,
                  right: 5,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryGreen,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                        )
                      ],
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// ✅ NAME
            const Text(
              "John Doe",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              "Wildlife Officer",
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 20),

            /// ✅ EMAIL CARD
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: primaryGreen,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        "john.doe@email.com",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// ✅ MENU SECTION
            Expanded(
              child: Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(
                    vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: Column(
                  children: [

                    buildMenuItem(
                      icon: Icons.edit_outlined,
                      title: "Edit Profile",
                      onTap: () {},
                    ),

                    buildDivider(),

                    buildMenuItem(
                      icon: Icons.person_outline,
                      title: "Role",
                      onTap: () {},
                    ),

                    buildDivider(),

                    buildMenuItem(
                      icon: Icons.settings_outlined,
                      title: "Settings",
                      onTap: () {},
                    ),

                    buildDivider(),

                    buildMenuItem(
                      icon: Icons.logout,
                      title: "Sign Out",
                      isLogout: true,
                      onTap: () {
                        _showLogoutDialog(context);
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// ✅ Menu Item
  Widget buildMenuItem({
    required IconData icon,
    required String title,
    bool isLogout = false,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isLogout ? Colors.red : Colors.grey[700],
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isLogout ? Colors.red : Colors.black87,
        ),
      ),
      trailing: isLogout
          ? null
          : const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Divider(thickness: 0.8),
    );
  }

  /// ✅ Logout Dialog
  void _showLogoutDialog(BuildContext context) {
    
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white, 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text("Confirm Logout"),
        content: const Text(
            "Are you sure you want to sign out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}