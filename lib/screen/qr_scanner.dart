import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with WidgetsBindingObserver {

  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  // ── Hidden text field for hardware scanner fallback ──────────────────
  final TextEditingController _hwController = TextEditingController();
  final FocusNode _hwFocusNode = FocusNode();
  // ─────────────────────────────────────────────────────────────────────

  bool _isScanned = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Keep the hidden field focused so HID keyboard input is captured.
    WidgetsBinding.instance.addPostFrameCallback((_) => _refocusHw());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _hwController.dispose();
    _hwFocusNode.dispose();
    try { _controller.dispose(); } catch (_) {}
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      try { _controller.stop(); } catch (_) {}
    } else if (state == AppLifecycleState.resumed) {
      try { _controller.start(); } catch (_) {}
      _refocusHw();
    }
  }

  void _refocusHw() {
    if (!mounted) return;
    _hwFocusNode.requestFocus();
    // Hide the software keyboard — we only want hardware scanner input.
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  // ── Called when camera detects a QR/barcode ──────────────────────────
  void _onDetect(BarcodeCapture capture) {
    if (_isScanned || !mounted) return;
    final barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final code = barcodes.first.rawValue;
      if (code != null && code.isNotEmpty) {
        _returnCode(code);
      }
    }
  }

  // ── Called when hardware scanner sends Enter (submit) ─────────────────
  void _onHwSubmitted(String raw) {
    final code = raw.trim();
    if (code.isEmpty || _isScanned) return;
    _hwController.clear();
    _returnCode(code);
  }

  // ── Common exit: return code to caller ───────────────────────────────
  void _returnCode(String code) {
    if (_isScanned || !mounted) return;
    setState(() => _isScanned = true);
    Navigator.pop(context, code);
  }

  void _goBack() {
    if (mounted) Navigator.pop(context);
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
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        // ── Camera view ──────────────────────────────────────────────────
        MobileScanner(
          controller: _controller,
          onDetect: _onDetect,
          errorBuilder: (context, error) {
            final isPermission = error.errorCode == MobileScannerErrorCode.permissionDenied;
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
                      isPermission ? 'Camera Permission Required' : 'Camera Error',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xff1A1A1A)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isPermission
                          ? 'Please allow camera access in your device settings.'
                          : error.errorDetails?.message ?? 'Could not start camera.',
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
          },
        ),

        // ── Hidden field: silently captures HID/hardware scanner input ───
        Offstage(
          offstage: true,
          child: TextField(
            controller: _hwController,
            focusNode: _hwFocusNode,
            autofocus: false,
            keyboardType: TextInputType.none,
            textInputAction: TextInputAction.go,
            enableSuggestions: false,
            autocorrect: false,
            showCursor: false,
            onSubmitted: _onHwSubmitted,
          ),
        ),

        // ── Scan frame overlay ───────────────────────────────────────────
        Center(
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xff5BA84A), width: 3),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),

        // ── Instructions ─────────────────────────────────────────────────
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
              'Align QR code within the frame to scan\nor use hardware scanner',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}