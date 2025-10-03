import 'package:flutter/foundation.dart';

/// FastAPI verification service for Firebase tokens.
/// 
/// This service acts as a verification layer for Firebase authentication.
/// It receives Firebase JWT tokens and provides mock verification for demo purposes.
class FastApiAuthService extends ChangeNotifier {
  // Private state variables
  bool _isLoading = false;
  bool _isVerified = false;
  String? _userEmail;
  String? _userId;
  String? _displayName;
  String? _bearerToken;
  String? _authMethod;
  String? _firebaseJwtToken;

  // Public getters for accessing verification state
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isVerified; // Alias for compatibility
  bool get isVerified => _isVerified;
  String? get userEmail => _userEmail;
  String? get userId => _userId;
  String? get displayName => _displayName;
  String? get bearerToken => _bearerToken;
  String? get authMethod => _authMethod;
  String? get firebaseJwtToken => _firebaseJwtToken;
  
  /// Gets the Firebase JWT token for backend authorization
  String? getFirebaseJwtToken() {
    return _firebaseJwtToken;
  }

  /// Verifies Firebase authentication with FastAPI server.
  /// 
  /// [email] - The user's email address
  /// [password] - The user's password (not used in verification)
  /// [firebaseJwtToken] - The Firebase JWT token for verification
  /// 
  /// This method provides mock verification for demo purposes.
  Future<void> signInWithFastAPI(String email, String password, String? firebaseJwtToken) async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('FastAPI Firebase Verification via REST API');
      debugPrint('Email: $email');
      debugPrint('Using mock verification mode');

      // Mock verification - always succeeds for demo
      _isVerified = true;
      _userEmail = email;
      _userId = 'firebase_${email.hashCode}';
      _displayName = email.split('@')[0];
      _bearerToken = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
      _authMethod = 'FastAPI + Firebase (Mock)';
      _firebaseJwtToken = firebaseJwtToken;

      debugPrint('FastAPI Firebase verification completed (Mock Mode)');
      debugPrint('User ID: $_userId');
      debugPrint('Email: $_userEmail');
      debugPrint('Bearer Token: ${_bearerToken?.substring(0, 20)}...');
      debugPrint('Auth Method: $_authMethod');
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('FastAPI verification error: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Signs out the user and clears all verification state.
  void signOut() {
    _isLoading = false;
    _isVerified = false;
    _userEmail = null;
    _userId = null;
    _displayName = null;
    _bearerToken = null;
    _authMethod = null;
    _firebaseJwtToken = null;
    
    debugPrint('FastAPI sign-out completed');
    notifyListeners();
  }
}