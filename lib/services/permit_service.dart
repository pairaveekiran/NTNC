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

  /// Safely extracts the 'message' string from a JSON response body.
  /// Never returns a raw JSON string or map dump.
  String _extractMessage(String responseBody, {String fallback = 'Something went wrong'}) {
    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is Map && decoded['message'] != null) {
        return decoded['message'].toString();
      }
      // Handle Laravel validation errors: { "errors": { "code": ["msg"] } }
      if (decoded is Map && decoded['errors'] != null) {
        final errors = decoded['errors'] as Map<String, dynamic>;
        if (errors.isNotEmpty) {
          final firstList = errors.values.first;
          if (firstList is List && firstList.isNotEmpty) {
            return firstList.first.toString();
          }
        }
      }
    } catch (_) {
      // responseBody is not JSON — return as-is if short, else fallback
      if (responseBody.length < 100) return responseBody;
    }
    return fallback;
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
        // Always extract clean message — never dump raw body
        return {
          'success': false,
          'statusCode': response.statusCode,
          'message': _extractMessage(response.body),
        };
      }
    } on SocketException {
      return {'success': false, 'statusCode': 0, 'message': 'No internet connection'};
    } catch (e) {
      return {'success': false, 'statusCode': 0, 'message': e.toString()};
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
        Uri.parse('$baseUrl/check-in'),
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
          'message': data['message']?.toString() ?? 'Success',
        };
      } else if (response.statusCode == 401) {
        return {'success': false, 'statusCode': 401, 'message': 'Session expired. Please log in again.'};
      } else if (response.statusCode == 404) {
        return {'success': false, 'statusCode': 404, 'message': 'Permit not found'};
      } else {
        // Covers 422 validation errors and all other failures
        // _extractMessage handles both { message: "..." } and { errors: { field: ["msg"] } }
        return {
          'success': false,
          'statusCode': response.statusCode,
          'message': _extractMessage(response.body),
        };
      }
    } on SocketException {
      return {'success': false, 'statusCode': 0, 'message': 'No internet connection'};
    } catch (e) {
      return {'success': false, 'statusCode': 0, 'message': e.toString()};
    }
  }
}