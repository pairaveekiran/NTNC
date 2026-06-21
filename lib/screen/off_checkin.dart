import 'package:flutter/material.dart';
import 'package:ntnc/screen/notices.dart';
import 'package:ntnc/screen/qr_scanner.dart';
import 'package:ntnc/widget/bottom_navigation.dart';

class OfflineScanScreen extends StatefulWidget {
  const OfflineScanScreen({super.key});

  @override
  State<OfflineScanScreen> createState() => _OfflineScanScreenState();
}

class _OfflineScanScreenState extends State<OfflineScanScreen> {
  static const primaryGreen = Color(0xff2D6B21);
  static const lightGreen = Color(0xff5BA84A);

  String? scannedCode;
  String? selectedAction; // "checkin" or "checkout"

  /// ─────────────────────────────────────────────
  /// Open Camera Scanner
  /// ─────────────────────────────────────────────
  Future<void> _openScanner() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const QRScannerScreen(),
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        scannedCode = result;
        selectedAction = null; // reset action on new scan
      });

      if (mounted) {
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
  }

  /// ─────────────────────────────────────────────
  /// Handle Check In / Check Out
  /// ─────────────────────────────────────────────
  void _handleAction(String action) {
    setState(() => selectedAction = action);

    final isCheckIn = action == "checkin";
    final label = isCheckIn ? "Checked In" : "Checked Out";
    final color = isCheckIn ? primaryGreen : Colors.redAccent;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        content: Row(
          children: [
            Icon(
              isCheckIn ? Icons.login_rounded : Icons.logout_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              "$label successfully!",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEFF2EF),
      extendBody: true,

      /// ✅ Bottom Navigation
      floatingActionButton: CustomScanFAB(onPressed: _openScanner),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomNavigation(
        isCheckInActive: true,
        onNotificationPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NoticesScreen(),
            ),
          );
        },
        onCheckInPressed: () {},
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
                            "Offline Scan",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Scan permits when offline",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // TODO: Refresh / sync action
                      },
                      icon: const Icon(
                        Icons.sync_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// ✅ CONTENT
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🟠 Offline Banner
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xffFDF2E1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 28,
                          width: 28,
                          decoration: const BoxDecoration(
                            color: Color(0xffF39C12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.priority_high_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "You are currently offline",
                                style: TextStyle(
                                  color: Color(0xffD17C0F),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "Permits will sync when online",
                                style: TextStyle(
                                  color: Color(0xffB87519),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  /// 📷 Scan QR Code Card
                  _buildCard(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: _openScanner,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xffE6F4E8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.qr_code_2_rounded,
                                color: primaryGreen,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Scan QR Code",
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: primaryGreen,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    "Tap to open camera scanner",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xff666666),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// 📝 Scanned Code Field
                  _buildCard(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                scannedCode != null
                                    ? Icons.check_circle_rounded
                                    : Icons.qr_code_rounded,
                                size: 18,
                                color: scannedCode != null
                                    ? primaryGreen
                                    : const Color(0xff9E9E9E),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "Scanned Code",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xff8A8A8A),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              if (scannedCode != null && selectedAction != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selectedAction == "checkin"
                                        ? const Color(0xffE6F4E8)
                                        : const Color(0xffFDE8E8),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        selectedAction == "checkin"
                                            ? Icons.login_rounded
                                            : Icons.logout_rounded,
                                        size: 12,
                                        color: selectedAction == "checkin"
                                            ? primaryGreen
                                            : Colors.redAccent,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        selectedAction == "checkin"
                                            ? "Checked In"
                                            : "Checked Out",
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: selectedAction == "checkin"
                                              ? primaryGreen
                                              : Colors.redAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: scannedCode != null
                                  ? const Color(0xffF6FBF6)
                                  : const Color(0xffFAFAFA),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: scannedCode != null
                                    ? const Color(0xffC8E6C9)
                                    : const Color(0xffE8E8E8),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              scannedCode ?? "No code scanned yet",
                              style: TextStyle(
                                fontSize: 15,
                                fontStyle: scannedCode == null
                                    ? FontStyle.italic
                                    : FontStyle.normal,
                                color: scannedCode == null
                                    ? const Color(0xff9E9E9E)
                                    : const Color(0xff1A1A1A),
                                fontWeight: scannedCode == null
                                    ? FontWeight.normal
                                    : FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  /// ✅ Check In / Check Out Buttons (only when scanned)
                  if (scannedCode != null) ...[
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        /// ✅ CHECK IN
                        Expanded(
                          child: _ActionButton(
                            label: "Check In",
                            icon: Icons.login_rounded,
                            gradient: const [
                              Color(0xff4FA044),
                              primaryGreen,
                            ],
                            isSelected: selectedAction == "checkin",
                            selectedBorderColor: const Color(0xffA5D6A7), // <--- CHANGED: Added custom light green border
                            onTap: () => _handleAction("checkin"),
                          ),
                        ),

                        const SizedBox(width: 12),

                        /// 🔴 CHECK OUT
                        Expanded(
                          child: _ActionButton(
                            label: "Check Out",
                            icon: Icons.logout_rounded,
                            gradient: const [
                              Color(0xffEF5350),
                              Color(0xffC62828),
                            ],
                            isSelected: selectedAction == "checkout",
                            selectedBorderColor: const Color(0xffEF9A9A), // <--- CHANGED: Added custom light red border
                            onTap: () => _handleAction("checkout"),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 22),

                  /// 📜 Your Scanned Permits Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Your Scanned Permits",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xff1A1A1A),
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            scannedCode = null;
                            selectedAction = null;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xffE57373),
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                        ),
                        child: const Text(
                          "Clear Records",
                          style: TextStyle(
                            color: Color(0xffE57373),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// Empty State
                  _buildCard(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        children: [
                          Container(
                            height: 56,
                            width: 56,
                            decoration: BoxDecoration(
                              color: const Color(0xffF0F4F0),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.inbox_rounded,
                              color: Color(0xffBDBDBD),
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "No scanned permits yet",
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Scan a QR code to get started",
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ─────────────────────────────────────────────
  /// Reusable White Card Wrapper
  /// ─────────────────────────────────────────────
  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
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
      child: child,
    );
  }
}

/// ─────────────────────────────────────────────
/// Action Button Widget (Check In / Check Out)
/// ─────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<Color> gradient;
  final bool isSelected;
  final Color selectedBorderColor; // <--- CHANGED: Added parameter for custom border color
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.isSelected,
    required this.selectedBorderColor, // <--- CHANGED: Added parameter for custom border color
    required this.onTap,
  });

  static const primaryGreen = Color(0xff2D6B21);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient.last.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
        border: isSelected
            ? Border.all(color: selectedBorderColor, width: 2.5) // <--- CHANGED: Using the custom border color instead of Colors.white
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 8),
                Container(
                  height: 20,
                  width: 20,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}