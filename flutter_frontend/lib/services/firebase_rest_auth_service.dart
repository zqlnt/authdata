import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/environment.dart';

/// Firebase authentication service using REST API calls.
/// 
/// This service handles user authentication through Firebase's REST API,
/// providing email/password sign-in, sign-up, password reset, and sign-out
/// functionality. It's designed to work with Flutter web applications.
class FirebaseRestAuthService extends ChangeNotifier {
  // Private state variables
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _userEmail;
  String? _userId;
  String? _displayName;
  String? _idToken;

  /// Firebase project configuration (from Environment)
  static String get projectId => Environment.firebaseProjectId;
  static String get apiKey => Environment.firebaseApiKey;
  static String get authDomain => Environment.firebaseAuthDomain;
  
  /// Firebase REST API endpoints for authentication
  static String get signInUrl => 'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${Environment.firebaseApiKey}';
  static String get signUpUrl => 'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${Environment.firebaseApiKey}';
  static String get passwordResetUrl => 'https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=${Environment.firebaseApiKey}';

  // Public getters for accessing authentication state
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get userEmail => _userEmail;
  String? get userId => _userId;
  String? get displayName => _displayName;
  String? get idToken => _idToken;
  
  /// Gets the current Firebase JWT token for backend authorization
  String? getFirebaseJwtToken() {
    return _idToken;
  }

  /// Gets the bearer token (alias for idToken for compatibility)
  String? get bearerToken => _idToken;

  /// Signs in a user with email and password using Firebase REST API.
  /// 
  /// [email] - The user's email address
  /// [password] - The user's password
  /// 
  /// Throws an exception if authentication fails or network error occurs.
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('Firebase Email Sign-In via REST API');
      debugPrint('Email: $email');
      debugPrint('Project: $projectId');
      debugPrint('URL: $signInUrl');
      
      final response = await http.post(
        Uri.parse(signInUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );
      
      debugPrint('Firebase API Response: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        _isAuthenticated = true;
        _userEmail = data['email'];
        _userId = data['localId'];
        _displayName = data['displayName'] ?? email.split('@')[0];
        _idToken = data['idToken'];
        
        debugPrint('Firebase email sign-in successful!');
        debugPrint('User ID: $_userId');
        debugPrint('Email: $_userEmail');
        debugPrint('ID Token: ${_idToken?.substring(0, 20)}...');
      } else {
        final error = json.decode(response.body);
        throw Exception('Firebase Error: ${error['error']['message']}');
      }
    } catch (e) {
      debugPrint('Firebase sign-in error: $e');
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Creates a new user account with email and password using Firebase REST API.
  /// 
  /// [email] - The user's email address
  /// [password] - The user's password (must be at least 6 characters)
  /// 
  /// Throws an exception if account creation fails or network error occurs.
  Future<void> createUserWithEmailAndPassword(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('Firebase Email Sign-Up via REST API');
      debugPrint('Email: $email');
      debugPrint('Project: $projectId');
      debugPrint('URL: $signUpUrl');
      
      final response = await http.post(
        Uri.parse(signUpUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );
      
      debugPrint('Firebase API Response: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        _isAuthenticated = true;
        _userEmail = data['email'];
        _userId = data['localId'];
        _displayName = data['displayName'] ?? email.split('@')[0];
        _idToken = data['idToken'];
        
        debugPrint('Firebase email sign-up successful!');
        debugPrint('User ID: $_userId');
        debugPrint('Email: $_userEmail');
        debugPrint('ID Token: ${_idToken?.substring(0, 20)}...');
      } else {
        final error = json.decode(response.body);
        throw Exception('Firebase Error: ${error['error']['message']}');
      }
    } catch (e) {
      debugPrint('Firebase sign-up error: $e');
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Google Sign-In authentication (not yet implemented).
  /// 
  /// This is a placeholder method for future Google OAuth integration.
  /// Currently throws an exception indicating the feature is not available.
  Future<void> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('Google Sign-In not yet implemented');
      throw Exception('Google Sign-In will be implemented in a future update');
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Sends a password reset email to the user using Firebase REST API.
  /// 
  /// [email] - The user's email address to send the reset link to
  /// 
  /// Throws an exception if the email is invalid or network error occurs.
  Future<void> resetPassword(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('Firebase Password Reset via REST API');
      debugPrint('Email: $email');
      debugPrint('Project: $projectId');
      debugPrint('URL: $passwordResetUrl');
      
      final response = await http.post(
        Uri.parse(passwordResetUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'requestType': 'PASSWORD_RESET',
        }),
      );
      
      debugPrint('Firebase API Response: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        debugPrint('Password reset email sent via Firebase!');
      } else {
        final error = json.decode(response.body);
        throw Exception('Firebase Error: ${error['error']['message']}');
      }
    } catch (e) {
      debugPrint('Firebase password reset error: $e');
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Signs out the current user and clears all authentication data.
  /// 
  /// This method resets all user state and notifies listeners of the change.
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('Firebase Sign Out');
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      _isAuthenticated = false;
      _userEmail = null;
      _userId = null;
      _displayName = null;
      _idToken = null;

      debugPrint('Firebase sign-out successful!');
    } catch (e) {
      debugPrint('Firebase sign-out error: $e');
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
  }
}
