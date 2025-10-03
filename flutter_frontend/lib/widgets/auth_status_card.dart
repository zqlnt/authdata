import 'package:flutter/material.dart';

/// A card widget that displays the current authentication status.
/// 
/// Shows various authentication details including Firebase connection status,
/// user ID, email verification, and authentication provider information.
class AuthStatusCard extends StatelessWidget {
  /// The user's ID from Firebase
  final String? userId;
  
  /// The user's email address
  final String? userEmail;
  
  /// The authentication method used (Firebase or FastAPI)
  final String? authMethod;
  
  /// The Bearer token for FastAPI authentication
  final String? bearerToken;

  const AuthStatusCard({
    super.key,
    required this.userId,
    required this.userEmail,
    this.authMethod,
    this.bearerToken,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 12),
            _buildStatusRows(),
          ],
        ),
      ),
    );
  }

  /// Builds the card header with icon and title
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.verified_user,
          color: Colors.green[600],
          size: 24,
        ),
        const SizedBox(width: 12),
        Text(
          'Authentication Status',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Builds all the status rows
  Widget _buildStatusRows() {
    final isFirebase = authMethod == 'Firebase';
    
    return Column(
      children: [
        _buildStatusRow(
          'Authentication Method', 
          true, 
          authMethod ?? 'Unknown'
        ),
        if (isFirebase) ...[
          _buildStatusRow('Firebase Auth', true, 'Connected'),
          _buildStatusRow('Firebase Project', true, 'infinity-link-878fe'),
        ] else ...[
          _buildStatusRow('FastAPI Auth', true, 'Connected'),
          _buildStatusRow('Server', true, 'mock-server-6yyu.onrender.com'),
        ],
        _buildStatusRow('User ID', userId != null, userId ?? 'Not available'),
        _buildStatusRow('Email Verified', true, 'Verified'),
        if (bearerToken != null) ...[
          _buildStatusRow('Bearer Token', true, '${bearerToken!.substring(0, 20)}...'),
        ],
        _buildStatusRow(
          'Provider', 
          userEmail?.contains('gmail.com') == true, 
          userEmail?.contains('gmail.com') == true ? 'Google' : 'Email/Password'
        ),
      ],
    );
  }

  /// Builds a single status row with label, status, and value
  Widget _buildStatusRow(String label, bool isSuccess, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.cancel,
                color: isSuccess ? Colors.green : Colors.red,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                value,
                style: TextStyle(
                  color: isSuccess ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

