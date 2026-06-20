import 'package:flutter/material.dart';

class SinglePostCheckInScreen extends StatefulWidget {
  final String? permitId;

  const SinglePostCheckInScreen({super.key, this.permitId});

  @override
  State<SinglePostCheckInScreen> createState() =>
      _SinglePostCheckInScreenState();
}

class _SinglePostCheckInScreenState extends State<SinglePostCheckInScreen> {
  static const primaryGreen = Color(0xff2D6B21);
  static const lightGreen = Color(0xff5BA84A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEFF2EF),
      
      // ❌ No bottomNavigationBar
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
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 16, 18),
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
                            "Single Post Check-in",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Verify and check-in permit holder",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
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

          /// ✅ CONTENT
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🟩 Permit ID Card
                  _buildCard(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Permit ID",
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xff8A8A8A),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.only(bottom: 6),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Color(0xffD9D9D9),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Text(
                              widget.permitId ?? "ONNqEshLD10",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xff1A1A1A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  /// 👤 Permit Holder Info Card
                  _buildCard(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// Profile Avatar + Nationality Badge
                              Column(
                                children: [
                                  Container(
                                    height: 100,
                                    width: 90,
                                    decoration: BoxDecoration(
                                      color: const Color(0xffF2F2F2),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Icon(
                                      Icons.person_rounded,
                                      size: 60,
                                      color: Color(0xffBDBDBD),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xffE6F4E8),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      "Indian",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: primaryGreen,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(width: 14),

                              /// Right side info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Sonu Kumar",
                                      style: TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xff1A1A1A),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "27 yrs • Male • Indian",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    const Divider(
                                      thickness: 0.8,
                                      color: Color(0xffE0E0E0),
                                    ),
                                    const SizedBox(height: 8),
                                    _infoRow("Passport No", "244053439754"),
                                    const SizedBox(height: 6),
                                    _infoRow("Receipt No", "ONL/ACAP-325775"),
                                    const SizedBox(height: 6),
                                    _infoRow("Permit Code", "ONNqEshLD10"),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          /// Trekking Region
                          Row(
                            children: [
                              const Text(
                                "Trekking Region",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xff8A8A8A),
                                ),
                              ),
                              const SizedBox(width: 14),
                              const Expanded(
                                child: Text(
                                  "Jomsom Muktinath Trek",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xff1A1A1A),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          /// Check-in / Check-out Buttons
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _showSuccessSnack(
                                          "Checked-in successfully");
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryGreen,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Check-in",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        SizedBox(width: 6),
                                        Icon(
                                          Icons.check_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: SizedBox(
                                  height: 50,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      _showSuccessSnack(
                                          "Checked-out successfully");
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: Colors.red,
                                        width: 1.5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      backgroundColor: Colors.white,
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Check-out",
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        SizedBox(width: 6),
                                        Icon(
                                          Icons.arrow_outward_rounded,
                                          color: Colors.red,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  /// 📋 Permit Details
                  _buildCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Permit Details",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: primaryGreen,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Divider(
                            thickness: 0.8,
                            color: Color(0xffE0E0E0),
                          ),
                          const SizedBox(height: 12),

                          /// Entry/Exit
                          Row(
                            children: [
                              const SizedBox(
                                width: 130,
                                child: Text(
                                  "Entry/Exit Points",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xff8A8A8A),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    const _Dot(color: Color(0xff2E7D32)),
                                    const SizedBox(width: 6),
                                    const Text(
                                      "Beni",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: Color(0xff1A1A1A),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "/",
                                      style: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const _Dot(color: Color(0xffE53935)),
                                    const SizedBox(width: 6),
                                    const Text(
                                      "Beni",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: Color(0xff1A1A1A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),
                          _detailRow("Validity of Permit",
                              "09-Jun-2026 to 24-Jun-2026"),
                          const SizedBox(height: 12),
                          _detailRow("Destination", "Muktinath"),
                          const SizedBox(height: 12),
                          _detailRow(
                              "Trek Route", "Beni - Jomsom - Muktinath"),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  /// 🏢 Issuing Authority + Travel Agency
                  _buildCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Permit Issuing Authority",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: primaryGreen,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    "Online, Online",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xff333333),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Tel: ---",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 1,
                              color: const Color(0xffE0E0E0),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 14),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Travel Agency",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: primaryGreen,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    "Nebira Journeys, Pokhara",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xff333333),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Tel: 9851064185",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
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

                  const SizedBox(height: 14),

                  /// 🚪 Check Post Entries
                  _buildCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Check Post Entries",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: primaryGreen,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Divider(
                            thickness: 0.8,
                            color: Color(0xffE0E0E0),
                          ),
                          const SizedBox(height: 8),

                          /// Table Header
                          Row(
                            children: const [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  "TIME",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xff8A8A8A),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  "CHECK POST",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xff8A8A8A),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  "DIRECTION",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xff8A8A8A),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          _checkPostRow(
                            time: "2026-06-09 17:13",
                            post: "Jomsom",
                            isIn: true,
                            highlighted: true,
                          ),
                          _checkPostRow(
                            time: "2026-06-17 16:35",
                            post: "EPC, Pokhara",
                            isIn: false,
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
  /// Reusable Card Wrapper
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

  /// Info row inside permit holder card
  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xff8A8A8A),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xff1A1A1A),
            ),
          ),
        ),
      ],
    );
  }

  /// Detail row inside Permit Details card
  Widget _detailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xff8A8A8A),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xff1A1A1A),
            ),
          ),
        ),
      ],
    );
  }

  /// Check Post table row
  Widget _checkPostRow({
    required String time,
    required String post,
    required bool isIn,
    bool highlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: highlighted ? const Color(0xffF5F7F5) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              time,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xff333333),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              post,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xff333333),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                _Dot(
                  color: isIn
                      ? const Color(0xff2E7D32)
                      : const Color(0xffE53935),
                ),
                const SizedBox(width: 6),
                Text(
                  isIn ? "IN" : "OUT",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isIn
                        ? const Color(0xff2E7D32)
                        : const Color(0xffE53935),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: primaryGreen,
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// ─────────────────────────────────────────────
/// Small Colored Dot Widget
/// ─────────────────────────────────────────────
class _Dot extends StatelessWidget {
  final Color color;

  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      width: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}