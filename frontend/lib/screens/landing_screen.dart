import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/authProvider.dart';
import '../core/providers/settings_provider.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

    // Check if user is logged in
    if (authProvider.user != null) {
      final role = authProvider.user!['role'];
      
      // Navigate based on role
      switch (role) {
        case 'admin':
          Navigator.pushReplacementNamed(context, '/admin/dashboard');
          break;
        case 'security':
          Navigator.pushReplacementNamed(context, '/security_dashboard');
          break;
        case 'resident':
          Navigator.pushReplacementNamed(context, '/resident/dashboard');
          break;
        default:
          Navigator.pushReplacementNamed(context, '/auth/login');
      }
      return const SizedBox.shrink(); // Return empty widget since we're navigating away
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE5E0D8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              const SizedBox(height: 40),
              const Text(
                'Welcome to Kikao Homes',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A6B5D),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Secure and Modern Residential Management',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 40),
              _buildFeatureCard(
                icon: Icons.security,
                title: 'Secure Access',
                description: 'Manage visitor access with QR codes and real-time notifications',
              ),
              const SizedBox(height: 20),
              _buildFeatureCard(
                icon: Icons.home,
                title: 'Resident Management',
                description: 'Easily manage resident information and access rights',
              ),
              const SizedBox(height: 20),
              _buildFeatureCard(
                icon: Icons.notifications,
                title: 'Real-time Updates',
                description: 'Get instant notifications about visitor arrivals and departures',
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCC7357),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFCC7357),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A6B5D),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
