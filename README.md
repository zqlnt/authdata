# Infinity Link - Firebase Authentication & Data Integration Project

I built this Flutter web app to learn how authentication works with Firebase and FastAPI. It handles user login, manages JWT tokens, and fetches data from a mock server. Let me walk you through how it all works.

## What This App Does

This is a Flutter web app that lets users sign in with email and password. Once logged in, it can fetch email messages, calendar events, and user accounts from a mock server. The interesting part is how it handles authentication - it uses Firebase for the main login, then adds an extra FastAPI layer for security.

The app shows how to work with JWT tokens, handle different authentication methods, and display real data in the UI.

## How the Project is Organized

Here's how I set up the files and folders:

### Root Directory Structure

```
my_firebase_app/
├── flutter_frontend/          # The main Flutter app
│   ├── lib/                   # All the Dart code
│   ├── web/                   # Web-specific stuff
│   ├── pubspec.yaml          # Dependencies list
│   └── .env                   # API keys and config
├── fastapi_backend/          # FastAPI config folder
│   └── .env                   # Backend API keys
├── .gitignore                # What not to commit
└── README.md                 # This file
```

### Flutter App Structure

The main app is in `flutter_frontend/` and I organized it like this:

```
flutter_frontend/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── config/
│   │   └── environment.dart         # Environment configuration
│   ├── screens/
│   │   ├── auth_screen.dart         # Login/signup screen
│   │   └── home_screen.dart         # Main dashboard
│   ├── services/
│   │   ├── firebase_rest_auth_service.dart  # Firebase authentication
│   │   ├── fastapi_auth_service.dart        # FastAPI verification
│   │   ├── backend_auth_test_service.dart   # Backend testing
│   │   └── mock_api_service.dart            # Data fetching
│   └── widgets/
│       ├── welcome_card.dart         # Welcome message component
│       └── auth_status_card.dart     # Auth status display
├── web/
│   ├── index.html            # Web entry point
│   └── favicon.png          # App icon
└── pubspec.yaml             # Dependencies and metadata
```

## How Each File Works

### 1. Main Application Entry (`lib/main.dart`)

This is where the app starts. I set it up to load environment variables and initialize the authentication services.

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FirebaseRestAuthService()),
        ChangeNotifierProvider(create: (_) => FastApiAuthService()),
      ],
      child: MyApp(),
    ),
  );
}
```

This code:
- Loads the `.env` file with API keys
- Sets up the Provider system for managing state
- Creates both authentication services
- Starts the app

### 2. Environment Configuration (`lib/config/environment.dart`)

I put all the API keys and URLs in this file. It reads from the `.env` file but has fallback values if something is missing.

```dart
class Environment {
  static String get firebaseApiKey => 
    dotenv.env['FIREBASE_API_KEY'] ?? 'AIzaSyDrwx-cR0Q6PCalqdJ53zYH8agQe7jUGvo';
  
