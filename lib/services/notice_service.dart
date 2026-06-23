import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class NoticeService {
  static const String _baseUrl = 'https://mis.ntnc.org.np/api/notices';

  Future<String?> getNotice() async {
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
      ).timeout(const Duration(seconds: 30));

      debugPrint('Notice API status: ${response.statusCode}');
      debugPrint('Notice API body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['body'] as String?;
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load notice: HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Notice API error: $e');
      throw Exception('Error loading notice: $e');
    }
  }
}
