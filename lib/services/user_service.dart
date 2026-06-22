import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:ntnc/models/user_profile.dart';
import 'package:ntnc/services/storage_service.dart';

class UserService {
  static const String baseUrl = 'https://mis.ntnc.org.np/api';
  static const String corsProxy = 'https://corsproxy.io/?';

  String _getApiUrl(String endpoint) {
    if (kIsWeb) {
      return '$corsProxy$baseUrl$endpoint';
    }
    return '$baseUrl$endpoint';
  }

  Future<UserProfile?> getProfile() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final apiUrl = _getApiUrl('/v1/profile');
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
        return UserProfile.fromJson(data);
      } else if (response.statusCode == 401) {
        await StorageService.clearAll();
        return null;
      } else {
        throw Exception('Failed to load profile');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } catch (e) {
      throw Exception('Error loading profile: $e');
    }
  }
}
