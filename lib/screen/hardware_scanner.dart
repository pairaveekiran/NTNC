import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ntnc/screen/sp_checkin.dart';

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
        builder: (_) => SinglePostCheckInScreen(permitId: code),
      ),
    );

    _resetForNextScan();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xffF2F2F2),
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
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                    child: Column(
                      children: [
                        _buildStatusRow(),
                        const SizedBox(height: 20),
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

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xff5BA84A),
            Color(0xff3F8A30),
            Color(0xff2D6B21),
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 16, 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 14),
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
                    SizedBox(height: 2),
                    Text(
                      'Scan permit code with barcode device',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12.5,
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
    );
  }

  Widget _buildStatusRow() {
    final bool ready = _textFocusNode.hasFocus && !_isNavigating;
    final Color dotColor = _isNavigating
        ? const Color(0xFF1976D2)
        : ready
            ? const Color(0xFF22C55E)
            : const Color(0xFFF59E0B);

    final String statusText = _isNavigating
        ? 'Opening permit details\u2026'
        : ready
            ? 'Scanner Ready \u2014 waiting for scan'
            : 'Tap anywhere to reactivate scanner';

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_isNavigating)
          const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF1976D2),
            ),
          )
        else
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
        const SizedBox(width: 8),
        Text(
          statusText,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildScannerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Hidden TextField captures HID/wedge barcode scanner keystrokes.
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
          _buildAnimatedScanPreview(),
          const SizedBox(height: 14),
          if (_displayedCode.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xffE6F4E8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: primaryGreen.withValues(alpha: 0.25),
                ),
              ),
              child: Text(
                _displayedCode,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: primaryGreen,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          Text(
            _isNavigating ? 'Loading permit details\u2026' : 'Waiting for scan\u2026',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedScanPreview() {
    return SizedBox(
      width: 180,
      height: 180,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final travel = constraints.maxHeight - 24;
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xffF2F9F1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: lightGreen.withValues(alpha: 0.3),
                    width: 1.2,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(
                      opacity: 0.05,
                      child: const Icon(
                        Icons.qr_code_2_rounded,
                        size: 150,
                        color: primaryGreen,
                      ),
                    ),
                    const Icon(
                      Icons.qr_code_2_rounded,
                      size: 130,
                      color: Color(0xff2D6B21),
                    ),
                    _buildCorner(top: true, left: true),
                    _buildCorner(top: true, left: false),
                    _buildCorner(top: false, left: true),
                    _buildCorner(top: false, left: false),
                  ],
                ),
              ),
              AnimatedBuilder(
                animation: _scanLineController,
                child: Container(
                  height: 2.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        lightGreen.withValues(alpha: 0.9),
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: lightGreen.withValues(alpha: 0.45),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                builder: (context, child) {
                  return Positioned(
                    left: 12,
                    right: 12,
                    top: 12 + (travel * _scanLineController.value),
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
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          border: Border(
            top: top
                ? const BorderSide(color: primaryGreen, width: 2.5)
                : BorderSide.none,
            bottom: !top
                ? const BorderSide(color: primaryGreen, width: 2.5)
                : BorderSide.none,
            left: left
                ? const BorderSide(color: primaryGreen, width: 2.5)
                : BorderSide.none,
            right: !left
                ? const BorderSide(color: primaryGreen, width: 2.5)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xffE6F4E8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: primaryGreen,
                  size: 20,
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
          const SizedBox(height: 14),
          _buildStep('1', 'Connect your barcode/QR hardware scanner device.'),
          const SizedBox(height: 10),
          _buildStep('2', 'Ensure the status dot above is green (Scanner Ready).'),
          const SizedBox(height: 10),
          _buildStep('3', 'Point the scanner at the permit barcode and trigger a scan.'),
          const SizedBox(height: 10),
          _buildStep('4', 'Permit details will open automatically.'),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: Color(0xffE6F4E8),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: primaryGreen,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xff555555),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

