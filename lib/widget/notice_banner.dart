import 'package:flutter/material.dart';
import 'package:ntnc/services/notice_service.dart';

class NoticeBanner extends StatefulWidget {
  const NoticeBanner({super.key});

  @override
  State<NoticeBanner> createState() => _NoticeBannerState();
}

class _NoticeBannerState extends State<NoticeBanner> {
  bool _isLoading = true;
  String? _noticeBody;
  bool _isDismissed = false;

  @override
  void initState() {
    super.initState();
    _fetchNotice();
  }

  Future<void> _fetchNotice() async {
    try {
      final result = await NoticeService().getNotice();
      
      if (!mounted) return;
      
      setState(() {
        _noticeBody = result;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _noticeBody = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hide while loading
    if (_isLoading) {
      return const SizedBox.shrink();
    }

    // Hide if no notice (404 or null)
    if (_noticeBody == null) {
      return const SizedBox.shrink();
    }

    // Hide if dismissed
    if (_isDismissed) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xffFFF8E7),
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(
            color: Color(0xffF39C12),
            width: 4,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.campaign_rounded,
            color: Color(0xffF39C12),
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Official Notice",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff5A4000),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _noticeBody!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xff5A4000),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                _isDismissed = true;
              });
            },
            child: const Icon(
              Icons.close_rounded,
              color: Color(0xff999999),
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}
