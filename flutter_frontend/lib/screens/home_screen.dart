import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firebase_rest_auth_service.dart';
import '../services/fastapi_auth_service.dart';
import '../services/backend_auth_test_service.dart';
import '../services/mock_api_service.dart';
import '../widgets/welcome_card.dart';
import '../widgets/auth_status_card.dart';
import 'auth_screen.dart';

/// The main home screen displayed after successful authentication.
/// 
/// This screen provides a dashboard with user information, authentication
/// status, and testing capabilities for the Firebase-compatible mock server.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
  }

  /// Builds the app bar with user menu
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Infinity Link'),
      backgroundColor: const Color(0xFF1976D2),
      foregroundColor: Colors.white,
      actions: [
        _buildUserMenu(context),
      ],
    );
  }

  /// Builds the user menu dropdown
  Widget _buildUserMenu(BuildContext context) {
    return Consumer<FirebaseRestAuthService>(
      builder: (context, authService, child) {
        return PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'logout') {
              await _handleSignOut(context, authService);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Sign Out'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Builds the main body content
  Widget _buildBody(BuildContext context) {
    return Consumer2<FirebaseRestAuthService, FastApiAuthService>(
      builder: (context, firebaseAuth, fastApiAuth, child) {
        // Determine which auth service is active
        final isFirebaseAuth = firebaseAuth.isAuthenticated;
        final isFastApiAuth = fastApiAuth.isAuthenticated;
        final activeAuthService = isFirebaseAuth ? firebaseAuth : fastApiAuth;
        
        return Container(
          decoration: _buildBackgroundDecoration(),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeSection(activeAuthService),
                  const SizedBox(height: 24),
                  _buildAuthStatusSection(activeAuthService, isFirebaseAuth),
                  const SizedBox(height: 24),
                  _buildBackendAuthTestSection(context),
                  const SizedBox(height: 24),
                  _buildMockServerSection(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Builds the background decoration
  BoxDecoration _buildBackgroundDecoration() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFF5F5F5),
          Color(0xFFE8EAF6),
        ],
      ),
    );
  }

  /// Builds the welcome section
  Widget _buildWelcomeSection(dynamic activeAuthService) {
    return WelcomeCard(
      userEmail: activeAuthService.userEmail ?? 'User',
    );
  }

  /// Builds the authentication status section
  Widget _buildAuthStatusSection(dynamic activeAuthService, bool isFirebaseAuth) {
    return AuthStatusCard(
      userId: activeAuthService.userId,
      userEmail: activeAuthService.userEmail,
      authMethod: isFirebaseAuth ? 'Firebase' : 'FastAPI + Firebase',
      bearerToken: activeAuthService.bearerToken,
    );
  }

  /// Builds the backend authorization test section
  Widget _buildBackendAuthTestSection(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Backend Authorization Test',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Test if your Firebase JWT token works with the backend server.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _testBackendAuth(context),
                icon: const Icon(Icons.security),
                label: const Text('Test Backend Authorization'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the mock server section
  Widget _buildMockServerSection(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Firebase Mock Server Data',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Fetch data from the Firebase-compatible mock server.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _testMockServerData(context, 'Email Messages', 'messages'),
                    icon: const Icon(Icons.email),
                    label: const Text('Email Messages'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _testMockServerData(context, 'Calendar Events', 'events'),
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Calendar Events'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _testMockServerData(context, 'User Accounts', 'accounts'),
                icon: const Icon(Icons.people),
                label: const Text('User Accounts'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[600],
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Handles user sign out
  Future<void> _handleSignOut(BuildContext context, FirebaseRestAuthService authService) async {
    await authService.signOut();
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    }
  }

  /// Tests backend authorization
  Future<void> _testBackendAuth(BuildContext context) async {
    try {
      final service = BackendAuthTestService();
      final result = await service.testBackendAuthorization(context);

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Backend Authorization Test'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status: ${result['success'] ? 'SUCCESS' : 'FAILED'}'),
                Text('Status Code: ${result['statusCode']}'),
                if (result['error'] != null)
                  Text('Error: ${result['error']}'),
                if (result['message'] != null)
                  Text('Message: ${result['message']}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Tests mock server data
  Future<void> _testMockServerData(BuildContext context, String title, String dataType) async {
    try {
      final service = MockApiService();
      
      // Get Firebase JWT token
      final firebaseAuth = Provider.of<FirebaseRestAuthService>(context, listen: false);
      final token = firebaseAuth.getFirebaseJwtToken();
      
      if (token == null) {
        throw Exception('No Firebase JWT token available. Please sign in first.');
      }
      
      service.setBearerToken(token);

      List<Map<String, dynamic>> data;
      switch (dataType) {
        case 'messages':
          data = await service.getEmailMessages();
          break;
        case 'events':
          data = await service.getCalendarEvents();
          break;
        case 'accounts':
          data = await service.getAccounts();
          break;
        default:
          throw Exception('Unknown data type: $dataType');
      }

      if (context.mounted) {
        _showMockServerData(context, title, data, dataType);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Shows mock server data in a dialog
  void _showMockServerData(BuildContext context, String title, List<Map<String, dynamic>> data, String dataType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$title (${data.length} items)'),
        content: SizedBox(
          width: double.maxFinite,
          height: 500,
          child: ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  title: Text(
                    _getItemTitle(item, dataType),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_getItemSubtitle(item, dataType).isNotEmpty)
                        Text(
                          _getItemSubtitle(item, dataType),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 4),
                      Text(
                        _getItemTrailing(item, dataType),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Gets the title for different data types
  String _getItemTitle(Map<String, dynamic> item, String dataType) {
    switch (dataType) {
      case 'messages':
        return item['subject'] ?? 'No Subject';
      case 'events':
        return item['title'] ?? 'No Title';
      case 'accounts':
        return item['gmail_address'] ?? 'No Email';
      default:
        return 'Unknown';
    }
  }

  /// Gets the subtitle for different data types
  String _getItemSubtitle(Map<String, dynamic> item, String dataType) {
    switch (dataType) {
      case 'messages':
        final snippet = item['snippet'] ?? 'No Snippet';
        return snippet.length > 100 ? '${snippet.substring(0, 100)}...' : snippet;
      case 'events':
        final description = item['description'] ?? 'No Description';
        return description.length > 100 ? '${description.substring(0, 100)}...' : description;
      case 'accounts':
        return 'Gmail Account';
      default:
        return 'Unknown';
    }
  }

  /// Gets the trailing text for different data types
  String _getItemTrailing(Map<String, dynamic> item, String dataType) {
    switch (dataType) {
      case 'messages':
        final sender = item['sender'] ?? 'Unknown Sender';
        final recipient = item['recipient'] ?? '';
        return 'From: $sender${recipient.isNotEmpty ? ' → $recipient' : ''}';
      case 'events':
        final location = item['location'];
        final startTime = item['start_utc'];
        if (location != null && location.toString().isNotEmpty) {
          return '📍 $location';
        } else if (startTime != null) {
          return '🕒 ${_formatDateTime(startTime.toString())}';
        } else {
          return '📅 Event';
        }
      case 'accounts':
        return '📧 Gmail';
      default:
        return 'Unknown';
    }
  }

  /// Formats date time for display
  String _formatDateTime(String dateTime) {
    try {
      final date = DateTime.parse(dateTime);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTime;
    }
  }
}