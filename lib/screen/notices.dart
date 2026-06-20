import 'package:flutter/material.dart';
import 'package:ntnc/screen/off_checkin.dart';
import 'package:ntnc/screen/qr_scanner.dart';
import 'package:ntnc/widget/bottom_navigation.dart';

class NoticesScreen extends StatefulWidget {
  const NoticesScreen({super.key});

  @override
  State<NoticesScreen> createState() => _NoticesScreenState();
}

class _NoticesScreenState extends State<NoticesScreen> {
  static const primaryGreen = Color(0xff2D6B21);
  static const lightGreen = Color(0xff5BA84A);

  // Toggle this to true to preview with sample notices
  final List<_Notice> notices = [];

  String selectedFilter = "All";
  final List<String> filters = ["All", "Unread", "Important"];

  /// ─────────────────────────────────────────────
  /// Open Camera QR Scanner
  /// ─────────────────────────────────────────────
  Future<void> _openScanner() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const QRScannerScreen(),
      ),
    );

    if (result != null && result.isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: primaryGreen,
          content: Text("Scanned: $result"),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// ─────────────────────────────────────────────
  /// Navigate to Offline Check-in Screen
  /// ─────────────────────────────────────────────
  void _openCheckIn() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const OfflineScanScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEFF2EF),
      extendBody: true,

      /// ✅ Center QR Scan Button → opens camera
      floatingActionButton: CustomScanFAB(onPressed: _openScanner),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      /// ✅ Bottom Navigation — Notification tab is ACTIVE (green)
      bottomNavigationBar: CustomBottomNavigation(
        isNotificationActive: true, // ✅ THIS makes Notification GREEN
        onNotificationPressed: () {
          // Already on this screen — do nothing
        },
        onCheckInPressed: _openCheckIn,
      ),

      body: Column(
        children: [
          /// ✅ HEADER with Gradient
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
                padding: const EdgeInsets.fromLTRB(12, 8, 16, 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Notices",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Stay updated with latest announcements",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// Mark all as read icon
                    IconButton(
                      onPressed: notices.isEmpty
                          ? null
                          : () {
                              // TODO: mark all as read
                            },
                      icon: Icon(
                        Icons.done_all_rounded,
                        color:
                            notices.isEmpty ? Colors.white54 : Colors.white,
                        size: 26,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// ✅ Filter Chips
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: filters.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = filters[index];
                  final isSelected = filter == selectedFilter;
                  return GestureDetector(
                    onTap: () => setState(() => selectedFilter = filter),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryGreen : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? primaryGreen
                              : const Color(0xffE0E0E0),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          filter,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xff555555),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          /// ✅ CONTENT
          Expanded(
            child: notices.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: notices.length,
                    itemBuilder: (context, index) {
                      return _buildNoticeCard(notices[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// ─────────────────────────────────────────────
  /// Empty State — "No Notices Yet"
  /// ─────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// Decorative Layered Icon
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 180,
                  width: 180,
                  decoration: BoxDecoration(
                    color: const Color(0xffE6F4E8).withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  height: 140,
                  width: 140,
                  decoration: const BoxDecoration(
                    color: Color(0xffE6F4E8),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [lightGreen, primaryGreen],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryGreen.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.white,
                    size: 52,
                  ),
                ),
                const Positioned(
                  top: 38,
                  right: 38,
                  child: CircleAvatar(
                    radius: 7,
                    backgroundColor: Color(0xffF39C12),
                    child: Icon(
                      Icons.priority_high_rounded,
                      color: Colors.white,
                      size: 10,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            const Text(
              "No Notices Yet",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xff1A1A1A),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "You're all caught up! New announcements\nand important updates will appear here.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xff7A7A7A),
                height: 1.5,
              ),
            ),

            const SizedBox(height: 28),

            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: primaryGreen,
                      content: Text("Checking for new notices..."),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: primaryGreen, width: 1.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                ),
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: primaryGreen,
                  size: 20,
                ),
                label: const Text(
                  "Refresh",
                  style: TextStyle(
                    color: primaryGreen,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ─────────────────────────────────────────────
  /// Notice Card (for when data exists)
  /// ─────────────────────────────────────────────
  Widget _buildNoticeCard(_Notice notice) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: notice.iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(notice.icon, color: notice.iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notice.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xff1A1A1A),
                        ),
                      ),
                    ),
                    if (notice.isUnread)
                      Container(
                        height: 8,
                        width: 8,
                        decoration: const BoxDecoration(
                          color: primaryGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notice.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xff666666),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      color: Color(0xff999999),
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      notice.time,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xff999999),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ─────────────────────────────────────────────
/// Notice Model
/// ─────────────────────────────────────────────
class _Notice {
  final String title;
  final String description;
  final String time;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final bool isUnread;

  _Notice({
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  }) : isUnread = false;
}