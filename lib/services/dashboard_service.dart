import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:ntnc/services/storage_service.dart';
import 'package:ntnc/models/today_check_in_response.dart';

class DashboardService {
  static final DashboardService _instance = DashboardService._internal();
  factory DashboardService() => _instance;
  DashboardService._internal();

  static const String baseUrl = 'https://mis.ntnc.org.np/api/v1';

  TodayCheckInResponse? cachedResponse;

  String _getApiUrl(String endpoint) {
    if (kIsWeb) {
      return '$baseUrl$endpoint';
    }
    return '$baseUrl$endpoint';
  }

  Future<TodayCheckInResponse> fetchTodayCheckIns({bool forceRefresh = false}) async {
    if (!forceRefresh && cachedResponse != null) {
      return cachedResponse!;
    }

    final token = await StorageService.getToken();
    if (token == null) {
      throw Exception('No authentication token found.');
    }

    final apiUrl = _getApiUrl('/check-ins/today');
    try {
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
        cachedResponse = TodayCheckInResponse.fromJson(data);
        return cachedResponse!;
      } else {
        throw Exception('Failed to load check-ins (${response.statusCode})');
      }
    } on SocketException {
      throw Exception('No internet connection.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
