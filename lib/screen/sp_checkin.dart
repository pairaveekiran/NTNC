import 'package:flutter/material.dart';
import 'package:ntnc/services/permit_service.dart';
import 'package:ntnc/models/permit_model.dart';
import 'package:intl/intl.dart';
import 'package:ntnc/services/storage_service.dart';
import 'package:ntnc/screen/login.dart';

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
  
  final PermitService _permitService = PermitService();
  Permit? _permit;
  bool _isLoading = true;
  bool _isCheckingInLoading = false;   // spinner for Check In button only
  bool _isCheckingOutLoading = false;  // spinner for Check Out button only
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPermit();
  }

  Future<void> _loadPermit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _permitService.getPermit(widget.permitId ?? '');
    
    if (result['success']) {
      setState(() {
        _permit = result['permit'];
        _isLoading = false;
      });
    } else {
      if (result['statusCode'] == 401) {
        await StorageService.clearAll();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        }
      } else if (result['statusCode'] == 404) {
        setState(() {
          _errorMessage = 'Permit not found';
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Failed to load permit';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleCheckIn(int direction) async {
    // Set only the relevant button's loading flag
    if (direction == 1) {
      setState(() => _isCheckingInLoading = true);
    } else {
      setState(() => _isCheckingOutLoading = true);
    }

    try {
      final result = await _permitService.postCheckIn(
        widget.permitId ?? '',
        direction,
      );

      if (!mounted) return;

      if (result['success']) {
        _showSuccessSnack(
          direction == 1 ? 'Checked-in successfully!' : 'Checked-out successfully!',
        );
        _loadPermit();
      } else {
        final statusCode = result['statusCode'];
        // Always extract as plain string — never show raw map object
        final String errorText = result['message']?.toString() ?? 'Something went wrong';

        if (statusCode == 401) {
          await StorageService.clearAll();
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
            );
          }
        } else if (statusCode == 404) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Row(
                children: [
                  Icon(Icons.error_outline_rounded, color: Color(0xffC62828), size: 22),
                  SizedBox(width: 8),
                  Text('Permit Not Found'),
                ],
              ),
              content: const Text('This permit code does not exist in the system.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK', style: TextStyle(color: Color(0xff2D6B21))),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xffC62828),
              content: Text(errorText),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        if (direction == 1) {
          setState(() => _isCheckingInLoading = false);
        } else {
          setState(() => _isCheckingOutLoading = false);
        }
      }
    }
  }

  String _calculateAge(String dob) {
    try {
      final birthDate = DateTime.parse(dob);
      final today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      return '$age yrs';
    } catch (e) {
      return '';
    }
  }

  String _formatDate(String date) {
    try {
      final dt = DateTime.parse(date);
      return DateFormat('dd-MMM-yyyy').format(dt);
    } catch (e) {
      return date;
    }
  }

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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: primaryGreen))
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _errorMessage!,
                              style: const TextStyle(fontSize: 16, color: Colors.red),
                            ),
                            if (_errorMessage != 'Permit not found') ...[
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadPermit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryGreen,
                                ),
                                child: const Text('Retry', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ],
                        ),
                      )
                    : SingleChildScrollView(
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
                              _permit?.code ?? widget.permitId ?? '',
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
                                    child: Text(
                                      _permit?.country.nationality ?? '',
                                      style: const TextStyle(
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
                                    Text(
                                      "${_permit?.firstName ?? ''} ${_permit?.midName ?? ''} ${_permit?.lastName ?? ''}".trim(),
                                      style: const TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xff1A1A1A),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${_permit != null ? _calculateAge(_permit!.dob) : ''} • ${_permit?.gender == 'M' ? 'Male' : _permit?.gender == 'F' ? 'Female' : ''} • ${_permit?.country.nationality ?? ''}",
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
                                    _infoRow("Passport No", _permit?.passport ?? ''),
                                    const SizedBox(height: 6),
                                    _infoRow("Receipt No", _permit?.receipt ?? ''),
                                    const SizedBox(height: 6),
                                    _infoRow("Permit Code", _permit?.code ?? ''),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          /// Trekking Region
                          if (_permit?.treks.isNotEmpty ?? false)
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
                                Expanded(
                                  child: Text(
                                    _permit?.treks[0].trek.name ?? '',
                                    style: const TextStyle(
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
                                    onPressed: (_isCheckingInLoading || _isCheckingOutLoading) ? null : () => _handleCheckIn(1),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryGreen,
                                      disabledBackgroundColor: primaryGreen.withValues(alpha: 0.6),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: _isCheckingInLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Row(
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
                                    onPressed: (_isCheckingInLoading || _isCheckingOutLoading) ? null : () => _handleCheckIn(0),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: _isCheckingOutLoading ? Colors.red.withValues(alpha: 0.4) : Colors.red,
                                        width: 1.5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      backgroundColor: Colors.white,
                                    ),
                                    child: _isCheckingOutLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.red,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Row(
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
                                    Text(
                                      _permit?.getEntryPost.address ?? '',
                                      style: const TextStyle(
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
                                    Text(
                                      _permit?.getExitPost.address ?? '',
                                      style: const TextStyle(
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
                          _detailRow(
                            "Validity of Permit",
                            _permit != null
                                ? "${_formatDate(_permit!.validFrom)} to ${_formatDate(_permit!.validTo)}"
                                : '',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  /// 🏢 Issuing Authority
                  _buildCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
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
                          Text(
                            _permit?.getIssuingOffice.name ?? '',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xff333333),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Tel: ${_permit?.getIssuingOffice.phone ?? '---'}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
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
                          const Row(
                            children: [
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

                          ...(_permit?.checkIns ?? []).asMap().entries.map((entry) {
                            final index = entry.key;
                            final checkIn = entry.value;
                            return _checkPostRow(
                              time: checkIn.loggedAt,
                              post: checkIn.checkPost.name,
                              isIn: checkIn.direction == 1,
                              highlighted: index == 0,
                            );
                          }),
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