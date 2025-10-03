import 'package:flutter/material.dart';

/// A welcome card widget that displays user information and greeting.
/// 
/// Shows the user's avatar, welcome message, and email address in a
/// clean, modern card design.
class WelcomeCard extends StatelessWidget {
  /// The user's email address
  final String? userEmail;
  
  /// The user's display name
  final String? displayName;

  const WelcomeCard({
    super.key,
    required this.userEmail,
    this.displayName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildUserAvatar(),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildUserInfo(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the user avatar circle
  Widget _buildUserAvatar() {
    return CircleAvatar(
      radius: 30,
      backgroundColor: const Color(0xFF1976D2),
      child: Text(
        _getUserInitial(),
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Builds the user information section
  Widget _buildUserInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back!',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1976D2),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          userEmail ?? 'User',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// Gets the first letter of the user's email for the avatar
  String _getUserInitial() {
    if (userEmail != null && userEmail!.isNotEmpty) {
      return userEmail!.substring(0, 1).toUpperCase();
    }
    return 'U';
  }
}


