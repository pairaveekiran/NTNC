import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────
/// Bottom Navigation Bar with Notch
/// ─────────────────────────────────────────────
class CustomBottomNavigation extends StatelessWidget {
  final VoidCallback? onScannerPressed;
  final VoidCallback? onHardwareScannerPressed;
  final VoidCallback? onCheckInPressed;
  final bool isScannerActive;
  final bool isCheckInActive;
  final String? scannerType;

  const CustomBottomNavigation({
    super.key,
    this.onScannerPressed,
    this.onHardwareScannerPressed,
    this.onCheckInPressed,
    this.isScannerActive = false,
    this.isCheckInActive = false,
    this.scannerType,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: Colors.white,
      elevation: 12,
      padding: EdgeInsets.zero,
      height: 64,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BottomNavItem(
            icon: scannerType == 'hardware' ? Icons.qr_code_scanner_rounded : Icons.document_scanner_rounded,
            label: scannerType == 'hardware' ? "Bar Code Scanner" : "Mobile Scanner",
            onTap: scannerType == 'hardware' ? onHardwareScannerPressed : onScannerPressed,
            isActive: isScannerActive,
          ),
          const SizedBox(width: 60), // Space for FAB
          _BottomNavItem(
            icon: Icons.wifi_off_rounded,
            label: "Check-in",
            onTap: onCheckInPressed,
            isActive: isCheckInActive,
          ),
        ],
      ),
    );
  }
}

/// ─────────────────────────────────────────────
/// Extracted Dialog Logic for Scanner Selection
/// ─────────────────────────────────────────────
Future<void> showScannerOptionsDialog(
  BuildContext context, {
  required Function(String) onSelected,
  bool dismissible = false,
  String? currentType,
}) {
  return showDialog(
    context: context,
    barrierDismissible: dismissible,
    builder: (BuildContext context) {
      return PopScope(
        canPop: dismissible,
        child: Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Select Scanner Method',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: Color(0xff1A1A1A),
                        ),
                      ),
                    ),
                    if (dismissible)
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 20,
                            color: Color(0xff555555),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Choose the method you want to use for scanning the permit.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xff7A7A7A),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                _ScannerOptionCard(
                  icon: Icons.smartphone_rounded,
                  title: 'Mobile / Tablet Scanner',
                  subtitle: 'Use your device camera to scan QR codes',
                  isSelected: currentType == 'mobile',
                  onTap: () {
                    onSelected('mobile');
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 14),
                _ScannerOptionCard(
                  icon: Icons.document_scanner_rounded,
                  title: 'Bar Code Scanner',
                  subtitle: 'Use an external connected scanner device',
                  isSelected: currentType == 'hardware',
                  onTap: () {
                    onSelected('hardware');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// ─────────────────────────────────────────────
/// Floating Center Scan Button (FAB)
/// ─────────────────────────────────────────────
class CustomScanFAB extends StatelessWidget {
  final VoidCallback? onPressed;
  final VoidCallback? onHardwareScannerPressed;
  final String? scannerType;

  const CustomScanFAB({
    super.key,
    this.onPressed,
    this.onHardwareScannerPressed,
    this.scannerType,
  });

  void _handlePress(BuildContext context) {
    if (scannerType == 'hardware') {
      if (onHardwareScannerPressed != null) onHardwareScannerPressed!();
    } else if (scannerType == 'mobile') {
      if (onPressed != null) onPressed!();
    } else {
      showScannerOptionsDialog(
        context,
        dismissible: true,
        currentType: scannerType,
        onSelected: (type) {
          if (type == 'hardware' && onHardwareScannerPressed != null) onHardwareScannerPressed!();
          if (type == 'mobile' && onPressed != null) onPressed!();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 66,
      width: 66,
      child: FloatingActionButton(
        backgroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(
          side: BorderSide(color: Color(0xff2D6B21), width: 2),
        ),
        onPressed: () => _handlePress(context),
        child: const Icon(
          Icons.qr_code_scanner_rounded,
          color: Color(0xff2D6B21),
          size: 30,
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────
/// Internal Bottom Nav Item with Icon + Label
/// ─────────────────────────────────────────────
class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isActive;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    // 🎨 Active = green, Inactive = grey
    final Color color =
        isActive ? const Color(0xff2D6B21) : Colors.grey.shade600;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────
/// Helper widget for the scanner option cards
/// ─────────────────────────────────────────────
class _ScannerOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isSelected;

  const _ScannerOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xffF0F9F0) : const Color(0xffF9FAF9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? const Color(0xff2D6B21) : const Color(0xffE6F4E8), 
          width: isSelected ? 2.0 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xffE6F4E8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: const Color(0xff2D6B21), size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xff1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xff7A7A7A),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                  size: 24,
                  color: isSelected ? const Color(0xff2D6B21) : const Color(0xffBDBDBD),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}