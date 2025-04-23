import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/home_screen.dart';
import 'screens/text_editor_screen.dart';
import 'screens/simple_encryption_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'services/auth_service.dart';

// Create a global key for the navigator state to show error dialogs
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final authService = AuthService();

// Safe navigation method to prevent concurrent navigation operations
void navigateSafely(
  BuildContext context,
  String routeName, {
  Object? arguments,
}) {
  // Use Future.microtask to ensure navigation happens after the current build cycle
  Future.microtask(() {
    if (context.mounted) {
      Navigator.of(context).pushNamed(routeName, arguments: arguments);
    }
  });
}

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Try to initialize Firebase, but continue without it if it fails
  FirebaseApp? app;
  try {
    // Try to initialize Firebase with dummy options
    // (replace these with your actual Firebase options)
    app = await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyBS58R4pOwC6wXbo_-g7raHmTYO2pxdwDo',
        appId: '1:789396507044:android:61920ec95367f183789931',
        messagingSenderId: '789396507044',
        projectId: 'madminiproject-b5803',
        // The following are optional but often required
        storageBucket: 'madminiproject-b5803.firebasestorage.app',
      ),
    );
    print("Firebase initialized successfully: ${app.name}");
  } catch (e) {
    print("Failed to initialize Firebase: $e");
    // Continue without Firebase
  }

  // Check authentication status before showing the app
  await authService.checkAuthStatus();

  // Run the app regardless of Firebase initialization status
  runApp(MyApp(firebaseInitialized: app != null));
}

class MyApp extends StatelessWidget {
  final bool firebaseInitialized;

  const MyApp({Key? key, this.firebaseInitialized = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Encrypted Text App',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6200EE),
          brightness: Brightness.light,
          secondary: const Color(0xFF03DAC6),
          tertiary: const Color(0xFFFF8A65),
        ),
        useMaterial3: true,
        fontFamily: 'Poppins',
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6200EE), width: 2),
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF6200EE),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFBB86FC),
          brightness: Brightness.dark,
          secondary: const Color(0xFF03DAC6),
          tertiary: const Color(0xFFFF8A65),
          background: const Color(0xFF121212),
          surface: const Color(0xFF1E1E1E),
        ),
        useMaterial3: true,
        fontFamily: 'Poppins',
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2A2A2A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFBB86FC), width: 2),
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1F1F),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthCheckScreen(),
        '/simple_encryption': (context) => const SimpleEncryptionScreen(),
        '/login':
            (context) => LoginScreen(firebaseInitialized: firebaseInitialized),
        '/signup':
            (context) => SignupScreen(firebaseInitialized: firebaseInitialized),
      },
      onGenerateRoute: (settings) {
        // Protected routes that require authentication
        List<String> protectedRoutes = [
          '/home',
          '/editor',
          '/simple_encryption',
        ];

        // Check if route requires authentication
        if (protectedRoutes.contains(settings.name) &&
            !authService.isAuthenticated) {
          // Redirect to login if not authenticated
          return MaterialPageRoute(
            builder:
                (context) =>
                    LoginScreen(firebaseInitialized: firebaseInitialized),
            settings: RouteSettings(name: '/login'),
          );
        }

        // If Firebase isn't initialized and someone tries to access auth routes,
        // redirect to the encryption screen with a safer approach
        if (!firebaseInitialized &&
            (settings.name == '/login' || settings.name == '/signup')) {
          return MaterialPageRoute(
            builder: (context) => const SimpleEncryptionScreen(),
            settings: settings,
          );
        }

        // Process normal route generation
        if (settings.name == '/home') {
          const password = 'default_password';
          return MaterialPageRoute(
            builder: (context) => HomeScreen(password: password),
            settings: settings,
          );
        } else if (settings.name == '/editor') {
          // Handle null arguments case to prevent assertion errors
          final args = settings.arguments as Map<String, dynamic>?;
          final password =
              args != null
                  ? args['password'] ?? 'default_password'
                  : 'default_password';
          final text = args != null ? args['text'] : null;

          return MaterialPageRoute(
            builder:
                (context) => TextEditorScreen(text: text, password: password),
            settings: settings,
          );
        }

        // Default fallback
        return MaterialPageRoute(
          builder: (context) => const SimpleEncryptionScreen(),
          settings: settings,
        );
      },
    );
  }
}

// AuthCheck screen to verify authentication on app start
class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({Key? key}) : super(key: key);

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Small delay to prevent navigation during build
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      if (authService.isAuthenticated) {
        navigateSafely(context, '/simple_encryption');
      } else {
        navigateSafely(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
