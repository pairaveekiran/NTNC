import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────
/// Bottom Navigation Bar with Notch
/// ─────────────────────────────────────────────
class CustomBottomNavigation extends StatelessWidget {
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onCheckInPressed;

  const CustomBottomNavigation({
    super.key,
    this.onNotificationPressed,
    this.onCheckInPressed,
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
            icon: Icons.notifications_rounded,
            label: "Notification",
            onTap: onNotificationPressed,
          ),
          const SizedBox(width: 60), // Space for FAB
          _BottomNavItem(
            icon: Icons.wifi_off_rounded,
            label: "Check-in",
            onTap: onCheckInPressed, // ✅ just use the passed callback
          ),
        ],
      ),
    );
  }
}

/// ─────────────────────────────────────────────
/// Floating Center Scan Button (FAB)
/// ─────────────────────────────────────────────
class CustomScanFAB extends StatelessWidget {
  final VoidCallback? onPressed;

  const CustomScanFAB({super.key, this.onPressed});

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
        onPressed: onPressed ?? () {},
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

  const _BottomNavItem({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black87, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}