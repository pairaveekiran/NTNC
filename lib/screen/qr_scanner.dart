import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with WidgetsBindingObserver {
  late final MobileScannerController _controller;
  bool _isScanned = false;
  bool _isStopping = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Create controller — MobileScanner widget handles starting it automatically
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _safeDispose();
    super.dispose();
  }

  void _safeDispose() {
    if (_isStopping) return;
    _isStopping = true;
    try {
      _controller.stop().catchError((_) {}).whenComplete(() {
        try { _controller.dispose(); } catch (_) {}
      });
    } catch (_) {
      try { _controller.dispose(); } catch (_) {}
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isStopping) return;
    if (state == AppLifecycleState.paused) {
      try { _controller.stop(); } catch (_) {}
    } else if (state == AppLifecycleState.resumed) {
      try { _controller.start(); } catch (_) {}
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isScanned || !mounted || _isStopping) return;
    final barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final code = barcodes.first.rawValue;
      if (code != null && code.isNotEmpty) {
        setState(() => _isScanned = true);
        Navigator.pop(context, code);
      }
    }
  }

  void _goBack() {
    if (!mounted) return;
    Navigator.pop(context);
  }

  void _showPermissionDialog() {
    if (!mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.camera_alt_outlined, color: Color(0xffF57C00), size: 24),
            SizedBox(width: 10),
            Expanded(child: Text('Camera Permission Required')),
          ],
        ),
        content: const Text(
          'This app needs camera access to scan QR codes. Please allow camera permission in your device settings.',
          style: TextStyle(fontSize: 13, color: Color(0xff555555), height: 1.4),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              _goBack();             // back to dashboard
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff2D6B21),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _goBack();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: const Color(0xff2D6B21),
          foregroundColor: Colors.white,
          title: const Text('Scan QR Code'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: _goBack,
          ),
          actions: [
            IconButton(
              onPressed: () {
                try { _controller.toggleTorch(); } catch (_) {}
              },
              icon: const Icon(Icons.flash_on_rounded),
            ),
            IconButton(
              onPressed: () {
                try { _controller.switchCamera(); } catch (_) {}
              },
              icon: const Icon(Icons.cameraswitch_rounded),
            ),
          ],
        ),
        body: Stack(
          children: [
            MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
              errorBuilder: (context, error) {
                // Determine if it's a permission issue or a hardware issue
                final isPermission =
                    error.errorCode == MobileScannerErrorCode.permissionDenied;

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (isPermission) {
                    _showPermissionDialog();
                  } else {
                    _showNoCameraDialog(
                      error.errorDetails?.message ??
                          'Camera could not be accessed.',
                    );
                  }
                });

                return _buildErrorBody(
                  icon: isPermission
                      ? Icons.camera_alt_outlined
                      : Icons.no_photography_rounded,
                  iconColor: isPermission
                      ? const Color(0xffF57C00)
                      : const Color(0xffC62828),
                  title: isPermission
                      ? 'Camera Permission Required'
                      : 'No Camera Found',
                  message: isPermission
                      ? 'Please allow camera access in your device settings.'
                      : error.errorDetails?.message ??
                          'Camera could not be accessed on this device.',
                );
              },
            ),

            // Scan frame overlay
            Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border:
                      Border.all(color: const Color(0xff5BA84A), width: 3),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            // Instructions at the bottom
            Positioned(
              bottom: 60,
              left: 30,
              right: 30,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Align QR code within the frame to scan',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNoCameraDialog(String message) {
    if (!mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.no_photography_rounded,
                color: Color(0xffC62828), size: 24),
            SizedBox(width: 10),
            Text('No Camera Found'),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
              fontSize: 13, color: Color(0xff555555), height: 1.4),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _goBack();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff2D6B21),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBody({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
  }) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.symmetric(horizontal: 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 54, color: iconColor),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xff1A1A1A)),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xff555555), height: 1.4),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _goBack,
                icon: const Icon(Icons.arrow_back_rounded, size: 20),
                label: const Text('Go Back',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff2D6B21),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}