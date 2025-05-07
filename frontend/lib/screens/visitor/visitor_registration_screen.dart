import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/models/visit_sessions.dart';
import '../../core/providers/visit_provider.dart';
import '../../core/providers/authProvider.dart';

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
      // Check if user is authenticated with Supabase
      final supabase = Supabase.instance.client;
      final session = supabase.auth.currentSession;

      if (session == null) {
        log('User is not authenticated. Creating anonymous visit.');
        // For visitor registration, we might want to allow this even without authentication
        // Or we could redirect to login
      } else {
        log('User is authenticated. Session token: ${session.accessToken.substring(0, 10)}...');
      }

      log('Getting VisitProvider from context');
      final visitProvider = Provider.of<VisitProvider>(context, listen: false);
      log('VisitProvider obtained successfully');

      final visit = VisitSessions(
        VisitorName: _nameController.text,
        visitorPhone: _phoneController.text,
        NationalID: _nationalIdController.text,
        unitNumber: _unitNumberController.text,
        status: 'pending',
        checkInTime: null,
        checkOutTime: null,
      );

      log('Created visit object: ${visit.toJson()}');
      log('Attempting to create visit session...');

      try {
        await visitProvider.createVisitSession(visit);
        log('Visit session created successfully in provider');

        if (!mounted) return;

        log('Visit registered successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Visit registered successfully')),
        );

        log('Sending push notification');
        try {
          await visitProvider.sendPushNotification(
            unitNumber: _unitNumberController.text,
            message: 'A visitor has been registered for your unit.',
          );
          log('Push notification sent successfully');
        } catch (notificationError) {
          log('Error sending push notification: $notificationError');
          // Continue even if notification fails
        }

        Navigator.of(context).pop();
      } catch (serviceError) {
        log('Error in createVisitSession: $serviceError');
        throw serviceError;
      }
    } catch (e) {
      if (!mounted) return;

      log('Error during registration: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: ${e.toString()}')),
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
    return Scaffold(
      backgroundColor: const Color(0xFFE5E0D8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Visitor Registration',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A6B5D),
                ),
              ),
              const SizedBox(height: 30),
              _buildTextField('Full Name', Icons.person, _nameController),
              const SizedBox(height: 16),
              _buildTextField('National ID', Icons.credit_card, _nationalIdController),
              const SizedBox(height: 16),
              _buildTextField('Phone Number', Icons.phone, _phoneController),
              const SizedBox(height: 16),
              _buildTextField('Unit Number', Icons.home, _unitNumberController),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _registerVisit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCC7357),
                    minimumSize: const Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please fill in $label';
          }
          return null;
        },
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: InputBorder.none,
          hintText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF4A6B5D)),
          hintStyle: const TextStyle(
            color: Color(0xFF4A6B5D),
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
