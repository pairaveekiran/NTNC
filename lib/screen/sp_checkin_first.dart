import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:ntnc/services/permit_service.dart';
import 'package:ntnc/models/permit_model.dart';
import 'package:ntnc/services/storage_service.dart';
import 'package:ntnc/screen/login.dart';
import 'package:ntnc/screen/sp_checkin.dart';

/// V2 Check-in screen — uses the lighter /permits/V2 endpoint.
/// Displays: name + permit-code chip on same line, avatar icon,
/// receipt no, gender/age row. Check-in / Check-out unchanged.
class SinglePostCheckInFirstScreen extends StatefulWidget {
  final String? permitId;

  const SinglePostCheckInFirstScreen({super.key, this.permitId});

  @override
  State<SinglePostCheckInFirstScreen> createState() =>
      _SinglePostCheckInFirstScreenState();
}

class _SinglePostCheckInFirstScreenState
    extends State<SinglePostCheckInFirstScreen> {
  static const primaryGreen = Color(0xff2D6B21);
  static const lightGreen = Color(0xff5BA84A);

  final PermitService _permitService = PermitService();
  final FlutterTts _flutterTts = FlutterTts();

  PermitV2? _permit;
  bool _isLoading = true;
  bool _isCheckingInLoading = false;
  bool _isCheckingOutLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initTts();
    _loadPermit();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.6);
    await _flutterTts.awaitSpeakCompletion(true);
  }

  Future<void> _speak(String text) async {
    await _flutterTts.stop();
    await _flutterTts.speak(text);
  }

  // ─── LOAD PERMIT (V2) ─────────────────────────
  Future<void> _loadPermit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _permitService.getPermitV2(widget.permitId ?? '');

    if (result['success']) {
      setState(() {
        _permit = result['permit'] as PermitV2;
        _isLoading = false;
      });
    } else {
      if (result['statusCode'] == 401) {
        await StorageService.clearAll();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
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

  // ─── CHECK-IN / CHECK-OUT ────────────────────
  Future<void> _handleCheckIn(int direction) async {
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
        final successText = direction == 1
            ? 'Checked-in successfully!'
            : 'Checked-out successfully!';
        _showSuccessSnack(successText);
        await _speak(successText);
        
        if (mounted) Navigator.pop(context, true);
      } else {
        final statusCode = result['statusCode'];
        final String errorText =
            result['message']?.toString() ?? 'Something went wrong';

        if (statusCode == 401) {
          await StorageService.clearAll();
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
            );
          }
        } else if (statusCode == 404) {
          _speak('Permit Not Found');
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.error_outline_rounded,
                      color: Color(0xffC62828), size: 22),
                  SizedBox(width: 8),
                  Text('Permit Not Found'),
                ],
              ),
              content: const Text(
                  'This permit code does not exist in the system.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK',
                      style: TextStyle(color: Color(0xff2D6B21))),
                ),
              ],
            ),
          );
        } else {
          _speak(errorText);
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

  // ─── HELPERS ─────────────────────────────────
  String _calculateAge(String dob) {
    try {
      final parts = dob.split('-');
      if (parts.length != 3) return '';
      final year = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final day = int.tryParse(parts[2]);
      if (year == null || month == null || day == null || year == 0) return '';
      final birthDate = DateTime(year, month, day);
      final today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      return '$age yrs';
    } catch (_) {
      return '';
    }
  }

  String _genderLabel(String g) {
    if (g == 'M') return 'Male';
    if (g == 'F') return 'Female';
    return g;
  }

  // ─── BUILD ────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEFF2EF),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: primaryGreen))
                : _errorMessage != null
                    ? _buildError()
                    : SingleChildScrollView(
                        padding:
                            const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHolderCard(),
                            const SizedBox(height: 14),
                            _buildActionButtons(),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  // ─── HEADER ───────────────────────────────────
  Widget _buildHeader() {
    return Container(
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
                      'Single Post Check-in',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Verify and check-in permit holder',
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
    );
  }

  // ─── ERROR STATE ──────────────────────────────
  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.red),
            ),
            if (_errorMessage != 'Permit not found') ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadPermit,
                style:
                    ElevatedButton.styleFrom(backgroundColor: primaryGreen),
                child: const Text('Retry',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── PERMIT HOLDER CARD ───────────────────────
  Widget _buildHolderCard() {
    final p = _permit!;

    final fullName = [p.firstName, p.midName, p.lastName]
        .where((s) => s.isNotEmpty)
        .join(' ');

    final ageStr = _calculateAge(p.dob);
    final genderStr = _genderLabel(p.gender);

    final subtitleParts = <String>[
      if (ageStr.isNotEmpty) ageStr,
      if (genderStr.isNotEmpty) genderStr,
    ];
    final subtitle = subtitleParts.join(' \u2022 ');

    return _buildCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Avatar  +  Name & code block ──────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar icon
                Container(
                  height: 80,
                  width: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xffF2F2F2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: p.photo.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            'https://epermit.ntnc.org.np/upload/application/${p.photo}',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.person_rounded,
                                size: 50,
                                color: Color(0xffBDBDBD),
                              );
                            },
                          ),
                        )
                      : const Icon(
                          Icons.person_rounded,
                          size: 50,
                          color: Color(0xffBDBDBD),
                        ),
                ),

                const SizedBox(width: 14),

                // Right column: name row + subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ─ Name  |  Permit Code chip — same line ─
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SinglePostCheckInScreen(
                                      permitId: p.code,
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(4),
                              child: Text.rich(
                                TextSpan(
                                  text: fullName,
                                  children: [
                                    if (p.passport.isNotEmpty)
                                      TextSpan(
                                        text: ' (${p.passport})',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: primaryGreen,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                  ],
                                ),
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: primaryGreen,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Country Name (made bigger)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xffE6F4E8),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: primaryGreen.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Text(
                              p.countryName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: primaryGreen,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            const Divider(thickness: 0.8, color: Color(0xffE0E0E0)),
            const SizedBox(height: 10),

            // ── Detail rows ──────────────────────────
            _infoRow('Receipt No', p.receipt),
            const SizedBox(height: 8),
            _infoRow('Permit Code', p.code),
            if (p.projectName.isNotEmpty) ...[
              const SizedBox(height: 8),
              _infoRow('Project', p.projectName),
            ],
            if (p.treks.isNotEmpty) ...[
              const SizedBox(height: 8),
              _infoRow('Trek', p.treks.first.trek.name),
            ],
          ],
        ),
      ),
    );
  }

  // ─── ACTION BUTTONS ───────────────────────────
  Widget _buildActionButtons() {
    return Row(
      children: [
        // Check In
        Expanded(
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: (_isCheckingInLoading || _isCheckingOutLoading)
                  ? null
                  : () => _handleCheckIn(1),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                disabledBackgroundColor:
                    primaryGreen.withValues(alpha: 0.6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _isCheckingInLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Check-in',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.check_rounded,
                            color: Colors.white, size: 18),
                      ],
                    ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Check Out
        Expanded(
          child: SizedBox(
            height: 50,
            child: OutlinedButton(
              onPressed: (_isCheckingInLoading || _isCheckingOutLoading)
                  ? null
                  : () => _handleCheckIn(0),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: _isCheckingOutLoading
                      ? Colors.red.withValues(alpha: 0.4)
                      : Colors.red,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                backgroundColor: Colors.white,
              ),
              child: _isCheckingOutLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.red, strokeWidth: 2))
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Check-out',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_outward_rounded,
                            color: Colors.red, size: 18),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── WIDGET HELPERS ───────────────────────────
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

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 96,
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
