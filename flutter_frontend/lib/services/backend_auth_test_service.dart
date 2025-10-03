import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../config/environment.dart';
import 'firebase_rest_auth_service.dart';

/// Service for testing backend authorization with Firebase JWT tokens.
/// 
/// This service provides methods to test the FastAPI backend authorization
/// layer by sending Firebase JWT tokens for verification.
class BackendAuthTestService {
  /// Base URL for the mock API server
  static const String baseUrl = 'https://mock-server-firebase.onrender.com';
  
  /// HTTP client configured with timeout settings
  final http.Client _client = http.Client();
  
  /// Tests backend authorization with Firebase JWT token and FastAPI API key.
  /// 
  /// Returns a map containing the test result and response details.
  Future<Map<String, dynamic>> testBackendAuthorization(BuildContext context) async {
    try {
      debugPrint('Testing backend authorization with Firebase JWT token + FastAPI API key');
      debugPrint('Base URL: $baseUrl');
      
      // Get Firebase JWT token from the current auth service via Provider
      final firebaseService = Provider.of<FirebaseRestAuthService>(context, listen: false);
      final String? firebaseJwtToken = firebaseService.getFirebaseJwtToken();
      
      if (firebaseJwtToken == null) {
        return {
          'success': false,
          'statusCode': 0,
          'message': 'No Firebase JWT token available. Please sign in first.',
          'error': 'No authentication token',
        };
      }
      
      // FastAPI API key from environment
      final String fastApiApiKey = Environment.fastApiApiKey;
      
      final response = await _client.get(
        Uri.parse('$baseUrl/accounts'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $firebaseJwtToken',  // Firebase JWT token
          'X-API-Key': fastApiApiKey,  // FastAPI API key
        },
      ).timeout(const Duration(seconds: 10));
      
      debugPrint('Backend Auth Test Response: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'statusCode': response.statusCode,
          'message': 'Authorization successful! Backend accepted Firebase JWT token.',
          'data': data,
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'statusCode': response.statusCode,
          'message': 'Backend rejected Firebase JWT token (401 Unauthorized).',
          'error': 'Unauthorized - Invalid or expired token',
        };
      } else if (response.statusCode == 500) {
        return {
          'success': false,
          'statusCode': response.statusCode,
          'message': 'Backend server error (500). The server may be having issues.',
          'error': 'Internal Server Error - Server may be down or misconfigured',
        };
      } else {
        return {
          'success': false,
          'statusCode': response.statusCode,
          'message': 'Unexpected response from backend.',
          'error': 'Status code: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('Backend authorization test error: $e');
      return {
        'success': false,
        'statusCode': null,
        'message': 'Network error during authorization test.',
        'error': e.toString(),
      };
    }
  }
  
  /// Disposes the HTTP client
  void dispose() {
    _client.close();
  }
}

