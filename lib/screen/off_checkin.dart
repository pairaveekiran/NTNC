import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ntnc/screen/login.dart';
import 'package:ntnc/screen/notices.dart';
import 'package:ntnc/screen/qr_scanner.dart';
import 'package:ntnc/services/bulk_checkin_service.dart';
import 'package:ntnc/services/storage_service.dart';
import 'package:ntnc/widget/bottom_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineScanScreen extends StatefulWidget {
  const OfflineScanScreen({super.key});

  @override
  State<OfflineScanScreen> createState() => _OfflineScanScreenState();
}

/// ─────────────────────────────────────────────
/// Model for a cached scanned permit record
/// ✅ ADDED: toJson / fromJson for persistence
/// ─────────────────────────────────────────────
class ScannedPermitRecord {
  final String code;
  final int direction; // 1 = Check In, 0 = Check Out
  final DateTime timestamp;
  String syncStatus; // "pending", "success", "failed"
  String? errorMessage;

  ScannedPermitRecord({
    required this.code,
    required this.direction,
    required this.timestamp,
    this.syncStatus = "pending",
    this.errorMessage,
  });

  /// Convert to JSON-compatible map
  Map<String, dynamic> toJson() => {
        'code': code,
        'direction': direction,
        'timestamp': timestamp.toIso8601String(),
        'syncStatus': syncStatus,
        'errorMessage': errorMessage,
      };

  /// Construct from JSON map
  factory ScannedPermitRecord.fromJson(Map<String, dynamic> json) {
    return ScannedPermitRecord(
      code: json['code'] as String,
      direction: json['direction'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      syncStatus: json['syncStatus'] as String? ?? "pending",
      errorMessage: json['errorMessage'] as String?,
    );
  }
}

class _OfflineScanScreenState extends State<OfflineScanScreen> {
  static const primaryGreen = Color(0xff2D6B21);
  static const lightGreen = Color(0xff5BA84A);

  /// ✅ ADDED: SharedPreferences key
  static const String _storageKey = 'cached_scanned_permits';

  String? scannedCode;
  String? selectedAction; // "checkin" or "checkout"
  DateTime? _scannedAt; // timestamp captured the moment QR is scanned

  /// ✅ Cached list of scanned permit records
  final List<ScannedPermitRecord> _scannedPermits = [];
  bool _isSyncing = false;

  bool _isSelectionMode = false;
  final Set<int> _selectedIndexes = {};

  @override
  void initState() {
    super.initState();
    _loadScannedPermits(); // ✅ load cached records on screen open
  }

  /// ─────────────────────────────────────────────
  /// ✅ ADDED: Load saved records from SharedPreferences
  /// ─────────────────────────────────────────────
  Future<void> _loadScannedPermits() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_storageKey);

    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final List<dynamic> decoded = json.decode(jsonString);
        final List<ScannedPermitRecord> loaded = decoded
            .map((e) =>
                ScannedPermitRecord.fromJson(e as Map<String, dynamic>))
            .toList();

