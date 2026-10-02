import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:ntnc/models/user_profile.dart';
import 'package:ntnc/services/storage_service.dart';

class UserService {
  static const String baseUrl = 'https://mis.ntnc.org.np/api';
  static UserProfile? _cachedProfile;

  String _getApiUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
  
  static void clearCache() {
    _cachedProfile = null;
  }

  Future<UserProfile?> getProfile({bool forceRefresh = false}) async {
    if (_cachedProfile != null && !forceRefresh) {
      return _cachedProfile;
    }

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
        _cachedProfile = UserProfile.fromJson(data);
        return _cachedProfile;
      } else if (response.statusCode == 401) {
        await StorageService.clearAll();
        _cachedProfile = null;
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
