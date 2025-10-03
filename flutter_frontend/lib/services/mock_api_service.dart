import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/environment.dart';

/// Service for interacting with the Firebase-compatible mock API server.
/// 
/// This service provides methods to test connectivity and fetch data from
/// the Firebase-compatible mock server at https://mock-server-firebase.onrender.com.
class MockApiService {
  /// Base URL for the Firebase-compatible mock API server
  static String get baseUrl => Environment.newMockServerUrl;
  
  /// HTTP client configured with timeout settings
  final http.Client _client = http.Client();
  
  /// Optional Bearer token for authenticated requests
  String? _bearerToken;
  
  /// Set the Bearer token for authenticated requests
  void setBearerToken(String? token) {
    _bearerToken = token;
  }
  
  /// Get the Bearer token
  String? get bearerToken => _bearerToken;
  
  /// Get headers for API requests, including Bearer token if available
  Map<String, String> _getHeaders({bool includeAuth = true}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (includeAuth && _bearerToken != null) {
      headers['Authorization'] = 'Bearer $_bearerToken';
    }
    
    return headers;
  }
  
  /// Makes a GET request with the real Firebase JWT token
  Future<http.Response> _getWithRealToken(String url) async {
    debugPrint('Making request to: $url');

    // Get the current Firebase JWT token from the auth service
    String? firebaseToken = _bearerToken;

    if (firebaseToken == null) {
      throw Exception('No Firebase JWT token available. Please sign in first.');
    }

    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $firebaseToken',
        },
      ).timeout(const Duration(seconds: 30)); // Increased timeout to 30 seconds

      debugPrint('Response with real Firebase token: ${response.statusCode}');
      return response;
    } catch (e) {
      debugPrint('Request failed: $e');
      rethrow;
    }
  }
  
  /// Fetches email messages from the Firebase-compatible mock server
  Future<List<Map<String, dynamic>>> getEmailMessages() async {
    return _fetchData('$baseUrl/db/email/messages', 'items', 'email messages');
  }
  
  /// Fetches calendar events from the Firebase-compatible mock server
  Future<List<Map<String, dynamic>>> getCalendarEvents() async {
    return _fetchData('$baseUrl/db/calendar/events', 'items', 'calendar events');
  }
  
  /// Fetches user accounts from the Firebase-compatible mock server
  Future<List<Map<String, dynamic>>> getAccounts() async {
    return _fetchData('$baseUrl/accounts', 'accounts', 'user accounts');
  }
  
  /// Generic method to fetch data from the mock server with retry logic
  Future<List<Map<String, dynamic>>> _fetchData(String url, String dataKey, String dataType) async {
    int maxRetries = 3;
    int retryCount = 0;
    
    while (retryCount < maxRetries) {
      try {
        debugPrint('Fetching $dataType from Firebase mock server... (attempt ${retryCount + 1})');
        final response = await _getWithRealToken(url);
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          debugPrint('$dataType Response: ${response.statusCode}');
          
          // Handle different response formats
          List<Map<String, dynamic>> result = [];
          
          if (data is List) {
            // If the response is already a list
            result = List<Map<String, dynamic>>.from(data);
          } else if (data is Map && data.containsKey(dataKey)) {
            // If the response has the expected key
            final items = data[dataKey];
            if (items is List) {
              result = List<Map<String, dynamic>>.from(items);
            } else {
              result = [Map<String, dynamic>.from(items)];
            }
          } else {
            // If the response is a single object, wrap it in a list
            result = [Map<String, dynamic>.from(data)];
          }
          
          debugPrint('Parsed $dataType: ${result.length} items');
          debugPrint('Sample data structure: ${result.isNotEmpty ? result.first : 'No data'}');
          return result;
        } else {
          debugPrint('Error fetching $dataType: ${response.statusCode}');
          throw Exception('Failed to fetch $dataType: ${response.statusCode}');
        }
      } catch (e) {
        retryCount++;
        debugPrint('Error fetching $dataType (attempt $retryCount): $e');
        
        if (retryCount >= maxRetries) {
          debugPrint('Max retries reached for $dataType');
          rethrow;
        }
        
        // Wait before retrying
        await Future.delayed(Duration(seconds: retryCount * 2));
      }
    }
    
    throw Exception('Failed to fetch $dataType after $maxRetries attempts');
  }
  
  // Removed fallback mock data - now using real Firebase JWT token
  
  /// Tests the connection to the mock API server
  Future<bool> testConnection() async {
    try {
      debugPrint('Testing connection to Firebase mock server...');
      final response = await _client
          .get(
            Uri.parse(baseUrl),
            headers: _getHeaders(),
          )
          .timeout(const Duration(seconds: 10));
      
      debugPrint('Connection test response: ${response.statusCode}');
      return response.statusCode < 500; // Any response < 500 means server is reachable
    } catch (e) {
      debugPrint('Connection test failed: $e');
      return false;
    }
  }
  
  /// Tests common endpoints (for compatibility)
  Future<List<String>> testCommonEndpoints() async {
    return ['/accounts', '/db/email/messages', '/db/calendar/events'];
  }
  
  /// Discovers available endpoints (for compatibility)
  Future<Map<String, dynamic>> discoverEndpoints() async {
    return {
      'success': true,
      'endpoints': ['/accounts', '/db/email/messages', '/db/calendar/events'],
      'count': 3,
    };
  }
  
  /// Get individual email by string ID (for compatibility)
  Future<Map<String, dynamic>> getEmailByStringId(String id) async {
    try {
      final response = await _getWithRealToken('$baseUrl/emails/$id');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'error': 'Email not found',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  /// Get individual email by integer ID (for compatibility)
  Future<Map<String, dynamic>> getEmailByIntId(int id) async {
    try {
      final response = await _getWithRealToken('$baseUrl/db/email/messages/$id');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'error': 'Email not found',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  /// Disposes the HTTP client
  void dispose() {
    _client.close();
  }
}