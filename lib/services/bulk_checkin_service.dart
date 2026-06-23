import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import '../screen/off_checkin.dart';

class BulkCheckInService {
  static const String _baseUrl = 'https://mis.ntnc.org.np/api/v1';
  static final _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> postBulkCheckIns(
      List<ScannedPermitRecord> records) async {
    final token = await _storage.read(key: 'access_token');

    final permits = records.map((r) {
      final formattedDate =
          DateFormat('yyyy-MM-dd HH:mm').format(r.timestamp);
      return {
        'code': r.code,
        'logged_at': formattedDate,
        'direction': r.direction,
      };
    }).toList();

    final response = await http.post(
      Uri.parse('$_baseUrl/check-ins'),
      headers: {
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'permits': permits}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    } else {
      throw Exception('Failed to sync: ${response.statusCode}');
    }
  }
}

class UnauthorizedException implements Exception {}