  static String get newMockServerUrl => 
    dotenv.env['NEW_MOCK_SERVER_URL'] ?? 'https://mock-server-firebase.onrender.com';
}
```

I did this because:
- Keeps API keys out of the source code
- Has default values for development
- Easy to change for different environments
- More secure than hardcoding keys

### 3. Firebase Authentication Service (`lib/services/firebase_rest_auth_service.dart`)

This handles the main login functionality. I used Firebase's REST API instead of their SDK because I wanted to understand exactly what's happening.

The main methods are:
- `signInWithEmail()` - User login
- `signUpWithEmail()` - User registration  
- `signOut()` - Logout
- `refreshToken()` - Refresh expired tokens

Here's how login works:
1. Send HTTP POST to Firebase's API with email/password
2. Firebase returns a JWT token if credentials are good
3. Store the token for making API calls later
4. Handle errors if login fails

The tricky part is that JWT tokens expire after 1 hour, so I had to add logic to refresh them automatically using the refresh token.

### 4. FastAPI Authentication Service (`lib/services/fastapi_auth_service.dart`)

I added this as an extra security layer. It takes the Firebase token and sends it to a FastAPI backend for verification.

The flow is:
1. User logs in with Firebase first
2. Take the Firebase JWT token and send it to FastAPI
3. FastAPI checks the token (or uses mock mode for testing)
4. Generate an additional bearer token for extra security
5. Store both tokens

This shows how you can have multiple services checking authentication, which is common in bigger applications.

### 5. Mock API Service (`lib/services/mock_api_service.dart`)

This is the most complicated part. It handles getting data from the mock server, which includes dealing with authentication, retries, and parsing responses.

What it does:
- Sends JWT tokens in the Authorization header
- Retries failed requests with increasing delays
- Handles different error codes (200, 401, 403, 500, 503)
- Parses JSON responses into usable data
- Falls back to mock data if the server is down

It fetches three types of data:
- Email messages from `/db/email/messages`
- Calendar events from `/db/calendar/events`  
- User accounts from `/accounts`

### 6. Backend Auth Test Service (`lib/services/backend_auth_test_service.dart`)

This tests whether the FastAPI backend is working properly. It sends both the Firebase JWT token and the FastAPI API key to make sure everything is connected.

What it does:
- Gets the current Firebase JWT token
- Sends a test request to the FastAPI backend
- Includes both Authorization and X-API-Key headers
- Shows whether it worked or failed
- Helps debug when authentication isn't working

### 7. Authentication Screen (`lib/screens/auth_screen.dart`)

This is the login page where users enter their email and password.

It has:
- Email and password input fields
- A toggle to choose between Firebase-only or Firebase + FastAPI
- Loading spinner while logging in
- Error messages if something goes wrong
- Form validation

The screen can handle two different login flows:
1. Firebase-only: Just use Firebase for authentication
2. Firebase + FastAPI: Use Firebase first, then verify with FastAPI

### 8. Home Screen (`lib/screens/home_screen.dart`)

This is the main page users see after logging in. It shows their info and lets them test the data fetching.

It has:
- Welcome message with user details
- Authentication status info
- Button to test backend authorization
- Buttons to test fetching emails, calendar events, and user accounts

This screen shows how to:
- Display user info from the authentication services
- Test if the backend is working
- Fetch and show real data from the mock server
- Handle loading states and show errors

### 9. UI Components (`lib/widgets/`)

I put reusable UI pieces in the widgets folder:

- `welcome_card.dart`: Shows welcome message and user email
- `auth_status_card.dart`: Displays authentication status and token info

I made these separate components so I could reuse them in different screens without duplicating code.

## How It All Works Together

### Authentication Flow

Here's what happens when someone logs in:

1. User opens the app and sees the login screen
2. User types in email and password
3. App sends this to Firebase's API
4. Firebase sends back a JWT token if the credentials are good
5. If the FastAPI toggle is on, the token gets sent to FastAPI for extra verification
6. FastAPI sends back another bearer token
7. User gets redirected to the home screen
8. Now the app can make requests to the mock server using the tokens

### Data Fetching Flow

When someone clicks "Test Email Messages":

1. App gets the current JWT token from the authentication service
2. Makes an HTTP GET request to the mock server with the token in the Authorization header
3. Mock server checks the token and sends back data
4. App parses the JSON and shows it in the UI
5. If the request fails, it retries with increasing delays

### State Management

I used Flutter's Provider pattern to manage state:

- `FirebaseRestAuthService`: Keeps track of Firebase authentication
- `FastApiAuthService`: Keeps track of FastAPI verification
- UI components listen to these services and update automatically
- When authentication changes, the UI updates everywhere

## Configuration Files

### Frontend Environment (`.env` in `flutter_frontend/`)

I put all the API keys and URLs in this file:

```env
# Firebase Configuration
FIREBASE_API_KEY=AIzaSyDrwx-cR0Q6PCalqdJ53zYH8agQe7jUGvo
FIREBASE_AUTH_DOMAIN=infinity-link-878fe.firebaseapp.com
FIREBASE_PROJECT_ID=infinity-link-878fe
FIREBASE_STORAGE_BUCKET=infinity-link-878fe.appspot.com
FIREBASE_MESSAGING_SENDER_ID=123456789
FIREBASE_APP_ID=1:123456789:web:abcdef123456

# Mock Server URLs
NEW_MOCK_SERVER_URL=https://mock-server-firebase.onrender.com
OLD_MOCK_SERVER_URL=https://mock-server-6yyu.onrender.com

# FastAPI Configuration
FASTAPI_API_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Development Settings
DEBUG_MODE=true
```

### Backend Environment (`.env` in `fastapi_backend/`)

```env
MOCK_API_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

