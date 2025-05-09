import 'package:flutter/material.dart';
import '../../core/constants/landing_theme.dart';
import '../../widgets/common_background.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
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
                                    Icons.person_add_rounded,
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
                                        'Create Account',
                                        style: LandingTheme.headingStyle(),
                                      ),
                                    ),
                                    Text(
                                      'Join Kikao Homes community',
                                      style: LandingTheme.subheadingStyle(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            _buildTextField(
                              controller: _nameController,
                              label: 'Full Name',
                              icon: Icons.person,
                              keyboardType: TextInputType.name,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your full name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
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
                            _buildPasswordField(
                              controller: _passwordController,
                              label: 'Password',
                              obscureText: _obscurePassword,
                              togglePassword: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildPasswordField(
                              controller: _confirmPasswordController,
                              label: 'Confirm Password',
                              obscureText: _obscureConfirmPassword,
                              togglePassword: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
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
                                        // TODO: Implement registration logic
                                      }
                                    },
                                    style: LandingTheme.primaryButtonStyle(isHovered: _isButtonHovered),
                                    child: const Text(
                                      'Create Account',
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
                                  'Already have an account?',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    'Sign In',
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback togglePassword,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.black),
      decoration: LandingTheme.inputDecoration(
        label,
        prefixIcon: Icon(Icons.lock, color: LandingTheme.accentColor),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility : Icons.visibility_off,
            color: LandingTheme.accentColor,
          ),
          onPressed: togglePassword,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        if (label == 'Confirm Password' && 
            value != _passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }
}
