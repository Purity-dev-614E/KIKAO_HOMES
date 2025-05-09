import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/appEndpoints.dart';
import 'http_client.dart';

class AuthService{

  final _client = HttpClientWrapper();

  Future<String> createUser({
    required String email,
    required String fullName,
    required String role,
    String? unitNumber,
  }) async {
    try {
      final body = {
        'email': email,
        'full_name': fullName,
        'role': role,
        if (role == 'resident' && unitNumber != null) 'unit_number': unitNumber,
      };

      final response = await _client.post(
        AppEndpoints().adduser, // your endpoint here
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['message'] ?? 'User created successfully';
      } else {
        throw Exception('Failed to create user: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating user: $e');
    }
  }

  Future<String> updatePassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.post(
        AppEndpoints().setUserPassword, // your endpoint here
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['message'] ?? 'Password updated successfully';
      } else {
        throw Exception('Failed to update password: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating password: $e');
    }
  }

  Future<String> sendSetPasswordEmail({
    required String email,
  }) async {
    try {
      final response = await _client.post(
        AppEndpoints().sendSetPasswordEmail, // your endpoint here
        body: jsonEncode({
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['message'] ?? 'Email sent successfully';
      } else {
        throw Exception('Failed to send email: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error sending email: $e');
    }
  }

  Future<String> login({
    required String email,
    required String password,
  }) async {
    try {
      // Try using Supabase client to invoke the function
      final supabase = Supabase.instance.client;
      
      log('Attempting login with email: $email');
      
      // First approach: Try using Supabase's built-in signInWithPassword
      try {
        final authResponse = await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
        
        if (authResponse.session != null) {
          log('Login successful via Supabase auth');
          
          // Store tokens in shared preferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('accessToken', authResponse.session!.accessToken);
          await prefs.setString('refreshToken', authResponse.session!.refreshToken ?? '');
          await prefs.setString('userId', authResponse.user!.id);
          
          // Fetch user profile to get role
          try {
            // Fetch user profile from profiles table
            final profileData = await supabase
                .from('profiles')
                .select()
                .eq('id', authResponse.user!.id)
                .single();
                
            if (profileData['role'] != null) {
              await prefs.setString('role', profileData['role']);
              log('User role: ${profileData['role']}');
            } else {
              log('Role not found in profile data');
            }
          } catch (profileError) {
            log('Error fetching user profile: $profileError');
            // Continue even if profile fetch fails
          }
          
          return 'Login successful';
        }
      } catch (authError) {
        log('Supabase auth login failed: $authError');
        // Continue to the next approach if this fails
      }
      
      // Second approach: Try using Supabase functions.invoke
      try {
        final functionResponse = await supabase.functions.invoke(
          'login',
          body: {
            'email': email,
            'password': password,
          },
        );
        
        log('Function response status: ${functionResponse.status}');
        
        if (functionResponse.status == 200) {
          final data = functionResponse.data;
          
          // Store tokens in shared preferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('accessToken', data['access_token']);
          await prefs.setString('refreshToken', data['refresh_token'] ?? '');
          await prefs.setString('userId', data['AuthId']);
          
          // Try to get role from response data
          if (data['role'] != null) {
            await prefs.setString('role', data['role']);
            log('User role from function: ${data['role']}');
          } else {
            // If role is not in the response, try to fetch it from profiles table
            try {
              final profileData = await supabase
                  .from('profiles')
                  .select()
                  .eq('id', data['AuthId'])
                  .single();
                  
              if (profileData['role'] != null) {
                await prefs.setString('role', profileData['role']);
                log('User role from profile: ${profileData['role']}');
              }
            } catch (profileError) {
              log('Error fetching user profile: $profileError');
            }
          }
          
          return data['message'] ?? 'Login successful';
        } else {
          throw Exception('Function failed: ${functionResponse.status}');
        }
      } catch (functionError) {
        log('Supabase function invoke failed: $functionError');
        // Continue to the next approach if this fails
      }
      
      // Third approach: Try direct HTTP with minimal configuration
      final response = await http.post(
        Uri.parse(AppEndpoints().login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      
      log('HTTP response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Store tokens in shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', data['access_token']);
        await prefs.setString('refreshToken', data['refresh_token'] ?? '');
        await prefs.setString('userId', data['AuthId']);
        
        // Try to get role from response data
        if (data['role'] != null) {
          await prefs.setString('role', data['role']);
          log('User role from HTTP: ${data['role']}');
        } else {
          // If role is not in the response, try to fetch it from profiles table
          try {
            final profileData = await supabase
                .from('profiles')
                .select()
                .eq('id', data['AuthId'])
                .single();
                
            if (profileData['role'] != null) {
              await prefs.setString('role', profileData['role']);
              log('User role from profile: ${profileData['role']}');
            }
          } catch (profileError) {
            log('Error fetching user profile: $profileError');
          }
        }
        
        return data['message'] ?? 'Login successful';
      } else {
        throw Exception('HTTP request failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      log('Error during login: $e');
      throw Exception('Error logging in: $e');
    }
  }

  Future<String> adminSignup({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.post(
        AppEndpoints().adminSignup, // your endpoint here
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      log('Admin Signup response: ${response.statusCode} \n ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['message'] ?? 'Admin signup successful';
      } else {
        throw Exception('Failed to sign up admin: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error signing up admin: $e');
    }
  }

  Future<String> securityLogin({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.post(
        AppEndpoints().securityLogin, // your endpoint here
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      log('Security Login response: ${response.statusCode} \n ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['message'] ?? 'Security login successful';
      } else {
        throw Exception('Failed to login security: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error logging in security: $e');
    }
  }

  Future<String> securityLogout() async {
    try {
      final response = await _client.post(
        AppEndpoints().securityLogout, // your endpoint here
      );
      log('Security Logout response: ${response.statusCode} \n ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['message'] ?? 'Security logout successful';
      } else {
        throw Exception('Failed to logout security: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error logging out security: $e');
    }
  }
  
  Future<Map<String,dynamic>> fetchUserById() async {
    try {
      final response = await _client.get(AppEndpoints().fetchUserById);

      log('fetch user by id: ${response.statusCode}\n${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('role', data["role"]);
        return data;
      } else {
        throw Exception("failed to get user");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getProfilesByRole(String role) async {
    final response = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('role', role);

    log('get profiles by role: ${response.length}');

    return List<Map<String, dynamic>>.from(response);
  }
}