import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/firebase_rest_auth_service.dart';
import 'services/fastapi_auth_service.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

/// Main entry point for the Infinity Link application.
/// 
/// This Flutter web app provides Firebase authentication and mock API integration
/// for testing and development purposes. The app uses Firebase REST API for
/// authentication and connects to a mock server for data fetching.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  try {
    await dotenv.load(fileName: ".env");
    debugPrint('Environment variables loaded successfully');
  } catch (e) {
    debugPrint('Could not load .env file, using fallback values: $e');
  }

  // Initialize the app
  runApp(const MyApp());
}

/// The main application widget that sets up the app structure and theme.
/// 
/// This widget configures the Material Design theme, provides the authentication
/// service to the widget tree, and handles the initial routing between
/// authentication and home screens.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => FirebaseRestAuthService()),
            ChangeNotifierProvider(create: (context) => FastApiAuthService()),
          ],
      child: MaterialApp(
        title: 'Infinity Link',
        theme: _buildAppTheme(),
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  /// Creates the app's theme configuration.
  /// 
  /// Uses Material 3 design with a blue color scheme that matches
  /// the Infinity Link branding.
  ThemeData _buildAppTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1976D2),
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }
}

/// Handles the authentication state and routes users to appropriate screens.
/// 
/// This widget listens to the authentication service and displays:
/// - LoadingScreen while checking authentication status
/// - HomeScreen for authenticated users
/// - AuthScreen for unauthenticated users
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<FirebaseRestAuthService, FastApiAuthService>(
      builder: (context, firebaseAuth, fastApiAuth, child) {
        // Show loading screen while checking auth state
        if (firebaseAuth.isLoading || fastApiAuth.isLoading) {
          return const LoadingScreen();
        }

        // Show home screen if user is authenticated with either service
        if (firebaseAuth.isAuthenticated || fastApiAuth.isAuthenticated) {
          return const HomeScreen();
        }

        // Show auth screen if user is not authenticated
        return const AuthScreen();
      },
    );
  }
}

/// A loading screen displayed while the app initializes or checks authentication.
/// 
/// Shows the Infinity Link branding with a loading indicator to provide
/// visual feedback during app startup and authentication checks.
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: _buildGradientDecoration(),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _AppLogo(),
              SizedBox(height: 24),
              _AppTitle(),
              SizedBox(height: 32),
              _LoadingIndicator(),
              SizedBox(height: 16),
              _LoadingText(),
            ],
          ),
        ),
      ),
    );
  }

  /// Creates the gradient background decoration.
  BoxDecoration _buildGradientDecoration() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF1976D2),
          Color(0xFF1565C0),
        ],
      ),
    );
  }
}

/// The app logo icon displayed on the loading screen.
class _AppLogo extends StatelessWidget {
  const _AppLogo();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.link,
      size: 80,
      color: Colors.white,
    );
  }
}

/// The app title displayed on the loading screen.
class _AppTitle extends StatelessWidget {
  const _AppTitle();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Infinity Link',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}

/// The loading indicator displayed on the loading screen.
class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      strokeWidth: 3,
    );
  }
}

/// The loading text displayed on the loading screen.
class _LoadingText extends StatelessWidget {
  const _LoadingText();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Loading...',
      style: TextStyle(
        fontSize: 16,
        color: Colors.white70,
      ),
    );
  }
}