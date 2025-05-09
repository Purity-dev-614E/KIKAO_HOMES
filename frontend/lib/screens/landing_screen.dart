import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../core/providers/authProvider.dart';
import '../core/providers/settings_provider.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _titleAnimation;
  late Animation<double> _subtitleAnimation;
  late Animation<double> _buttonAnimation;
  late Animation<double> _aboutAnimation;
  late List<Animation<double>> _cardAnimations;
  
  // Hover states
  bool _isButtonHovered = false;
  bool _isFabHovered = false;
  List<bool> _isCardHovered = [false, false, false];
  double _parallaxOffset = 0.0;
  
  // Particle effect variables
  final List<Map<String, dynamic>> _particles = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    
    // Initialize particles for background effect
    final random = math.Random();
    for (int i = 0; i < 30; i++) {
      _particles.add({
        'x': random.nextDouble() * 1.0,
        'y': random.nextDouble() * 1.0,
        'size': random.nextDouble() * 4 + 1,
        'speed': random.nextDouble() * 0.02 + 0.01,
        'opacity': random.nextDouble() * 0.5 + 0.1,
      });
    }

    // Setup animations with different delays
    _titleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );
    
    _subtitleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
    );
    
    _cardAnimations = List.generate(3, (index) {
      return CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          0.3 + (index * 0.1),
          0.8 + (index * 0.1),
          curve: Curves.easeOut,
        ),
      );
    });
    
    _buttonAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    );
    
    _aboutAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Design elements
  final Color _primaryColor = const Color(0xFF2A5C42);
  final Color _accentColor = const Color(0xFFF6AE2D);
  final Color _textColor = const Color(0xFF333333);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    Provider.of<SettingsProvider>(context, listen: false);

    if (authProvider.user != null) {
      final role = authProvider.user!['role'];
      switch (role) {
        case 'admin':
          Navigator.pushReplacementNamed(context, '/admin_dashboard');
          break;
        case 'security':
          Navigator.pushReplacementNamed(context, '/security/dashboard');
          break;
        case 'resident':
          Navigator.pushReplacementNamed(context, '/visitor_history');
          break;
        default:
          Navigator.pushReplacementNamed(context, '/login');
      }
      return const SizedBox.shrink();
    }

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Main content
          MouseRegion(
            onHover: (event) {
              // Calculate parallax effect based on mouse position
              setState(() {
                _parallaxOffset = (event.position.dx / MediaQuery.of(context).size.width - 0.5) * 20;
              });
            },
            child: Stack(
              children: [
                // Background Image with Gradient Overlay and Parallax Effect
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutQuad,
                  transform: Matrix4.translationValues(_parallaxOffset, 0, 0),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/house.jpg'), // Fixed image path
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Particle overlay effect
                CustomPaint(
                  size: Size.infinite,
                  painter: ParticlesPainter(_particles),
                ),

                // Content
                SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Header Section
                        _buildHeaderSection(),
                        const SizedBox(height: 40),

                        // Feature Cards
                        _buildFeatureCards(),

                        // About Section
                        _buildAboutSection(),

                        // Get Started Button
                        _buildGetStartedButton(),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Floating Action Button positioned at the bottom right
          Positioned(
            right: 16,
            bottom: 16,
            child: _buildFloatingActionButton(),
          ),
        ],
      ),
    );
  }

  // Track header icon hover state
  bool _isHeaderIconHovered = false;

  Widget _buildHeaderSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
      child: FadeTransition(
        opacity: _titleAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Transform.translate(
              offset: Offset(0, 30 * (1 - _titleAnimation.value)),
              child: Row(
                children: [
                  MouseRegion(
                    onEnter: (_) => setState(() => _isHeaderIconHovered = true),
                    onExit: (_) => setState(() => _isHeaderIconHovered = false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: EdgeInsets.all(_isHeaderIconHovered ? 16 : 12),
                      decoration: BoxDecoration(
                        color: _isHeaderIconHovered 
                            ? _accentColor.withOpacity(0.9) 
                            : _primaryColor.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(_isHeaderIconHovered ? 16 : 12),
                        boxShadow: _isHeaderIconHovered 
                            ? [
                                BoxShadow(
                                  color: _accentColor.withOpacity(0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                )
                              ] 
                            : [],
                      ),
                      child: AnimatedRotation(
                        turns: _isHeaderIconHovered ? 0.1 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: const Icon(
                          Icons.security_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(
                            colors: [Colors.white, _accentColor.withOpacity(0.8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds);
                        },
                        child: Text(
                          'Kikao Homes',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      Text(
                        'Premium Residential Management',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FadeTransition(
              opacity: _subtitleAnimation,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - _subtitleAnimation.value)),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Transforming communities through\nsmart security solutions',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          _buildAnimatedCard(
            animation: _cardAnimations[0],
            icon: Icons.verified_user_outlined,
            title: 'Military-Grade Security',
            description: 'Biometric access control with 256-bit encryption',
            color: _accentColor,
            extraContent: _buildExtraContent(
              'Our security system uses advanced biometric verification and 256-bit encryption to ensure only authorized individuals can access your community.',
              [
                'Fingerprint scanning',
                'Facial recognition',
                'Two-factor authentication'
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildAnimatedCard(
            animation: _cardAnimations[1],
            icon: Icons.people_alt_outlined,
            title: 'Resident Management',
            description: 'Centralized control for all community members',
            color: Colors.white,
            textColor: _textColor,
            extraContent: _buildExtraContent(
              'Manage all residents from a single dashboard with comprehensive tools for access control, communication, and community management.',
              [
                'Resident profiles',
                'Access permissions',
                'Community announcements'
              ],
              isDark: false,
            ),
          ),
          const SizedBox(height: 20),
          _buildAnimatedCard(
            animation: _cardAnimations[2],
            icon: Icons.notifications_active_outlined,
            title: 'Real-time Monitoring',
            description: 'Instant alerts for all security events',
            color: _primaryColor,
            extraContent: _buildExtraContent(
              'Get instant notifications about all security events in your community, allowing for immediate response to any potential issues.',
              [
                'Mobile notifications',
                'Email alerts',
                'Security staff dispatch'
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildExtraContent(String description, List<String> features, {bool isDark = true}) {
    final textColor = isDark ? Colors.white : _textColor;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Container(
          height: 1,
          color: textColor.withOpacity(0.2),
        ),
        const SizedBox(height: 16),
        Text(
          description,
          style: TextStyle(
            color: textColor.withOpacity(0.9),
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        ...features.map((feature) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(
                Icons.arrow_right_rounded, 
                color: isDark ? _accentColor : _primaryColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                feature,
                style: TextStyle(
                  color: textColor.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildAboutSection() {
    return FadeTransition(
      opacity: _aboutAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
        child: MouseRegion(
          onEnter: (_) => setState(() {}),  // Trigger rebuild for hover effects
          onExit: (_) => setState(() {}),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
              border: Border.all(
                color: _primaryColor.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      colors: [_primaryColor, _accentColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds);
                  },
                  child: Text(
                    'About Kikao Homes',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Kikao Homes is a comprehensive residential management platform designed for modern gated communities. Our system integrates cutting-edge security technology with intuitive resident management tools to create safer, smarter living environments.',
                  style: TextStyle(
                    fontSize: 16,
                    color: _textColor,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),
                _buildFeatureItem('24/7 Security Monitoring'),
                const SizedBox(height: 12),
                _buildFeatureItem('Visitor Management System'),
                const SizedBox(height: 12),
                _buildFeatureItem('Emergency Response Integration'),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildFeatureItem(String text) {
    return MouseRegion(
      onEnter: (_) => setState(() {}),
      onExit: (_) => setState(() {}),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.check_circle, color: _accentColor, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            text, 
            style: TextStyle(
              color: _textColor,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFloatingActionButton() {
    return MouseRegion(
      onEnter: (_) => setState(() => _isFabHovered = true),
      onExit: (_) => setState(() => _isFabHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutQuad,
        height: _isFabHovered ? 60 : 56,
        width: _isFabHovered ? 60 : 56,
        decoration: BoxDecoration(
          color: _isFabHovered ? _accentColor : _primaryColor,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: (_isFabHovered ? _accentColor : _primaryColor).withOpacity(0.4),
              blurRadius: _isFabHovered ? 20 : 10,
              offset: const Offset(0, 5),
              spreadRadius: _isFabHovered ? 2 : 0,
            )
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.pushNamed(context, '/login'),
            borderRadius: BorderRadius.circular(30),
            splashColor: Colors.white.withOpacity(0.2),
            child: Center(
              child: AnimatedRotation(
                turns: _isFabHovered ? 0.125 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.login_rounded,
                  color: Colors.white,
                  size: _isFabHovered ? 28 : 24,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGetStartedButton() {
    return ScaleTransition(
      scale: _buttonAnimation,
      child: FadeTransition(
        opacity: _buttonAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: MouseRegion(
            onEnter: (_) => setState(() => _isButtonHovered = true),
            onExit: (_) => setState(() => _isButtonHovered = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  colors: _isButtonHovered 
                    ? [_accentColor, _primaryColor] 
                    : [_primaryColor, _primaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isButtonHovered 
                      ? _accentColor.withOpacity(0.5) 
                      : _primaryColor.withOpacity(0.4),
                    blurRadius: _isButtonHovered ? 25 : 15,
                    offset: _isButtonHovered 
                      ? const Offset(0, 10) 
                      : const Offset(0, 6),
                    spreadRadius: _isButtonHovered ? 1 : 0,
                  )
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.pushNamed(context, '/login'),
                  borderRadius: BorderRadius.circular(15),
                  splashColor: Colors.white.withOpacity(0.2),
                  highlightColor: Colors.transparent,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      vertical: _isButtonHovered ? 20 : 18,
                      horizontal: _isButtonHovered ? 24 : 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: _isButtonHovered ? 20 : 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            color: Colors.white,
                          ),
                          child: const Text('Get Started'),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: _isButtonHovered ? 16 : 12,
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          transform: _isButtonHovered 
                            ? (Matrix4.identity()..translate(5.0)) 
                            : Matrix4.identity(),
                          child: Icon(
                            Icons.arrow_forward_rounded, 
                            size: _isButtonHovered ? 24 : 22,
                            color: Colors.white,
                          ),
                        ),
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

  Widget _buildAnimatedCard({
    required Animation<double> animation,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    Color textColor = Colors.white,
    Widget? extraContent,
  }) {
    final index = _cardAnimations.indexOf(animation);
    
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final clampedValue = animation.value.clamp(0.0, 1.0);
        return Transform.translate(
          offset: Offset(50 * (1 - clampedValue), 0),
          child: Opacity(
            opacity: clampedValue,
            child: Transform.scale(
              scale: clampedValue,
              child: MouseRegion(
                onEnter: (_) => setState(() => _isCardHovered[index] = true),
                onExit: (_) => setState(() => _isCardHovered[index] = false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  transform: _isCardHovered[index] 
                      ? (Matrix4.identity()..scale(1.05))
                      : Matrix4.identity(),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: color.withOpacity(_isCardHovered[index] ? 1.0 : 0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _isCardHovered[index] 
                            ? (_accentColor.withOpacity(0.3)) 
                            : Colors.black.withOpacity(0.2),
                        blurRadius: _isCardHovered[index] ? 30 : 20,
                        offset: _isCardHovered[index] 
                            ? const Offset(0, 15) 
                            : const Offset(0, 10),
                      )
                    ],
                    border: _isCardHovered[index] ? Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ) : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(_isCardHovered[index] ? 0.3 : 0.2),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: _isCardHovered[index] ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                )
                              ] : [],
                            ),
                            child: AnimatedRotation(
                              turns: _isCardHovered[index] ? 0.05 : 0,
                              duration: const Duration(milliseconds: 300),
                              child: Icon(
                                icon,
                                color: textColor == Colors.white ? Colors.white : _primaryColor,
                                size: 28,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 300),
                                  style: TextStyle(
                                    fontSize: _isCardHovered[index] ? 20 : 18,
                                    fontWeight: FontWeight.w700,
                                    color: textColor,
                                  ),
                                  child: Text(title),
                                ),
                                const SizedBox(height: 8),
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 300),
                                  style: TextStyle(
                                    color: textColor.withOpacity(_isCardHovered[index] ? 1.0 : 0.9),
                                    fontSize: 15,
                                    height: 1.4,
                                  ),
                                  child: Text(description),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      // Expandable content that appears on hover
                      if (extraContent != null)
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutQuad,
                          child: _isCardHovered[index] 
                              ? extraContent
                              : const SizedBox.shrink(),
                        ),
                      
                      // Learn more button that appears on hover
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutQuad,
                        child: _isCardHovered[index] ? Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  foregroundColor: textColor,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(
                                      color: textColor.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Learn More',
                                      style: TextStyle(
                                        color: textColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward,
                                      size: 16,
                                      color: textColor,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ) : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Custom painter for particle effect
class ParticlesPainter extends CustomPainter {
  final List<Map<String, dynamic>> particles;
  
  ParticlesPainter(this.particles);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    for (final particle in particles) {
      final x = particle['x'] * size.width;
      final y = particle['y'] * size.height;
      final particleSize = particle['size'];
      final opacity = particle['opacity'];
      
      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), particleSize, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}