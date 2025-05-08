import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kikao_homes/screens/admin/settings.dart';
import 'package:kikao_homes/screens/admin/user_management.dart';
import 'package:kikao_homes/screens/resident/visitor_approval.dart';
import 'package:provider/provider.dart';
import 'package:kikao_homes/screens/auth/login_screen.dart';
import 'package:kikao_homes/screens/auth/password_reset.dart';
import 'package:kikao_homes/screens/auth/register_screen.dart';
import 'package:kikao_homes/screens/auth/set_password.dart';
import 'package:kikao_homes/screens/landing_screen.dart';
import 'package:kikao_homes/screens/profile.dart';
import 'package:kikao_homes/screens/resident/visitor_history.dart';
import 'package:kikao_homes/screens/security/security_dashboard_screen.dart';
import 'package:kikao_homes/screens/visitor/visitor_registration_screen.dart';
import 'package:kikao_homes/screens/visitor/visitor_checkout_screen.dart';
import 'package:kikao_homes/screens/admin/dashboard_screen.dart';
import 'package:kikao_homes/screens/admin/residents_screen.dart';
import 'package:kikao_homes/screens/admin/visitors_screen.dart';
import 'package:kikao_homes/screens/admin/qr_management_screen.dart';
import 'package:kikao_homes/supabase_env.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kikao_homes/firebase_options.dart';
import 'core/services/notification_service.dart';
import 'core/providers/authProvider.dart';
import 'core/providers/settings_provider.dart';
import 'core/providers/visit_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase initialized successfully");
  } catch (e) {
    print("Error initializing Firebase: $e");
    // Continue without Firebase if there's an error
  }

  await Supabase.initialize(
    url: SupabaseEnv.supabaseUrl ,
    anonKey: SupabaseEnv.supabaseKey,
  );

  try {
    await NotificationService.initialize();
    print("Notification service initialized successfully");
  } catch (e) {
    print("Error initializing notification service: $e");
    // Continue without notifications if there's an error
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => VisitProvider()),
      ],
      child: MaterialApp(
        title: 'Kikao Homes',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          primaryColor: const Color(0xFF2C5E5B),
          scaffoldBackgroundColor: const Color(0xFFF8F9FA),
          colorScheme: ColorScheme.light(
            primary: const Color(0xFF2C5E5B),
            primaryContainer: const Color(0xFF3D7A78),
            secondary: const Color(0xFFF4A261),
            tertiary: const Color(0xFFE76F51),
            surface: Colors.white,
            background: const Color(0xFFF8F9FA),
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: const Color(0xFF212529),
            onBackground: const Color(0xFF212529),
            error: const Color(0xFFE76F51),
            onError: Colors.white,
            brightness: Brightness.light,
          ),
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Color(0xFF212529),
              letterSpacing: -0.5,
            ),
            displayMedium: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2C5E5B),
              letterSpacing: -0.3,
            ),
            titleLarge: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C5E5B),
            ),
            bodyLarge: TextStyle(
              fontSize: 16,
              color: Color(0xFF495057),
              height: 1.6,
            ),
            bodyMedium: TextStyle(
              fontSize: 14,
              color: Color(0xFF6C757D),
              height: 1.5,
            ),
            labelLarge: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2C5E5B), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE76F51), width: 1.5),
            ),
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
            labelStyle: const TextStyle(color: Color(0xFF6C757D)),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2C5E5B),
              foregroundColor: Colors.white,
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
            shadowColor: Colors.black.withOpacity(0.1),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              color: Color(0xFF212529),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            iconTheme: const IconThemeData(color: Color(0xFF2C5E5B)),
          ),
        ),
        home: const AppRouter(),
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(builder: (_) => const LandingScreen());
            case '/login':
              return MaterialPageRoute(builder: (_) => const LoginScreen());
            case '/register':
              return MaterialPageRoute(builder: (_) => const RegisterScreen());
            case '/set_password':
              return MaterialPageRoute(builder: (_) => const SetPasswordScreen());
            case '/password_reset':
              return MaterialPageRoute(builder: (_) => const PasswordResetScreen());
            case '/profile':
              return MaterialPageRoute(builder: (_) => const ProfileScreen());
            case '/security/dashboard':
              return MaterialPageRoute(builder: (_) => const SecurityDashboardScreen());
            case '/admin_dashboard':
              return MaterialPageRoute(builder: (_) => const DashboardScreen());
            case '/admin/visitors':
              return MaterialPageRoute(builder: (_) => const VisitorsScreen());
            case '/admin/residents':
              return MaterialPageRoute(builder: (_) => const ResidentsScreen());
            case '/admin/settings':
              return MaterialPageRoute(builder: (_) => const SettingsScreen());
            case '/user_management':
              return MaterialPageRoute(builder: (_) => const UserManagementScreen());
            case '/admin/qr-management':
              return MaterialPageRoute(builder: (_) => const QRManagementScreen());
            case '/visitor_history':
              return MaterialPageRoute(builder: (_) => const VisitorHistoryScreen());
            case '/visitor_approval':
              final args = settings.arguments as Map<String, dynamic>?;
              if (args == null || !args.containsKey('visitorData')) {
                return MaterialPageRoute(
                  builder: (_) => const Scaffold(
                    body: Center(child: Text('Visitor data is required')),
                  ),
                );
              }
              return MaterialPageRoute(
                builder: (_) => VisitorApproval(visitorData: args['visitorData']),
              );
            case '/visitors/registration':
              return MaterialPageRoute(builder: (_) => const VisitorRegistrationScreen());
            case '/visitors/checkout':
              return MaterialPageRoute(builder: (_) => const VisitorCheckoutScreen());
            default:
              return MaterialPageRoute(builder: (_) => const Scaffold(
                body: Center(child: Text('Page not found')),
              ));
          }
        },
      ),
    );
  }
}

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    if (authProvider.user != null) {
      print('user: ${authProvider.user}');
      final role = authProvider.user!['role'];
      
      switch (role) {
        case 'admin':
          return const DashboardScreen();
        case 'security':
          return const SecurityDashboardScreen();
        case 'resident':
          return const VisitorHistoryScreen(); // Using visitor history as resident dashboard
        default:
          return const LoginScreen();
      }
    }
    
    return const LandingScreen();
  }
}
