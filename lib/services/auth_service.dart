import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:ntnc/services/storage_service.dart';

class AuthService {
  static const String baseUrl = 'https://mis.ntnc.org.np/api';
  
  // CORS proxy for web
  static const String corsProxy = 'https://corsproxy.io/?';

  String _getApiUrl(String endpoint) {
    if (kIsWeb) {
      return '$corsProxy$baseUrl$endpoint';
    }
    return '$baseUrl$endpoint';
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final apiUrl = _getApiUrl('/login');
      print('Platform: ${StorageService.getPlatform()}');
      print('Attempting login for: $email');
      print('API URL: $apiUrl');
      
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout. Please check your connection.');
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'];
        
        // Save token to persistent storage
        await StorageService.saveToken(token);
        await StorageService.saveUserEmail(email);
        
        print('Token saved successfully');
        
        return {
          'success': true,
          'data': data,
        };
      } else if (response.statusCode == 401) {
        try {
          final data = jsonDecode(response.body);
          return {
            'success': false,
            'message': data['message'] ?? 'Email or password do not matched!',
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Email or password do not matched!',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Server error (${response.statusCode}). Please try again later.',
        };
      }
    } on SocketException catch (e) {
      print('SocketException: $e');
      return {
        'success': false,
        'message': 'No internet connection. Please check your network.',
      };
    } on http.ClientException catch (e) {
      print('ClientException: $e');
      return {
        'success': false,
        'message': 'Connection failed. Please check your internet connection and try again.',
      };
    } on HttpException catch (e) {
      print('HttpException: $e');
      return {
        'success': false,
        'message': 'Network error. Please try again.',
      };
    } on FormatException catch (e) {
      print('FormatException: $e');
      return {
        'success': false,
        'message': 'Invalid server response.',
      };
    } catch (e) {
      print('Unexpected error: $e');
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // Logout method
  Future<bool> logout() async {
    try {
      await StorageService.clearAll();
      print('User logged out successfully');
      return true;
    } catch (e) {
      print('Error during logout: $e');
      return false;
    }
  }

  // Check if user has valid session
  Future<bool> hasValidSession() async {
    return await StorageService.isLoggedIn();
  }
}