## Dependencies

### Required Dependencies (`pubspec.yaml`)

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0              # For making HTTP requests
  provider: ^6.1.1          # For state management
  flutter_dotenv: ^5.2.1    # For loading environment variables
  cupertino_icons: ^1.0.2   # For icons
```

### How to Set It Up

```bash
# Go to the Flutter project folder
cd flutter_frontend

# Install the dependencies
flutter pub get

# Create the environment file
touch .env

# Run the app
flutter run -d chrome --web-port=8080
```

## What I Learned While Building This

### Getting Started

I started with a basic Flutter web project and tried to set up Firebase authentication. The tricky part was figuring out how Firebase's REST API works compared to their SDK.

Using the REST API gives you more control but means you have to handle HTTP requests yourself. I had to:
- Learn Firebase's API endpoints
- Handle different response formats
- Manage authentication tokens manually
- Figure out proper error handling

### Token Problems

JWT tokens expire after 1 hour, which was annoying when users stayed logged in longer. I fixed this by:
- Parsing JWT tokens to check when they expire
- Adding automatic token refresh
- Adding retry logic for failed requests
- Storing refresh tokens securely

### Server Issues

The mock server sometimes returned 503 errors when it was overloaded. I added:
- Retry logic with increasing delays
- Fallback data when the server is down
- Better error messages for users

### Data Parsing Headaches

Different API endpoints returned data in different formats. I had to create:
- Flexible parsing functions that handle different formats
- Fallback values for missing data
- Data validation to prevent crashes
- Consistent UI display no matter what the API sends

## How to Run This

### What You Need

- Flutter SDK (latest version)
- Chrome browser
- Firebase project with Authentication enabled

### Setup Steps

1. **Get the code**
   ```bash
   git clone <repository-url>
   cd my_firebase_app
   ```

2. **Install dependencies**
   ```bash
   cd flutter_frontend
   flutter pub get
   ```

3. **Create environment file**
   ```bash
   touch .env
   ```
   Add the environment variables I listed above.

4. **Run the app**
   ```bash
   flutter run -d chrome --web-port=8080
   ```

### Testing It Out

1. **Try logging in**
   - Email: `zain01gul@gmail.com`
   - Password: `your_password`
   - Try both authentication methods
   - Check the console to see JWT tokens being generated

2. **Test data fetching**
   - Click "Test Email Messages" to get 50 email items
   - Click "Test Calendar Events" to get 50 calendar items
   - Click "Test User Accounts" to get 10 user accounts
   - See if the data shows up correctly

3. **Test backend authorization**
   - Click "Test Auth with API Key" to test FastAPI integration
   - Check console for 200 response
   - Make sure both Firebase JWT and FastAPI API key work

## Things to Consider for Production

### Security Stuff

- Environment variables keep sensitive data safe
- JWT tokens are stored in memory (not localStorage)
- HTTPS is used for all API calls
- CORS is configured properly
- No sensitive data is hardcoded

### Performance Stuff

- Retry logic prevents unnecessary requests
- Token caching reduces API calls
- Lazy loading for large data sets
- Proper widget lifecycle management

### Error Handling

- Network timeouts are handled gracefully
- Server errors trigger retry logic
- Authentication failures show clear messages
- Data parsing errors don't crash the app

## What You Can Learn From This

### Authentication Patterns

- How JWT tokens work and expire
- Multi-service authentication flows
- Token refresh and expiration handling
- Secure token storage and transmission

### API Integration

- How to set up HTTP headers properly
- How to handle different status codes
- Retry logic and error recovery
- Data transformation and parsing

### Flutter Web Development

- Provider pattern for state management
- Material Design component usage
- Responsive layout design
- Environment variable configuration

### Security Implementation

- Environment variable protection
- Secure token handling
- CORS configuration
- HTTPS enforcement


## Wrapping Up

This project shows how to build a complete authentication and data integration system using Flutter, Firebase, and FastAPI. The combination creates a solid foundation for real applications.

The file structure, error handling, and security measures make this a good reference for learning modern web development patterns. Whether you're building a simple prototype or something bigger, the patterns here give you a solid starting point.

This serves as both a learning resource and a practical guide, showing how to handle real challenges like token management, network reliability, and data parsing in a working application.

---

Built with Flutter, Firebase, and FastAPI - A complete authentication and data integration demonstration.