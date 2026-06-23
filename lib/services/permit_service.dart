import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ntnc/services/storage_service.dart';
import 'package:ntnc/models/permit_model.dart';

class PermitService {
  static const String baseUrl = 'https://mis.ntnc.org.np/api/v1';
  static const String corsProxy = 'https://corsproxy.io/?';

  String _getApiUrl(String endpoint) {
    if (kIsWeb) {
      return '$corsProxy$baseUrl$endpoint';
    }
    return '$baseUrl$endpoint';
  }

  Future<Map<String, dynamic>> getPermit(String code) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        return {'success': false, 'statusCode': 401, 'message': 'No token found'};
      }

      final apiUrl = _getApiUrl('/permits?code=$code');
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'permit': Permit.fromJson(data)};
      } else {
        return {'success': false, 'statusCode': response.statusCode, 'message': response.body};
      }
    } on SocketException {
      return {'success': false, 'message': 'No internet connection'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> postCheckIn(
    String code,
    int direction, {
    String remark = '',
  }) async {
    try {
      final token = await StorageService.getToken();

      final now = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

      final response = await http.post(
        Uri.parse('https://mis.ntnc.org.np/api/v1/check-in'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'code': code,
          'direction': direction,
          'logged_at': now,
          'remark': remark,
        }),
      );

      debugPrint('CheckIn status: ${response.statusCode}');
      debugPrint('CheckIn body: ${response.body}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Success',
        };
      } else if (response.statusCode == 401) {
        return {'success': false, 'statusCode': 401, 'message': 'Unauthorized'};
      } else if (response.statusCode == 404) {
        return {'success': false, 'statusCode': 404, 'message': 'Permit not found'};
      } else if (response.statusCode == 422) {
        final data = json.decode(response.body);
        return {'success': false, 'statusCode': 422, 'message': data.toString()};
      } else {
        return {
          'success': false,
          'statusCode': response.statusCode,
          'message': 'Failed: ${response.body}',
        };
      }
    } catch (e) {
      return {'success': false, 'statusCode': 0, 'message': e.toString()};
    }
  }
}
