import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firebase_rest_auth_service.dart';
import '../services/fastapi_auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _obscurePassword = true;
  bool _useFastAPI = false; // Toggle between Firebase-only and Firebase + FastAPI

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Handles user authentication (sign in or sign up).
  /// 
  /// Validates the form, calls the appropriate authentication method,
  /// and shows success or error messages to the user.
  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;
    
    try {
      if (_useFastAPI) {
        await _handleFirebaseWithFastAPI();
      } else {
        await _handleFirebaseOnly();
      }
    } catch (e) {
      _handleAuthError(e);
    }
  }
  
  /// Handles Firebase-only authentication (no FastAPI verification)
  Future<void> _handleFirebaseOnly() async {
    final authService = Provider.of<FirebaseRestAuthService>(context, listen: false);
    
    if (_isSignUp) {
      await _handleSignUp(authService);
    } else {
      await _handleSignIn(authService);
    }
  }
  
  /// Handles Firebase authentication with FastAPI verification
  Future<void> _handleFirebaseWithFastAPI() async {
    final firebaseAuth = Provider.of<FirebaseRestAuthService>(context, listen: false);
    final fastApiAuth = Provider.of<FastApiAuthService>(context, listen: false);
    
    if (_isSignUp) {
      // Firebase sign-up
      await firebaseAuth.createUserWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      // Get Firebase JWT token
      final firebaseJwtToken = firebaseAuth.getFirebaseJwtToken();
      
      // FastAPI verification
      await fastApiAuth.signInWithFastAPI(
        _emailController.text.trim(),
        _passwordController.text,
        firebaseJwtToken,
      );
      
      if (mounted) {
        _showSuccessMessage('Account created with Firebase + FastAPI verification!');
      }
    } else {
      // Firebase sign-in
      await firebaseAuth.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      // Get Firebase JWT token
      final firebaseJwtToken = firebaseAuth.getFirebaseJwtToken();
      
      // FastAPI verification
      await fastApiAuth.signInWithFastAPI(
        _emailController.text.trim(),
        _passwordController.text,
        firebaseJwtToken,
      );
      
      if (mounted) {
        _showSuccessMessage('Signed in with Firebase + FastAPI verification!');
      }
    }
  }
  

  /// Handles user sign up process
  Future<void> _handleSignUp(FirebaseRestAuthService authService) async {
    await authService.createUserWithEmailAndPassword(
      _emailController.text.trim(),
      _passwordController.text,
    );
    
    if (mounted) {
      _showSuccessMessage('Account created successfully!');
    }
  }

  /// Handles user sign in process
  Future<void> _handleSignIn(FirebaseRestAuthService authService) async {
    await authService.signInWithEmailAndPassword(
      _emailController.text.trim(),
      _passwordController.text,
    );
    
    if (mounted) {
      _showSuccessMessage('Signed in successfully!');
    }
  }
  
  // FastAPI verification is now handled automatically by Firebase service

  /// Handles authentication errors and shows appropriate messages
  void _handleAuthError(dynamic error) {
    if (!mounted) return;
    
    final errorMessage = _parseFirebaseError(error.toString());
    _showErrorMessage(errorMessage);
  }

  /// Parses Firebase error messages into user-friendly text
  String _parseFirebaseError(String error) {
    if (error.contains('INVALID_LOGIN_CREDENTIALS')) {
      return 'Invalid email or password. Please check your credentials.';
    } else if (error.contains('EMAIL_EXISTS')) {
      return 'An account with this email already exists.';
    } else if (error.contains('WEAK_PASSWORD')) {
      return 'Password should be at least 6 characters.';
    } else if (error.contains('INVALID_EMAIL')) {
      return 'Please enter a valid email address.';
    } else if (error.contains('USER_NOT_FOUND')) {
      return 'No account found with this email.';
    } else if (error.contains('TOO_MANY_ATTEMPTS_TRY_LATER')) {
      return 'Too many failed attempts. Please try again later.';
    } else if (error.contains('NETWORK_ERROR')) {
      return 'Network error. Please check your connection.';
    } else if (error.contains('TIMEOUT')) {
      return 'Request timed out. Please try again.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Shows a success message to the user
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Shows an error message to the user
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Handles password reset request.
  /// 
  /// Validates that an email is entered, then sends a password reset email
  /// using Firebase's password reset API.
  Future<void> _handlePasswordReset() async {
    final email = _emailController.text.trim();
    
    if (email.isEmpty) {
      _showWarningMessage('Please enter your email address first');
      return;
    }

    final authService = Provider.of<FirebaseRestAuthService>(context, listen: false);
    
    try {
      await authService.resetPassword(email);
      if (mounted) {
        _showInfoMessage('Password reset email sent! Check your inbox.');
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = _parseFirebaseError(e.toString());
        _showErrorMessage('Password reset failed: $errorMessage');
      }
    }
  }

  /// Shows a warning message to the user
  void _showWarningMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Shows an info message to the user
  void _showInfoMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 4),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1976D2),
              Color(0xFF1565C0),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo and Title
                        const Icon(
                          Icons.link,
                          size: 64,
                          color: Color(0xFF1976D2),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Infinity Link',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1976D2),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isSignUp ? 'Create your account' : 'Welcome back',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Authentication Method Toggle
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _useFastAPI = false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: !_useFastAPI ? Colors.white : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: !_useFastAPI ? [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ] : null,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.security,
                                          size: 20,
                                          color: !_useFastAPI ? const Color(0xFF1976D2) : Colors.grey[600],
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Firebase Only',
                                          style: TextStyle(
                                            fontWeight: !_useFastAPI ? FontWeight.bold : FontWeight.normal,
                                            color: !_useFastAPI ? const Color(0xFF1976D2) : Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _useFastAPI = true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: _useFastAPI ? Colors.white : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: _useFastAPI ? [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ] : null,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.api,
                                          size: 20,
                                          color: _useFastAPI ? const Color(0xFF1976D2) : Colors.grey[600],
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Firebase + FastAPI',
                                          style: TextStyle(
                                            fontWeight: _useFastAPI ? FontWeight.bold : FontWeight.normal,
                                            color: _useFastAPI ? const Color(0xFF1976D2) : Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outlined),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (_isSignUp && value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Auth Button
                        Consumer<FirebaseRestAuthService>(
                          builder: (context, authService, child) {
                            return SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: authService.isLoading ? null : _handleAuth,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1976D2),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                                child: authService.isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Text(
                                        _isSignUp ? 'Create Account' : 'Sign In',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // Divider
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'OR',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Toggle Sign Up/Sign In
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isSignUp = !_isSignUp;
                            });
                          },
                          child: Text(
                            _isSignUp
                                ? 'Already have an account? Sign In'
                                : 'Don\'t have an account? Sign Up',
                            style: const TextStyle(
                              color: Color(0xFF1976D2),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        // Password Reset
                        if (!_isSignUp) ...[
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _handlePasswordReset,
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}