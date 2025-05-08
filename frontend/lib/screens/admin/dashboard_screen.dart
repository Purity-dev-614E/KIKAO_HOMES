import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

Future<int> getAllResidents() async {
  final response = await Supabase.instance.client
      .from('profiles')
      .select()
      .eq('role', 'resident');

  return (response as List).length;
}

Future<int> getAllVisitors() async {
  final response = await Supabase.instance.client
      .from('visit_sessions')
      .select();

  return (response as List).length;
}

Future<int> getAllSecurity() async {
  final response = await Supabase.instance.client
      .from('profiles')
      .select()
      .eq('role', 'security');
  return (response as List).length;
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _residentCount = 0;
  int _visitorCount = 0;
  int _securityCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    try {
      final residents = await getAllResidents();
      final visitors = await getAllVisitors();
      final security = await getAllSecurity();
      
      setState(() {
        _residentCount = residents;
        _visitorCount = visitors;
        _securityCount = security;
      });
    } catch (e) {
      // Handle error
      print('Error loading counts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E0D8),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings),
            label: 'Manage Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/user_management');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/admin/settings');
          }
        },
      ),

      body: SafeArea(
        child: Column(
          children: [
            AdminTheme.header(
              context: context,
              title: 'Admin Dashboard',
              showBackButton: false,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  children: [
                    _buildDashboardCard(
                      icon: Icons.person_add,
                      title: 'Residents',
                      count: _residentCount.toString(),
                      onTap: () {
                        Navigator.pushNamed(context, '/admin/residents');
                      },
                    ),
                    _buildDashboardCard(
                      icon: Icons.people,
                      title: 'Visitors',
                      count: _visitorCount.toString(),
                      onTap: () {
                        Navigator.pushNamed(context, '/admin/visitors');
                      },
                    ),
                    _buildDashboardCard(
                      icon: Icons.security,
                      title: 'Security',
                      count: _securityCount.toString(),
                      onTap: () {
                        Navigator.pushNamed(context, '/admin/security');
                      },
                    ),
                    _buildDashboardCard(
                      icon: Icons.qr_code,
                      title: 'QR Codes',
                      count: '2',
                      onTap: () {
                        Navigator.pushNamed(context, '/admin/qr-management');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required String title,
    required String count,
    required VoidCallback onTap,
  }) {
    return AdminTheme.card(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 32,
            color: AdminTheme.primaryColor,
          ),
          const SizedBox(height: 12),
          Text(
            count,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AdminTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AdminTheme.subtitleTextStyle,
          ),
        ],
      ),
    );
  }
}
