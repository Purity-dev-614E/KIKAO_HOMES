import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/authProvider.dart';
import '../../core/constants/landing_theme.dart';
import '../../widgets/common_background.dart';

class SetPasswordScreen extends StatefulWidget {
  const SetPasswordScreen({super.key});

  @override
  State<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
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
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _setPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.updatePassword(
        email: ModalRoute.of(context)!.settings.arguments as String,
        password: _passwordController.text,
      );
      
      if (!mounted) return;
      
      setState(() {
        _successMessage = 'Password updated successfully';
      });
      
      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Success'),
          content: const Text('Your password has been updated successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Pop back to login screen
              },
              child: Text(
                'OK',
                style: TextStyle(color: LandingTheme.primaryColor),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _errorMessage = 'Failed to update password: ${e.toString()}';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
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
                                    Icons.lock_reset,
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
                                        'Set New Password',
                                        style: LandingTheme.headingStyle(),
                                      ),
                                    ),
                                    Text(
                                      'Create a secure password',
                                      style: LandingTheme.subheadingStyle(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            _buildPasswordField(
                              'Password',
                              _passwordController,
                              _obscurePassword,
                              () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildPasswordField(
                              'Confirm Password',
                              _confirmPasswordController,
                              _obscureConfirmPassword,
                              () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            if (_errorMessage != null)
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline, color: Colors.red),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else if (_successMessage != null)
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle_outline, color: Colors.green),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _successMessage!,
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
                                    onPressed: _isLoading ? null : _setPassword,
                                    style: LandingTheme.primaryButtonStyle(isHovered: _isButtonHovered),
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text(
                                            'Set Password',
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
                            Center(
                              child: TextButton.icon(
                                icon: const Icon(Icons.arrow_back, size: 16),
                                label: const Text('Back to Login'),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                ),
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
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    bool obscureText,
    VoidCallback onVisibilityChanged,
  ) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.black),
      decoration: LandingTheme.inputDecoration(
        label,
        hint: label,
        prefixIcon: Icon(Icons.lock, color: LandingTheme.accentColor),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility : Icons.visibility_off,
            color: LandingTheme.accentColor,
          ),
          onPressed: onVisibilityChanged,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        if (label == 'Confirm Password' && value != _passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }
}
