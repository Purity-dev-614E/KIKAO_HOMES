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
import 'core/constants/theme_constants.dart';
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
          primaryColor: const Color(0xFF4A6B5D),
          scaffoldBackgroundColor: const Color(0xFFE5E0D8),
          colorScheme: ColorScheme.light(
            primary: const Color(0xFF4A6B5D),
            secondary: const Color(0xFFE5E0D8),
            tertiary: const Color(0xFFCC7357),
            onPrimary: Colors.white,
            onSecondary: const Color(0xFF2D2D2D),
            onTertiary: Colors.white,
            background: const Color(0xFFE5E0D8),
            surface: Colors.white,
          ),
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A6B5D),
            ),
            displayMedium: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A6B5D),
            ),
            bodyLarge: TextStyle(
              fontSize: 16,
              color: Color(0xFF2D2D2D),
            ),
            bodyMedium: TextStyle(
              fontSize: 14,
              color: Color(0xFF2D2D2D),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCC7357),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppTheme.secondaryColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppTheme.secondaryColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        initialRoute: '/visitors/registration',
        routes: {
          '/': (context) => const LandingScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/set_password': (context) => const SetPasswordScreen(),
          '/password_reset': (context) => const PasswordResetScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/security/dashboard': (context) => const SecurityDashboardScreen(),


          '/admin_dashboard': (context) => const DashboardScreen(),
          '/admin/visitors': (context) => const VisitorsScreen(),
          '/admin/residents': (context) => const ResidentsScreen(),
          '/admin/settings': (context) => const SettingsScreen(),
          '/user_management': (context) => const UserManagementScreen(),
          '/residents': (context) => const ResidentsScreen(),
          '/visitors': (context) => const VisitorsScreen(),
          '/admin/qr-management': (context) => const QRManagementScreen(),

          '/visitor_history': (context) => const VisitorHistoryScreen(),
          '/visitor_approval': (context) {
            // Get the visitor data from the route arguments
            final Map<String, dynamic>? args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
            if (args == null || !args.containsKey('visitorData')) {
              return const Scaffold(
                body: Center(child: Text('Visitor data is required')),
              );
            }
            return VisitorApproval(visitorData: args['visitorData']);
          },


          '/visitors/registration': (context) => const VisitorRegistrationScreen(),
          '/visitors/checkout': (context) => const VisitorCheckoutScreen(),

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
