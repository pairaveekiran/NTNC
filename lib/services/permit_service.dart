import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
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

  Future<Map<String, dynamic>> postCheckIn(String code, int direction) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        return {'success': false, 'statusCode': 401};
      }

      final apiUrl = _getApiUrl('/checkins');
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'code': code, 'direction': direction}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true};
      } else {
        return {'success': false, 'statusCode': response.statusCode};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
