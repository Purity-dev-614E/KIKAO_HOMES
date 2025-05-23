import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/models/visit_sessions.dart';
import '../../core/providers/visit_provider.dart';
import 'package:flutter/services.dart';
import 'waiting_screen.dart';

class VisitorRegistrationScreen extends StatefulWidget {
  const VisitorRegistrationScreen({super.key});

  @override
  State<VisitorRegistrationScreen> createState() => _VisitorRegistrationScreenState();
}

class _VisitorRegistrationScreenState extends State<VisitorRegistrationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nationalIdController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _unitNumberController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _nationalIdController.dispose();
    _phoneController.dispose();
    _unitNumberController.dispose();
    super.dispose();
  }
  Future<void> _registerVisit() async {
    if (_nameController.text.isEmpty ||
        _nationalIdController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _unitNumberController.text.isEmpty) {
      log('Validation failed: One or more fields are empty');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Visitor registration is always anonymous - no authentication needed
      log('Processing anonymous visitor registration');

      log('Getting VisitProvider from context');
      final visitProvider = Provider.of<VisitProvider>(context, listen: false);
      log('VisitProvider obtained successfully');

      final visit = VisitSessions(
        VisitorName: _nameController.text,
        visitorPhone: _phoneController.text,
        NationalID: _nationalIdController.text,
        unitNumber: _unitNumberController.text.toUpperCase(), // Ensure unit number is uppercase
        status: 'pending',
        checkInTime: null,
        checkOutTime: null,
      );

      log('Created visit object: ${visit.toJson()}');
      log('Attempting to create visit session...');

      try {
        // Create the visit session and get the result
        final createdVisit = await visitProvider.createVisitSession(visit);
        log('Visit session created successfully in provider');

        if (!mounted) return;

        log('Visit registered successfully');
        log('Sending push notification');
        
        try {
          // Use the ID from the created visit
          final visitId = createdVisit.id;
          
          try {
            // Try to send notification with minimal required data
            await visitProvider.sendPushNotification(
              unitNumber: _unitNumberController.text.toUpperCase(),
              message: 'A visitor has been registered for your unit.',
              type: 'visitor',
              data: {
                'visitor_id': visitId,
                'visitor_name': _nameController.text,
                'visitor_phone': _phoneController.text,
                'unit_number': _unitNumberController.text.toUpperCase(),
                'status': 'pending',
              },
            );
            log('Push notification sent successfully');
          } catch (notificationError) {
            log('Error sending push notification: $notificationError');
            // Continue even if notification fails - the visit is still registered
          }
          
          // Try direct API call to send push notification if the provider method fails
          try {
            final supabase = Supabase.instance.client;
            final response = await supabase.functions.invoke(
              'sendpushnotification',
              body: {
                'unitNumber': _unitNumberController.text.toUpperCase(),
                'message': 'A visitor has been registered for your unit.',
                'type': 'visitor',
                'data': {
                  'visitor_id': visitId,
                  'visitor_name': _nameController.text,
                  'visitor_phone': _phoneController.text,
                  'unit_number': _unitNumberController.text.toUpperCase(),
                  'status': 'pending',
                }
              },
            );
            log('Direct push notification sent successfully: ${response.data}');
          } catch (directNotificationError) {
            log('Error sending direct push notification: $directNotificationError');
            // Continue even if direct notification fails
          }
        } catch (notificationError) {
          log('Error in notification block: $notificationError');
          // Continue even if all notification attempts fail
        }

        if (!mounted) return;
        
        // Show waiting screen
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const WaitingScreen(
              message: 'Waiting for resident approval...',
              isSuccess: false,
            ),
          ),
        );
      } catch (serviceError) {
        log('Error in createVisitSession: $serviceError');
        
        // Show specific error message for "Resident not found"
        if (serviceError.toString().contains("Resident not found")) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No resident found for this unit. Please check the unit number.'),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          rethrow;
        }
      }
    } catch (e) {
      if (!mounted) return;

      log('Error during registration: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      log('Registration process completed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: colorScheme.primary),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 16),
              Text(
                'Register Visitor',
                style: theme.textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Please fill in the visitor details below',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 32),
              _buildTextField('Full Name', Icons.person_outline, _nameController, textInputAction: TextInputAction.next),
              const SizedBox(height: 20),
              _buildTextField('National ID', Icons.credit_card_outlined, _nationalIdController, 
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),
              _buildTextField('Phone Number', Icons.phone_outlined, _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),
              _buildTextField('Unit Number', Icons.home_outlined, _unitNumberController,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _registerVisit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Register Visitor',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    IconData icon,
    TextEditingController controller, {
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: theme.colorScheme.primary),
            hintText: 'Enter $label',
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ),
      ],
    );
  }
}
