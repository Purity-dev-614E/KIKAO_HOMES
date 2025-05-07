import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:kikao_homes/core/models/profiles.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  @override
  void initState() {
    super.initState();
  }

 final String? userId = Supabase.instance.client.auth.currentUser?.id;

Future<Profiles?> getUserProfile() async {
  if (userId == null) {
    log('User ID is null');
    throw Exception('User ID is null');
  } else {
    log(userId!);
  }

  try {
    final response = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', userId!)
        .maybeSingle(); // returns null instead of throwing if not found

    if (response == null) {
      log('No profile found for userId: $userId');
      return null; // or throw, depending on your use case
    }

    return Profiles.fromJson(response);
  } catch (e) {
    log(e.toString());
    throw Exception('Failed to fetch user profile: $e');
  }

}
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E0D8),
      body: SafeArea(
        child: FutureBuilder<Profiles?>(
          future: getUserProfile(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data == null) {
                return const Center(child: Text('No profile data found'));
              }
              final profile = snapshot.data!;
            
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: const Color(0xFF4A6B5D),
                  expandedHeight: 200,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: const Text('Profile'),
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF4A6B5D),
                            Color(0xFFCC7357),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(60),
                              border: Border.all(
                                color: const Color(0xFF4A6B5D),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 60,
                              color: Color(0xFF4A6B5D),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          profile.fullName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A6B5D),
                          ),
                        ),
                        Text(
                          'Unit ${profile.unitNumber}',
                          style: const TextStyle(
                            color: Color(0xFF2D2D2D),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 30),
                        _buildProfileSection(
                          title: 'Personal Information',
                          items: [
                            _buildProfileItem('Phone', profile.phoneNumber),
                            _buildProfileItem('Role', profile.role),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildProfileSection(
                          title: 'Residence Details',
                          items: [
                            _buildProfileItem('Unit Number', profile.unitNumber),
                          ],
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFCC7357),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Edit Profile',
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
          ],
        );
      },
    ),
  ),
);
  }

  Widget _buildProfileSection({
    required String title,
    required List<Widget> items,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
            const SizedBox(height: 10),
            ...items,
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              color: Color(0xFF4A6B5D),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF2D2D2D),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
