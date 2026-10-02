import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ntnc/screen/login.dart';
import 'package:ntnc/screen/userprofile.dart' as screen;
import 'package:ntnc/services/auth_service.dart';
import 'package:ntnc/services/user_service.dart';
import 'package:ntnc/services/storage_service.dart';
import 'package:ntnc/widget/bottom_navigation.dart';
import 'package:ntnc/models/user_profile.dart';

class AppDrawer extends StatefulWidget {
  final Function(String)? onScannerPreferenceChanged;

  const AppDrawer({
    super.key,
    this.onScannerPreferenceChanged,
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  UserProfile? _profile;
  bool _isLoading = true;

  static const primaryGreen = Color(0xff2D6B21);
  static const lightGreen = Color(0xff5BA84A);

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final profile = await UserService().getProfile();
      if (profile == null && mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
        return;
      }
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        title: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.close_rounded,
                  color: Color(0xff999999),
                  size: 24,
                ),
              ),
            ),
            Center(
              child: Column(
                children: [
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
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
            ),
          ],
        ),
        content: const Text(
          "Are you sure you want to sign out of your account?",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Color(0xff666666),
          ),
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
              onPressed: () async {
                // Clear stored data
                await AuthService().logout();
                
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                }
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

  @override
  Widget build(BuildContext context) {
    // Limit drawer width on wide screens
    final screenWidth = MediaQuery.of(context).size.width;
    final drawerWidth = screenWidth > 400 ? 360.0 : screenWidth * 0.85;

    return Drawer(
      backgroundColor: const Color(0xffF5F7F5),
      width: drawerWidth,
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
              child: Stack(
                children: [
                  /// Close button
                  Positioned(
                    top: 16,
                    right: 16,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
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

                  /// Centered Profile Info
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const screen.UserProfile(),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  width: 2,
                                ),
                              ),
                              child: const CircleAvatar(
                                radius: 36,
                                backgroundColor: Colors.white24,
                                child: Icon(
                                  Icons.person_rounded,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (_isLoading)
                            const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          else ...[
                            Text(
                              _profile?.name ?? "User",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _profile?.email ?? "",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            if (_profile != null && _profile!.roles.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.22),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.4),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.verified_user_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _profile!.roles[0].name.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// ✅ MAIN CONTENT LIST
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: primaryGreen))
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                    children: [
                      /// --- Account Information Section ---
                      const Padding(
                        padding: EdgeInsets.only(left: 6, bottom: 8),
                        child: Text(
                          "ACCOUNT INFORMATION",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xff888888),
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      
                      /// The unified card for read-only info
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xffE6ECE6)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: _buildReadOnlyItems(),
                        ),
                      ),

                      const SizedBox(height: 28),

                      /// --- Preferences Section ---
                      const Padding(
                        padding: EdgeInsets.only(left: 6, bottom: 8),
                        child: Text(
                          "PREFERENCES",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xff888888),
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      
                      /// Interactive Tile for Scanner
                      Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () async {
                            Navigator.pop(context); // Close drawer first
                            final currentType = await StorageService.getScannerType();
                            if (!context.mounted) return;
                            showScannerOptionsDialog(
                              context,
                              dismissible: true,
                              currentType: currentType,
                              onSelected: (selectedType) async {
                                await StorageService.saveScannerType(selectedType);
                                if (widget.onScannerPreferenceChanged != null) {
                                  widget.onScannerPreferenceChanged!(selectedType);
                                }
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: primaryGreen,
                                      content: Text(
                                        selectedType == 'hardware'
                                            ? "Hardware Scanner selected"
                                            : "Mobile Scanner selected",
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                          child: Ink(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xffE6ECE6)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              child: Row(
                                children: [
                                  Container(
                                    height: 42,
                                    width: 42,
                                    decoration: BoxDecoration(
                                      color: const Color(0xffF3E5F5),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.qr_code_scanner_rounded, color: Color(0xff8E24AA), size: 20),
                                  ),
                                  const SizedBox(width: 14),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Scanner Preference",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xff222222),
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          "Change default scanner method",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xff7A7A7A),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    "Change",
                                    style: TextStyle(
                                      color: primaryGreen,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      /// App Version Footer
                      const Center(
                        child: Text(
                          "NTNC App • v1.0.2",
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xffAAAAAA),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),

          /// ✅ LOGOUT BUTTON
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            decoration: const BoxDecoration(
              color: Color(0xffF5F7F5), // blend with background
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () => _showLogoutDialog(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade600,
                  side: BorderSide(
                    color: Colors.red.shade300,
                    width: 1.2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.logout_rounded, size: 20),
                label: const Text(
                  "Log Out",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper to build the info rows with dividers
  List<Widget> _buildReadOnlyItems() {
    if (_profile == null) return [];

    final genderLabel = _profile!.gender == 'M' ? 'Male' : 'Female';
    final roleSubtitle = _profile!.roles.isNotEmpty
        ? "${_profile!.roles[0].name} access level"
        : "No role assigned";

    final items = [
      _InfoRowData(
        icon: Icons.mail_outline_rounded,
        label: "EMAIL ADDRESS",
        value: _profile!.email,
        color: const Color(0xff1976D2),
        bgColor: const Color(0xffE3F0FB),
      ),
      _InfoRowData(
        icon: Icons.wc_rounded,
        label: "GENDER",
        value: genderLabel,
        color: const Color(0xffE91E63),
        bgColor: const Color(0xffFCE4EC),
      ),
      _InfoRowData(
        icon: Icons.badge_outlined,
        label: "ROLE",
        value: roleSubtitle,
        color: const Color(0xffF57C00),
        bgColor: const Color(0xffFFF2E5),
      ),
      if (_profile!.organization != null && _profile!.organization!.isNotEmpty)
        _InfoRowData(
          icon: Icons.business_rounded,
          label: "ORGANIZATION",
          value: _profile!.organization!,
          color: const Color(0xff00897B),
          bgColor: const Color(0xffE0F2F1),
        ),
    ];

    List<Widget> widgets = [];
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  color: item.bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, color: item.color, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff999999),
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.value,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff333333),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
      
      // Add divider if not the last item
      if (i < items.length - 1) {
        widgets.add(
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xffF0F0F0),
            indent: 64, // Align with text
            endIndent: 16,
          ),
        );
      }
    }
    return widgets;
  }
}

class _InfoRowData {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color bgColor;

  _InfoRowData({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.bgColor,
  });
}
