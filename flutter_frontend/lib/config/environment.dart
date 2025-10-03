import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration for the Infinity Link app.
/// 
/// This file loads configuration from environment variables (.env file)
/// and provides fallback values for development.
class Environment {
  /// Firebase project configuration
  static String get firebaseProjectId => dotenv.env['FIREBASE_PROJECT_ID'] ?? 'infinity-link-878fe';
  static String get firebaseApiKey => dotenv.env['FIREBASE_API_KEY'] ?? 'AIzaSyDrwx-cR0Q6PCalqdJ53zYH8agQe7jUGvo';
  static String get firebaseAuthDomain => dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? 'infinity-link-878fe.firebaseapp.com';
  static String get firebaseStorageBucket => dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? 'infinity-link-878fe.appspot.com';
  static String get firebaseMessagingSenderId => dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '123456789';
  static String get firebaseAppId => dotenv.env['FIREBASE_APP_ID'] ?? '1:123456789:web:abcdef123456';
  static String get firebaseMeasurementId => dotenv.env['FIREBASE_MEASUREMENT_ID'] ?? 'G-XXXXXXXXXX';
  
  /// Mock API configuration
  static String get mockApiBaseUrl => dotenv.env['MOCK_API_BASE_URL'] ?? 'https://mock-server-firebase.onrender.com';
  static String get newMockServerUrl => dotenv.env['NEW_MOCK_SERVER_URL'] ?? 'https://mock-server-firebase.onrender.com';
  static String get oldMockServerUrl => dotenv.env['OLD_MOCK_SERVER_URL'] ?? 'https://mock-server-6yyu.onrender.com';
  
  /// FastAPI configuration
  static String get fastApiApiKey => dotenv.env['FASTAPI_API_KEY'] ?? 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzZW50aW5lbC1hdXRoIiwiYXVkIjoic2VudGluZWwtY2xpZW50cyIsInN1YiI6InVzZXItNDIiLCJ1aWQiOjQyLCJqdGkiOiIyMTU0OTRiMDEzZGI0NDFkOGI4MGU0NDI5ZTI4ZWJkNyIsInR5cCI6ImFjY2VzcyIsImlhdCI6MTc1OTMzOTQ1MywiZXhwIjoxNzYxNzM5NDUzfQ.H5u_k3F_A1yv5zfyXui3dhHYnD1PoaMljw_TNPKASJc';
  
  /// Development settings
  static bool get debugMode => dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true' || true;
  static bool get enableLogging => dotenv.env['ENABLE_LOGGING']?.toLowerCase() == 'true' || true;
  
  /// Firebase configuration for SDK initialization
  static Map<String, String> get firebaseConfig => {
    'apiKey': firebaseApiKey,
    'authDomain': firebaseAuthDomain,
    'projectId': firebaseProjectId,
    'storageBucket': firebaseStorageBucket,
    'messagingSenderId': firebaseMessagingSenderId,
    'appId': firebaseAppId,
    'measurementId': firebaseMeasurementId,
  };
}
