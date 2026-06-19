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
  String selectedDirection = "Check In";

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

                  /// 📷 Scan QR Code Card → opens camera
                  _buildCard(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: _openScanner, // ✅ open camera
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
                          const Text(
                            "Scanned Code",
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xff8A8A8A),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.only(bottom: 6),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Color(0xffE0E0E0),
                                  width: 1,
                                ),
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
                                    : Colors.black87,
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

                  const SizedBox(height: 12),

                  /// ⬇️ Direction Dropdown
                  _buildCard(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Direction",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xff8A8A8A),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  "Select direction",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xff1A1A1A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xffE6F4E8),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedDirection,
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: primaryGreen,
                                ),
                                style: const TextStyle(
                                  color: primaryGreen,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                                dropdownColor: Colors.white,
                                items: const [
                                  DropdownMenuItem(
                                    value: "Check In",
                                    child: Text("Check In"),
                                  ),
                                  DropdownMenuItem(
                                    value: "Check Out",
                                    child: Text("Check Out", style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => selectedDirection = val);
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// 🕐 Logged At
                  _buildCard(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Logged At",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xff8A8A8A),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  "Current time will be recorded",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xff1A1A1A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 36,
                            width: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xffE0E0E0),
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.access_time_rounded,
                              color: Color(0xff9E9E9E),
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  /// ➕ Add to Permit List Button
                  Container(
                    width: double.infinity,
                    height: 58,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xff4FA044), primaryGreen],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: primaryGreen.withOpacity(0.35),
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
                          if (scannedCode == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.redAccent,
                                content: Text("Please scan a QR code first"),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return;
                          }
                          // TODO: Add to permit list
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: primaryGreen,
                              content: Text("Added to permit list!"),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 32,
                              width: 32,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "Add to Permit List",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

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
                          setState(() => scannedCode = null);
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
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        "No scanned permits yet",
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                        ),
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
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}