import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/authProvider.dart';
import '../core/providers/settings_provider.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _titleAnimation;
  late Animation<double> _subtitleAnimation;
  late Animation<double> _buttonAnimation;
  final List<Animation<double>> _cardAnimations = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Title animation
    _titleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    // Subtitle animation
    _subtitleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
      ),
    );

    // Card animations
    for (var i = 0; i < 3; i++) {
      _cardAnimations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(0.3 + (i * 0.15), 0.8 + (i * 0.1), curve: Curves.easeOutBack),
          ),
        ),
      );
    }

    // Button animation
    _buttonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOutBack),
      ),
    );

    // Start the animation sequence
    _controller.forward();
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // Initialize settings provider for potential future use
    Provider.of<SettingsProvider>(context, listen: false);

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
              FadeTransition(
                opacity: _titleAnimation,
                child: Transform.translate(
                  offset: Offset(0, 30 * (1 - _titleAnimation.value)),
                  child: const Text(
                    'Welcome to Kikao Homes',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A6B5D),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              FadeTransition(
                opacity: _subtitleAnimation,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - _subtitleAnimation.value)),
                  child: const Text(
                    'Secure and Modern Residential Management',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Column(
                    children: [
                      _buildAnimatedCard(
                        animation: _cardAnimations[0],
                        icon: Icons.security,
                        title: 'Secure Access',
                        description: 'Manage visitor access with QR codes and real-time notifications',
                      ),
                      const SizedBox(height: 20),
                      _buildAnimatedCard(
                        animation: _cardAnimations[1],
                        icon: Icons.home,
                        title: 'Resident Management',
                        description: 'Easily manage resident information and access rights',
                      ),
                      const SizedBox(height: 20),
                      _buildAnimatedCard(
                        animation: _cardAnimations[2],
                        icon: Icons.notifications,
                        title: 'Real-time Updates',
                        description: 'Get instant notifications about visitor arrivals and departures',
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 40),
              ScaleTransition(
                scale: _buttonAnimation,
                child: FadeTransition(
                  opacity: _buttonAnimation,
                  child: SizedBox(
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
                        elevation: 4,
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
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedCard({
    required Animation<double> animation,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(50 * (1 - animation.value), 0),
          child: Opacity(
            opacity: animation.value,
            child: _buildFeatureCard(
              icon: icon,
              title: title,
              description: description,
            ),
          ),
        );
      },
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
