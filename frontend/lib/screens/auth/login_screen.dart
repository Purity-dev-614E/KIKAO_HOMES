import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/providers/authProvider.dart';
import '../../core/constants/landing_theme.dart';
import '../../widgets/common_background.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isButtonHovered = false;
  
  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _formAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _formAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _login() async {
    final authProvider = AuthProvider();
    await authProvider.login(
        _emailController.text,
        _passwordController.text
    );
    
    // Check if login was successful by examining the success message
    if (authProvider.successMessage != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // Store user information or token in SharedPreferences
      await prefs.setString('userEmail', _emailController.text);
      await prefs.setBool('isLoggedIn', true);

      // Fetch user data
      final role = prefs.getString('role');
      log('role retrieved from prefs: $role');
      // Navigate to based on role
      if (role != null && role == 'admin') {
        Navigator.pushReplacementNamed(context, '/admin_dashboard');
      } else if(role != null && role == 'resident') {
        Navigator.pushReplacementNamed(context, '/visitor_history');
      } else if(role != null && role == 'security') {
        Navigator.pushReplacementNamed(context, '/security/dashboard');
      } else {
        log('Role Error: Unknown role $role');
        // Handle unknown role or show an error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unknown role')),
        );
      }
    } else if (authProvider.errorMessage != null) {
      log("Error message: ${authProvider.errorMessage}");
      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CommonBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: FadeTransition(
                  opacity: _formAnimation,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - _formAnimation.value)),
                    child: Container(
                      width: MediaQuery.of(context).size.width > 600 
                          ? 500 
                          : double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: LandingTheme.primaryColor.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.security_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ShaderMask(
                                      shaderCallback: (bounds) {
                                        return LinearGradient(
                                          colors: [Colors.white, LandingTheme.accentColor.withOpacity(0.8)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ).createShader(bounds);
                                      },
                                      child: Text(
                                        'Welcome Back',
                                        style: LandingTheme.headingStyle(),
                                      ),
                                    ),
                                    Text(
                                      'Sign in to continue',
                                      style: LandingTheme.subheadingStyle(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            _buildTextField(
                              controller: _emailController,
                              label: 'Email',
                              icon: Icons.email,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!value.contains('@')) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildPasswordField(),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/password_reset');
                                  },
                                  child: Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      color: LandingTheme.accentColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              child: MouseRegion(
                                onEnter: (_) => setState(() => _isButtonHovered = true),
                                onExit: (_) => setState(() => _isButtonHovered = false),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        _login();
                                      }
                                    },
                                    style: LandingTheme.primaryButtonStyle(isHovered: _isButtonHovered),
                                    child: const Text(
                                      'Sign In',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Don\'t have an account?',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/register');
                                  },
                                  child: Text(
                                    'Register',
                                    style: TextStyle(
                                      color: LandingTheme.accentColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
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
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required TextInputType keyboardType,
    required String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.black),
      decoration: LandingTheme.inputDecoration(
        label,
        hint: label,
        prefixIcon: Icon(icon, color: LandingTheme.accentColor),
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: const TextStyle(color: Colors.black),
      decoration: LandingTheme.inputDecoration(
        'Password',
        prefixIcon: Icon(Icons.lock, color: LandingTheme.accentColor),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
            color: LandingTheme.accentColor,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }
}
