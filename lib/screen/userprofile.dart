import 'package:flutter/material.dart';
import 'package:ntnc/screen/login.dart';
import 'package:ntnc/services/user_service.dart';
import 'package:ntnc/services/auth_service.dart';
import 'package:ntnc/models/user_profile.dart' as model;

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  model.UserProfile? _profile;
  bool _isLoading = true;
  String? _errorMessage;

  static const primaryGreen = Color(0xff2D6B21);
  static const lightGreen = Color(0xff5BA84A);

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profile = await UserService().getProfile();
      if (!mounted) return;
      
      if (profile == null) {
        await AuthService().logout();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );
        }
        return;
      }
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEEF2F0),
      body: Column(
        children: [
          /// ✅ TOP HEADER with Gradient
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [lightGreen, primaryGreen],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 60),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Text(
                      "Profile",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// ✅ CONTENT (overlapping profile picture)
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: primaryGreen,
                    ),
                  )
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                size: 64,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xff666666),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: _fetchProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryGreen,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SingleChildScrollView(
              child: Transform.translate(
                offset: const Offset(0, -50),
                child: Column(
                  children: [
                    /// PROFILE PICTURE
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border:
                                Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    Colors.black.withValues(alpha: 0.15),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              )
                            ],
                          ),
                          child: const CircleAvatar(
                            backgroundColor: Color(0xffE6F4E8),
                            child: Icon(
                              Icons.person_rounded,
                              size: 64,
                              color: primaryGreen,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: primaryGreen,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.edit_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    /// NAME
                    Text(
                      _profile?.name ?? "User",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff1A1A1A),
                      ),
                    ),

                    const SizedBox(height: 8),

                    /// ROLE BADGE only
                    if (_profile != null && _profile!.roles.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xffE6F4E8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _profile!.roles[0].name,
                          style: const TextStyle(
                            fontSize: 13,
                            color: primaryGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    /// EMAIL CARD
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [lightGreen, primaryGreen],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color:
                                primaryGreen.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color:
                                  Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.mail_outline_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Email Address",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _profile?.email ?? "",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// MENU CARD
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.black.withValues(alpha: 0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          if (_profile != null && _profile!.roles.isNotEmpty)
                            buildMenuItem(
                              icon: Icons.badge_outlined,
                              title: "Role",
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xffE6F4E8),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _profile!.roles[0].name,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: primaryGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              onTap: () {},
                            ),
                          if (_profile != null && _profile!.roles.isNotEmpty)
                            buildDivider(),
                          if (_profile != null)
                            buildMenuItem(
                              icon: Icons.wc_rounded,
                              title: "Gender",
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xffE0F2F1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _profile!.gender == 'M'
                                          ? Icons.male_rounded
                                          : Icons.female_rounded,
                                      size: 16,
                                      color: const Color(0xff00796B),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _profile!.gender == 'M'
                                          ? "Male"
                                          : "Female",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xff00796B),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () {},
                            ),
                          buildDivider(),
                          buildMenuItem(
                            icon: Icons.logout_rounded,
                            title: "Sign Out",
                            isLogout: true,
                            onTap: () => _showLogoutDialog(context),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ Menu Item with optional custom trailing widget
  Widget buildMenuItem({
    required IconData icon,
    required String title,
    bool isLogout = false,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      visualDensity: const VisualDensity(vertical: -1),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        height: 38,
        width: 38,
        decoration: BoxDecoration(
          color: isLogout
              ? Colors.red.withValues(alpha: 0.1)
              : const Color(0xffE6F4E8),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isLogout ? Colors.red : primaryGreen,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: isLogout ? Colors.red : const Color(0xff333333),
        ),
      ),
      trailing: trailing ??
          (isLogout
              ? null
              : const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey,
                )),
      onTap: onTap,
    );
  }

  /// ✅ Divider (thin & inset)
  Widget buildDivider() {
    return const Padding(
      padding: EdgeInsets.only(left: 70, right: 16),
      child:
          Divider(thickness: 0.6, height: 1, color: Color(0xffE0E0E0)),
    );
  }

  /// ✅ Logout Dialog
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
              onPressed: () async {
                await AuthService().logout();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const LoginPage()),
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
}