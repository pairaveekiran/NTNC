import 'package:flutter/material.dart';
import 'package:ntnc/screen/hardware_scanner.dart';
import 'package:ntnc/screen/off_checkin.dart';
import 'package:ntnc/screen/qr_scanner.dart';
import 'package:ntnc/screen/sp_checkin_first.dart';
import 'package:ntnc/widget/animated_counter.dart';
import 'package:ntnc/widget/app_drawer.dart';
import 'package:ntnc/widget/bottom_navigation.dart';
import 'package:ntnc/models/today_check_in_response.dart';
import 'package:ntnc/services/dashboard_service.dart';
import 'package:ntnc/services/storage_service.dart';
import 'package:ntnc/models/user_profile.dart';
import 'package:ntnc/services/user_service.dart';

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  bool _isLoading = true;
  String? _error;
  TodayCheckInResponse? _checkInData;
  UserProfile? _profile;
  String? _scannerType;

  @override
  void initState() {
    super.initState();
    _checkScannerPreference();
    _fetchData();
  }

  Future<void> _checkScannerPreference() async {
    final type = await StorageService.getScannerType();
    if (!mounted) return;
    
    if (type == null) {
      // Force selection on first launch
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showScannerOptionsDialog(
          context,
          dismissible: false,
          onSelected: (selectedType) async {
            await StorageService.saveScannerType(selectedType);
            if (mounted) {
              setState(() {
                _scannerType = selectedType;
              });
            }
          },
        );
      });
    } else {
      setState(() {
        _scannerType = type;
      });
    }
  }

  Future<void> _fetchData({bool forceRefresh = false}) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      if (!forceRefresh) _error = null;
    });

    try {
      final data = await DashboardService().fetchTodayCheckIns(forceRefresh: forceRefresh);
      UserProfile? profile = _profile;
      if (profile == null || forceRefresh) {
        profile = await UserService().getProfile();
      }
      
      if (mounted) {
        setState(() {
          _checkInData = data;
          _profile = profile;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
        if (forceRefresh) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_error ?? 'An error occurred'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleRefresh() async {
    await _fetchData(forceRefresh: true);
  }

  Future<void> _startMobileScan() async {
    bool keepScanning = true;
    while (keepScanning) {
      if (!mounted) break;

      try {
        final scannedCode = await Navigator.push<String>(
          context,
          MaterialPageRoute(
            builder: (context) => const QRScannerScreen(),
          ),
        );

        if (!mounted) break;

        if (scannedCode != null && scannedCode.isNotEmpty) {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  SinglePostCheckInFirstScreen(permitId: scannedCode),
            ),
          );
          if (result != true) keepScanning = false;
        } else {
          keepScanning = false;
        }
      } catch (e) {
        keepScanning = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF2F2F2),
      extendBody: true,

      /// ✅ DRAWER (Menu)
      drawer: AppDrawer(
        onScannerPreferenceChanged: (newType) {
          setState(() {
            _scannerType = newType;
          });
        },
      ),

      /// ✅ CENTER SCAN BUTTON
      floatingActionButton: CustomScanFAB(
        scannerType: _scannerType,
        // Camera QR path
        onPressed: _startMobileScan,
        // Hardware scanner path
        onHardwareScannerPressed: () {
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const HardwareScannerScreen(),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      /// ✅ BOTTOM NAVIGATION BAR
      bottomNavigationBar: CustomBottomNavigation(
        scannerType: _scannerType,
        onScannerPressed: _startMobileScan,
        onHardwareScannerPressed: () {
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const HardwareScannerScreen(),
            ),
          );
        },
        onCheckInPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const OfflineScanScreen(),
            ),
          );
        },
      ),

      body: Column(
        children: [
          /// HEADER with Light → Dark Green Gradient
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xff5BA84A), // light green (top)
                  Color(0xff3F8A30), // medium green
                  Color(0xff2D6B21), // dark green (bottom)
                ],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Top App Bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 16, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        /// ✅ MENU ICON — opens drawer
                        Builder(
                          builder: (context) => IconButton(
                            icon: const Icon(
                              Icons.menu_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: () =>
                                Scaffold.of(context).openDrawer(),
                          ),
                        ),
                        Container(
                          height: 44,
                          width: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: const EdgeInsets.all(2),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.asset(
                              "assets/images/ntnc.png",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                         Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "NATIONAL TRUST FOR NATURE CONSERVATION",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              SizedBox(height: 1),

    /// Divider line
    Container(
      height: 1,
      width: 275,
      color: Colors.white.withValues(alpha: 0.8),
    ),

    SizedBox(height: 1),
                              
                              Text(
                                "राष्ट्रिय प्रकृति संरक्षण कोष",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// Dashboard Title + Welcome + Profile
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Dashboard",
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Welcome, ${_profile?.name ?? 'User'}",
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        // GestureDetector(
                        //   onTap: () {
                        //     Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //         builder: (context) => const UserProfile(),
                        //       ),
                        //     );
                        //   },
                        //   child: Container(
                        //     padding: const EdgeInsets.all(2),
                        //     decoration: BoxDecoration(
                        //       shape: BoxShape.circle,
                        //       border: Border.all(
                        //         color: Colors.white.withOpacity(0.4),
                        //         width: 2,
                        //       ),
                        //     ),
                        //     child: const CircleAvatar(
                        //       radius: 24,
                        //       backgroundColor: Colors.white24,
                        //       child: Icon(
                        //         Icons.person_rounded,
                        //         size: 28,
                        //         color: Colors.white,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// CONTENT
          Expanded(
            child: RefreshIndicator(
              color: const Color(0xff5BA84A),
              onRefresh: _handleRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Section: Check-in Details
                    const _SectionHeader(title: "Check-in Details"),
                    const SizedBox(height: 14),
                    if (_isLoading && _checkInData == null)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(
                            color: Color(0xff5BA84A),
                          ),
                        ),
                      )
                    else if (_error != null && _checkInData == null)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 48),
                              const SizedBox(height: 16),
                              Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.red),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => _fetchData(forceRefresh: true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff5BA84A),
                                ),
                                child: const Text('Retry', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              topBarColor: const Color(0xff2E7D32),
                              iconBg: const Color(0xffE6F4E8),
                              icon: Icons.check_rounded,
                              iconColor: const Color(0xff2E7D32),
                              title: "Today's Check IN",
                              value: _checkInData?.checkIns ?? 0,
                              valueColor: const Color(0xff2D6B21),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _StatCard(
                              topBarColor: const Color(0xffF57C00),
                              iconBg: const Color(0xffFFF2E5),
                              icon: Icons.show_chart_rounded,
                              iconColor: const Color(0xffF57C00),
                              title: "Today's Check OUT",
                              value: _checkInData?.checkOuts ?? 0,
                              valueColor: const Color(0xffF57C00),
                            ),
                          ),
                        ],
                      ),
  
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ─────────────────────────────────────────────
/// Section Header (no divider line)
/// ─────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: Color(0xff333333),
      ),
    );
  }
}

/// ─────────────────────────────────────────────
/// Stat Card with Animated Counter
/// ─────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final Color topBarColor;
  final Color iconBg;
  final IconData icon;
  final Color iconColor;
  final String title;
  final int value;
  final Color valueColor;

  const _StatCard({
    required this.topBarColor,
    required this.iconBg,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Colored top bar
          Container(
            height: 5,
            decoration: BoxDecoration(
              color: topBarColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
          ),

          /// Content
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      height: 34,
                      width: 34,
                      decoration: BoxDecoration(
                        color: iconBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: iconColor, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xff666666),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: AnimatedCounter(
                    value: value,
                    color: valueColor,
                    formatWithComma: false,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}