        setState(() {
          _scannedPermits
            ..clear()
            ..addAll(loaded);
        });
      } catch (e) {
        debugPrint('Error loading scanned permits: $e');
      }
    }
  }

  /// ─────────────────────────────────────────────
  /// ✅ ADDED: Save current records to SharedPreferences
  /// ─────────────────────────────────────────────
  Future<void> _saveScannedPermits() async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString =
        json.encode(_scannedPermits.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

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
      final capturedAt = DateTime.now(); // ✅ captured at scan moment
      setState(() {
        scannedCode = result;
        _scannedAt = capturedAt;
        selectedAction = null;
      });
    }
  }

  /// ─────────────────────────────────────────────
  /// Handle Check In / Check Out
  /// After action, scanned code clears so user can scan again
  /// ✅ Now also persists to SharedPreferences
  /// ─────────────────────────────────────────────
  void _handleAction(int direction) {
    if (scannedCode == null) return;

    final timestamp = _scannedAt ?? DateTime.now(); // fallback just in case

    setState(() {
      _scannedPermits.insert(
        0,
        ScannedPermitRecord(
          code: scannedCode!,
          direction: direction,
          timestamp: timestamp, // ✅ uses scan time, not button tap time
        ),
      );

      scannedCode = null;
      _scannedAt = null; // ✅ reset after use
      selectedAction = null;
    });

    _saveScannedPermits(); // ✅ persist after change
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      _selectedIndexes.clear();
    });
  }

  void _deleteSelectedRecords() {
    if (_selectedIndexes.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xffF39C12),
          content: Text("Select at least one record to delete"),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.delete_outline_rounded,
              color: Color(0xffC62828),
              size: 22,
            ),
            SizedBox(width: 8),
            Text(
              "Remove Selected",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xff1A1A1A),
              ),
            ),
          ],
        ),
        content: Text(
          "Are you sure you want to remove ${_selectedIndexes.length} selected record(s)? This cannot be undone.",
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xff555555),
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xffDDDDDD)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(0, 44),
            ),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Color(0xff555555)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final toRemove = _selectedIndexes.toList()
                ..sort((a, b) => b.compareTo(a));
              for (final i in toRemove) {
                _scannedPermits.removeAt(i);
              }
              _isSelectionMode = false;
              _selectedIndexes.clear();
              setState(() {});
              await _saveScannedPermits();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffC62828),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(0, 44),
            ),
            child: const Text(
              "Remove",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ Sync records with API
  Future<void> _syncRecords() async {
    final pending = _scannedPermits.where((r) => r.syncStatus == "pending").toList();

    if (pending.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xffF39C12),
          content: Text("No pending records to sync"),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // ✅ TASK 1: Debug token before sending
    final token = await StorageService.getToken();
    debugPrint('✅ Token from StorageService: $token');

    if (token == null || token.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xffC62828),
          content: Text("No token found. Please log in again."),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      _isSyncing = true;
    });

    try {
      final service = BulkCheckInService();
      final result = await service.postBulkCheckIns(pending, token);

      final validCodes = List<String>.from(result['valid'] ?? []);
      final invalidList = List<dynamic>.from(result['invalid'] ?? []);

      for (final code in validCodes) {
        final record = _scannedPermits.firstWhere((r) => r.code == code);
        record.syncStatus = "success";
      }

      for (final item in invalidList) {
        final code = item['code'] as String;
        final message = item['message'] as String;
        final record = _scannedPermits.firstWhere((r) => r.code == code);
        record.syncStatus = "failed";
        record.errorMessage = message;
      }

      await _saveScannedPermits();

      setState(() {
        _scannedPermits.removeWhere((r) => r.syncStatus == "success");
      });

      await _saveScannedPermits();

      final failedCount = invalidList.length;
      final syncedCount = validCodes.length;

      if (!mounted) return;
      
      if (failedCount == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: primaryGreen,
            content: Text("All $syncedCount records synced successfully!"),
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xffF39C12),
            content: Text("Synced $syncedCount. $failedCount failed — check the list."),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } on UnauthorizedException {
      // ✅ TASK 3: Show message first before redirect
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xffC62828),
          content: Text("Session expired. Please log in again."),
          duration: Duration(seconds: 3),
        ),
      );

      await StorageService.clearAll();
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    } on SocketException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xffC62828),
          content: Text("Sync failed. Check your connection."),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xffC62828),
          content: Text("Sync failed: ${e.toString()}"),
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
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
                      onPressed: _isSyncing ? null : _syncRecords,
                      icon: _isSyncing
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Icon(
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
                        Expanded(
                          child: _ActionButton(
                            label: "Check In",
                            icon: Icons.login_rounded,
                            gradient: const [
                              Color(0xff4FA044),
                              primaryGreen,
                            ],
                            isSelected: selectedAction == "checkin",
                            selectedBorderColor: const Color(0xffA5D6A7),
                            onTap: () => _handleAction(1),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionButton(
                            label: "Check Out",
                            icon: Icons.logout_rounded,
                            gradient: const [
                              Color(0xffEF5350),
                              Color(0xffC62828),
                            ],
                            isSelected: selectedAction == "checkout",
                            selectedBorderColor: const Color(0xffEF9A9A),
                            onTap: () => _handleAction(0),
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
                      Row(
                        children: [
                          const Text(
                            "Your Scanned Permits",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xff1A1A1A),
                            ),
                          ),
                          if (_scannedPermits.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: primaryGreen,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "${_scannedPermits.length}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      IconButton(
                        onPressed: _scannedPermits.isEmpty
                            ? null
                            : (_isSelectionMode
                                ? _deleteSelectedRecords
                                : _toggleSelectionMode),
                        icon: Icon(
                          _isSelectionMode
                              ? Icons.delete_sweep_rounded
                              : Icons.delete_outline_rounded,
                          color: _scannedPermits.isEmpty
                              ? const Color(0xffCCCCCC)
                              : const Color(0xffC62828),
                          size: 24,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// ✅ Cancel bar when in selection mode
                  if (_isSelectionMode)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${_selectedIndexes.length} selected",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff2D6B21),
                            ),
                          ),
                          TextButton(
                            onPressed: _toggleSelectionMode,
                            child: const Text(
                              "Cancel",
                              style: TextStyle(
                                color: Color(0xff555555),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  /// ✅ Show TABLE OR empty state
                  if (_scannedPermits.isEmpty)
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
                    )
                  else
                    _buildPermitTable(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ─────────────────────────────────────────────
  /// ✅ Build Scanned Permits Table (ID + Direction)
  /// ─────────────────────────────────────────────
  Widget _buildPermitTable() {
    return _buildCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// ✅ Table Header
          IntrinsicHeight(
            child: Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Text(
                      "ID",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xff666666),
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),
                const VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: Color(0xffEEEEEE),
                ),
                const Expanded(
                  flex: 1,
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Text(
                      "DIRECTION",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xff666666),
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xffEEEEEE),
          ),

          /// ✅ Table Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: _scannedPermits.length,
            separatorBuilder: (_, _) => const Divider(
              height: 1,
              thickness: 0.8,
              color: Color(0xffF0F0F0),
            ),
            itemBuilder: (context, index) {
              final record = _scannedPermits[index];
              final isCheckIn = record.direction == 1;
              final isFailed = record.syncStatus == "failed";
              final isSelected = _selectedIndexes.contains(index);

              final actionColor =
                  isCheckIn ? primaryGreen : const Color(0xffC62828);
              final actionBg = isCheckIn
                  ? const Color(0xffE6F4E8)
                  : const Color(0xffFDE8E8);

              return GestureDetector(
                onTap: () {
                  if (_isSelectionMode) {
                    setState(() {
                      if (_selectedIndexes.contains(index)) {
                        _selectedIndexes.remove(index);
                      } else {
                        _selectedIndexes.add(index);
                      }
                    });
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xffE8F5E9)
                        : Colors.transparent,
                    border: isSelected
                        ? const Border(
                            left: BorderSide(
                              color: Color(0xff2D6B21),
                              width: 3,
                            ),
                          )
                        : null,
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        if (_isSelectionMode)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(
                              isSelected
                                  ? Icons.check_circle_rounded
                                  : Icons.circle_outlined,
                              color: isSelected
                                  ? const Color(0xff2D6B21)
                                  : const Color(0xffCCCCCC),
                              size: 20,
                            ),
                          ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  record.code,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xff1A1A1A),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (isFailed && record.errorMessage != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    record.errorMessage!,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xffC62828),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('yyyy-MM-dd HH:mm').format(record.timestamp),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xff999999),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const VerticalDivider(
                          width: 1,
                          thickness: 1,
                          color: Color(0xffF0F0F0),
                        ),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 110,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: actionBg,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          isCheckIn
                                              ? Icons.login_rounded
                                              : Icons.logout_rounded,
                                          size: 13,
                                          color: actionColor,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          isCheckIn ? "Check In" : "Check Out",
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: actionColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isFailed) ...[
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xffFDE8E8),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.error_outline,
                                            size: 11,
                                            color: Color(0xffC62828),
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            "Failed",
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xffC62828),
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
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
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
  final Color selectedBorderColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.isSelected,
    required this.selectedBorderColor,
    required this.onTap,
  });

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
            ? Border.all(color: selectedBorderColor, width: 2.5)
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