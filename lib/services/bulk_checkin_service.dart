import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../screen/off_checkin.dart';

class BulkCheckInService {
  static const String _baseUrl = 'https://mis.ntnc.org.np/api/v1';

  // ✅ TASK 4: Accept token as parameter
  Future<Map<String, dynamic>> postBulkCheckIns(
      List<ScannedPermitRecord> records, String token) async {
    final formatter = DateFormat('yyyy-MM-dd HH:mm');

    final permits = records.map((r) {
      return {
        'code': r.code,
        'logged_at': formatter.format(r.timestamp),
        'direction': r.direction,
      };
    }).toList();

    final body = json.encode({'permits': permits});
    debugPrint('Sync request body: $body');

    // ✅ TASK 2: Ensure proper headers including Accept
    final response = await http.post(
      Uri.parse('$_baseUrl/check-ins'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    // ✅ TASK 2: Print response for debugging
    debugPrint('Sync response status: ${response.statusCode}');
    debugPrint('Sync response body: ${response.body}');

    // ✅ TASK 5: Handle responses with meaningful exceptions
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else if (response.statusCode == 401) {
      throw UnauthorizedException('Token expired');
    } else {
      throw Exception('Sync failed: HTTP ${response.statusCode} — ${response.body}');
    }
  }
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);
}
