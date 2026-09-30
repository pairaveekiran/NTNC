import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ntnc/screen/sp_checkin_first.dart';

class HardwareScannerScreen extends StatefulWidget {
  const HardwareScannerScreen({super.key});

  @override
  State<HardwareScannerScreen> createState() => _HardwareScannerScreenState();
}

class _HardwareScannerScreenState extends State<HardwareScannerScreen>
    with SingleTickerProviderStateMixin {
  static const Color primaryGreen = Color(0xff2D6B21);
  static const Color lightGreen = Color(0xff5BA84A);

  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();

  late final AnimationController _scanLineController;
  late final Animation<double> _pulseAnimation;

  String _displayedCode = '';
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();

    _textController.addListener(() {
      if (!mounted) return;
      setState(() => _displayedCode = _textController.text);
    });

    _textFocusNode.addListener(() {
      if (!mounted) return;
      setState(() {});
    });

    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _scanLineController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _refocusScannerInput());
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    _textController.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  void _refocusScannerInput() {
    if (!mounted) return;
    _textFocusNode.requestFocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  void _resetForNextScan() {
    if (!mounted) return;
    setState(() {
      _isNavigating = false;
      _displayedCode = '';
    });
    _textController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _refocusScannerInput();
    });
  }

  Future<void> _onTextSubmitted(String raw) async {
    final code = raw.trim();
    if (code.isEmpty || _isNavigating) return;
    setState(() => _isNavigating = true);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SinglePostCheckInFirstScreen(permitId: code),
      ),
    );

    _resetForNextScan();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xffF0F4F0),
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _refocusScannerInput,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
                    child: Column(
                      children: [
                        _buildStatusChip(),
                        const SizedBox(height: 28),
                        _buildScannerCard(),
                        const SizedBox(height: 20),
                        _buildInstructionCard(),
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
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HEADER
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff5BA84A), Color(0xff2D6B21)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 20, 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Back button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Title & subtitle
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hardware Scanner',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Scan permit barcode with your device',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              // Scanner icon badge
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: const Icon(
                  Icons.qr_code_scanner_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // STATUS CHIP
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildStatusChip() {
    final bool ready = _textFocusNode.hasFocus && !_isNavigating;

    final Color chipBg = _isNavigating
        ? const Color(0xffEBF3FB)
        : ready
            ? const Color(0xffE8F5E9)
            : const Color(0xffFFF8E1);

    final Color dotColor = _isNavigating
        ? const Color(0xFF1976D2)
        : ready
            ? const Color(0xFF43A047)
            : const Color(0xFFFB8C00);

    final String statusText = _isNavigating
        ? 'Opening permit details…'
        : ready
            ? 'Ready — Waiting for scan'
            : 'Tap anywhere to activate';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: chipBg,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: dotColor.withValues(alpha: 0.3),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isNavigating)
            SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: dotColor,
              ),
            )
          else
            // Pulsing dot when ready
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (_, child) => Transform.scale(
                scale: ready ? _pulseAnimation.value : 1.0,
                child: child,
              ),
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: dotColor.withValues(alpha: 0.4),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(width: 10),
          Text(
            statusText,
            style: TextStyle(
              color: dotColor,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SCANNER CARD (main visual)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildScannerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Hidden TextField — captures HID barcode scanner keystrokes
          Offstage(
            offstage: true,
            child: TextField(
              controller: _textController,
              focusNode: _textFocusNode,
              autofocus: false,
              keyboardType: TextInputType.none,
              textInputAction: TextInputAction.go,
              enableSuggestions: false,
              autocorrect: false,
              showCursor: false,
              onSubmitted: _onTextSubmitted,
            ),
          ),

          // Animated scan preview area
          _buildAnimatedScanPreview(),

          const SizedBox(height: 20),

          // "Align barcode within the frame" label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xffF0F9F0),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: lightGreen.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.center_focus_weak_rounded,
                  size: 16,
                  color: primaryGreen.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Align barcode within the frame to scan',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Scanned code preview
          if (_displayedCode.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xffE8F5E9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: primaryGreen.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    color: primaryGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _displayedCode,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: primaryGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),

          // Bottom processing indicator
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _isNavigating
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: primaryGreen,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Loading permit details…',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                : Text(
                    'Waiting for scan…',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ANIMATED SCAN PREVIEW
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildAnimatedScanPreview() {
    return SizedBox(
      width: 200,
      height: 200,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final travel = constraints.maxHeight - 28;
          return Stack(
            alignment: Alignment.center,
            children: [
              // Background box with rounded corners
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xffF4FAF4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: lightGreen.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Faint background QR icon
                    Opacity(
                      opacity: 0.04,
                      child: const Icon(
                        Icons.qr_code_2_rounded,
                        size: 170,
                        color: primaryGreen,
                      ),
                    ),
                    // Solid QR icon
                    Icon(
                      Icons.qr_code_2_rounded,
                      size: 130,
                      color: primaryGreen.withValues(alpha: 0.85),
                    ),
                    // Corner brackets
                    _buildCorner(top: true, left: true),
                    _buildCorner(top: true, left: false),
                    _buildCorner(top: false, left: true),
                    _buildCorner(top: false, left: false),
                  ],
                ),
              ),

              // Animated scan line
              AnimatedBuilder(
                animation: _scanLineController,
                child: Container(
                  height: 2.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        lightGreen.withValues(alpha: 0.95),
                        Colors.transparent,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: lightGreen.withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                builder: (context, child) {
                  return Positioned(
                    left: 14,
                    right: 14,
                    top: 14 + (travel * _scanLineController.value),
                    child: child!,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCorner({required bool top, required bool left}) {
    return Positioned(
      top: top ? 10 : null,
      bottom: top ? null : 10,
      left: left ? 10 : null,
      right: left ? null : 10,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          border: Border(
            top: top
                ? const BorderSide(color: primaryGreen, width: 3)
                : BorderSide.none,
            bottom: !top
                ? const BorderSide(color: primaryGreen, width: 3)
                : BorderSide.none,
            left: left
                ? const BorderSide(color: primaryGreen, width: 3)
                : BorderSide.none,
            right: !left
                ? const BorderSide(color: primaryGreen, width: 3)
                : BorderSide.none,
          ),
          borderRadius: BorderRadius.only(
            topLeft: (top && left) ? const Radius.circular(4) : Radius.zero,
            topRight: (top && !left) ? const Radius.circular(4) : Radius.zero,
            bottomLeft: (!top && left) ? const Radius.circular(4) : Radius.zero,
            bottomRight: (!top && !left) ? const Radius.circular(4) : Radius.zero,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HOW TO USE CARD
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildInstructionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: const Color(0xffE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.tips_and_updates_rounded,
                  color: primaryGreen,
                  size: 19,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'How to use',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xff1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildStep('1', 'Connect your barcode/QR hardware scanner device.'),
          _buildStep('2', 'Ensure the status indicator above shows green (Ready).'),
          _buildStep('3', 'Point the scanner at the permit barcode and trigger a scan.'),
          _buildStep('4', 'Permit details will open automatically.'),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [lightGreen, primaryGreen],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Color(0xff4A4A4A),
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
