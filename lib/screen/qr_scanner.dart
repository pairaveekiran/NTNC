import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with WidgetsBindingObserver {
  // autoStart: false — we manually start BEFORE showing the MobileScanner widget
  // This prevents native-level crashes on devices with no camera (hardware scanners)
  final MobileScannerController _controller = MobileScannerController(
    autoStart: false,
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  bool _isChecking = true;   // true = still testing if camera exists
  bool _cameraOk = false;    // true = camera started successfully
  bool _isScanned = false;
  bool _errorDialogShown = false;
  String _errorTitle = 'No Camera Found';
  String _errorMessage =
      'No camera was found on this device. Please use a mobile phone to scan QR codes.';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Probe the camera after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) => _probeCamera());
  }

  /// Try to start the camera. If it throws, camera is unavailable.
  /// MobileScanner widget is only rendered AFTER this succeeds.
  Future<void> _probeCamera() async {
    try {
      await _controller.start();
      if (mounted) {
        setState(() {
          _isChecking = false;
          _cameraOk = true;
        });
      }
    } catch (e) {
      // Camera unavailable (no hardware, permission denied, etc.)
      final isPermission = e.toString().toLowerCase().contains('permission');
      if (mounted) {
        setState(() {
          _isChecking = false;
          _cameraOk = false;
          if (isPermission) {
            _errorTitle = 'Camera Permission Required';
            _errorMessage =
                'Please allow camera access in your device settings, then try again.';
          } else {
            _errorTitle = 'No Camera Found';
            _errorMessage =
                'No camera was found on this device. Please use a mobile phone to scan QR codes.';
          }
        });
        _showErrorDialog();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Simple synchronous dispose — no async, no awaiting.
    // MobileScannerController.dispose() handles stopping internally.
    try { _controller.dispose(); } catch (_) {}
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_cameraOk) return;
    if (state == AppLifecycleState.paused) {
      try { _controller.stop(); } catch (_) {}
    } else if (state == AppLifecycleState.resumed) {
      try { _controller.start(); } catch (_) {}
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isScanned || !mounted) return;
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
    if (mounted) Navigator.pop(context);
  }

  void _showErrorDialog() {
    if (!mounted || _errorDialogShown) return;
    _errorDialogShown = true;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              _errorTitle == 'Camera Permission Required'
                  ? Icons.camera_alt_outlined
                  : Icons.no_photography_rounded,
              color: _errorTitle == 'Camera Permission Required'
                  ? const Color(0xffF57C00)
                  : const Color(0xffC62828),
              size: 24,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(_errorTitle)),
          ],
        ),
        content: Text(
          _errorMessage,
          style: const TextStyle(
              fontSize: 13, color: Color(0xff555555), height: 1.4),
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
            if (_cameraOk) ...[
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
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    // Still probing camera — show loading
    if (_isChecking) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xff5BA84A)),
            SizedBox(height: 16),
            Text(
              'Checking camera...',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      );
    }

    // Camera probe failed — show error (dialog already shown above)
    if (!_cameraOk) {
      return _buildErrorBody();
    }

    // Camera is running — safe to render MobileScanner
    // autoStart: false so widget won't try to start again
    return Stack(
      children: [
        MobileScanner(
          controller: _controller,
          onDetect: _onDetect,
          errorBuilder: (context, error) {
            // Camera died mid-session
            final isPermission =
                error.errorCode == MobileScannerErrorCode.permissionDenied;
            if (!_errorDialogShown) {
              _errorTitle = isPermission
                  ? 'Camera Permission Required'
                  : 'No Camera Found';
              _errorMessage = isPermission
                  ? 'Please allow camera access in your device settings.'
                  : error.errorDetails?.message ??
                      'Camera error. Please try again.';
              WidgetsBinding.instance
                  .addPostFrameCallback((_) => _showErrorDialog());
            }
            return _buildErrorBody();
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

        // Instructions
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
    );
  }

  Widget _buildErrorBody() {
    final isPermission = _errorTitle == 'Camera Permission Required';
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
            Icon(
              isPermission
                  ? Icons.camera_alt_outlined
                  : Icons.no_photography_rounded,
              size: 54,
              color: isPermission
                  ? const Color(0xffF57C00)
                  : const Color(0xffC62828),
            ),
            const SizedBox(height: 16),
            Text(
              _errorTitle,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xff1A1A1A)),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
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