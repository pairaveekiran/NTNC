import 'package:flutter/material.dart';
import 'package:ntnc/screen/login.dart';
import 'package:ntnc/screen/userprofile.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  static const primaryGreen = Color(0xff2D6B21);
  static const lightGreen = Color(0xff5BA84A);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xffF5F7F5),
      width: MediaQuery.of(context).size.width * 0.82,
      child: Column(
        children: [
          /// ✅ PROFILE HEADER
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [lightGreen, primaryGreen],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Close button
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    /// ✅ Avatar + Name + Email — entire row tappable
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // close drawer first
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const UserProfile(),
                          ),
                        );
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.5),
                                width: 2,
                              ),
                            ),
                            child: const CircleAvatar(
                              radius: 32,
                              backgroundColor: Colors.white24,
                              child: Icon(
                                Icons.person_rounded,
                                size: 36,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "John Doe",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "john.doe@email.com",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 6),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.white70,
                            size: 22,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// Role Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_user_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                          SizedBox(width: 6),
                          Text(
                            "Wildlife Officer",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// ✅ MENU GRID
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 22, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 6, bottom: 12),
                    child: Text(
                      "Menu",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff666666),
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),

                  /// Grid View
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _menuItems.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.05,
                    ),
                    itemBuilder: (context, index) {
                      final item = _menuItems[index];
                      return _MenuTile(
                        icon: item.icon,
                        label: item.label,
                        color: item.color,
                        bgColor: item.bgColor,
                        onTap: () {
                          Navigator.pop(context); // close drawer first
                          _handleMenuTap(context, item.label);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          /// ✅ LOGOUT BUTTON
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => _showLogoutDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red,
                  elevation: 0,
                  side: BorderSide(
                    color: Colors.red.withOpacity(0.3),
                    width: 1.2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.logout_rounded, size: 20),
                label: const Text(
                  "Logout",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ─────────────────────────────────────────────
  /// Handle Menu Item Taps
  /// ─────────────────────────────────────────────
  void _handleMenuTap(BuildContext context, String label) {
    switch (label) {
      case "Profile":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const UserProfile(),
          ),
        );
        break;

      case "Email Address":
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: primaryGreen,
            content: Text("john.doe@email.com"),
            duration: Duration(seconds: 2),
          ),
        );
        break;

      case "Role":
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: primaryGreen,
            content: Text("Wildlife Officer"),
            duration: Duration(seconds: 2),
          ),
        );
        break;

      case "Settings":
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: primaryGreen,
            content: Text("Settings coming soon..."),
            duration: Duration(seconds: 2),
          ),
        );
        break;
    }
  }

  /// ─────────────────────────────────────────────
  /// Logout Dialog
  /// ─────────────────────────────────────────────
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Column(
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Colors.red,
                size: 30,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              "Confirm Logout",
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: const Text(
          "Are you sure you want to sign out of your account?",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Color(0xff666666)),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          SizedBox(
            width: 110,
            height: 44,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xffCCCCCC)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Color(0xff666666)),
              ),
            ),
          ),
          SizedBox(
            width: 110,
            height: 44,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
              child: const Text(
                "Logout",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ─────────────────────────────────────────────
/// Menu Tile Widget
/// ─────────────────────────────────────────────
class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff333333),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────
/// Menu Item Data
/// ─────────────────────────────────────────────
class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
  });
}

const List<_MenuItem> _menuItems = [
  _MenuItem(
    icon: Icons.person_rounded,
    label: "Profile",
    color: Color(0xff2D6B21),
    bgColor: Color(0xffE6F4E8),
  ),
  _MenuItem(
    icon: Icons.mail_outline_rounded,
    label: "Email Address",
    color: Color(0xff1976D2),
    bgColor: Color(0xffE3F0FB),
  ),
  _MenuItem(
    icon: Icons.badge_outlined,
    label: "Role",
    color: Color(0xffF57C00),
    bgColor: Color(0xffFFF2E5),
  ),
  _MenuItem(
    icon: Icons.settings_outlined,
    label: "Settings",
    color: Color(0xff7B1FA2),
    bgColor: Color(0xffF3E5F5),
  ),
];