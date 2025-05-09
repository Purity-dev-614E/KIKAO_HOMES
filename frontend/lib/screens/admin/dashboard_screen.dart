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
      backgroundColor: AdminTheme.backgroundColor,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: AdminTheme.accentColor,
        unselectedItemColor: AdminTheme.primaryColor,
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
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: _loadCounts,
                  tooltip: 'Refresh data',
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to Kikao Homes Admin',
                      style: AdminTheme.titleTextStyle.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage your community from one place',
                      style: AdminTheme.subtitleTextStyle,
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                        children: [
                          _buildDashboardCard(
                            icon: Icons.person_add,
                            title: 'Residents',
                            count: _residentCount.toString(),
                            color: const Color(0xFF4CAF50), // Green
                            onTap: () {
                              Navigator.pushNamed(context, '/admin/residents');
                            },
                          ),
                          _buildDashboardCard(
                            icon: Icons.people,
                            title: 'Visitors',
                            count: _visitorCount.toString(),
                            color: const Color(0xFF2196F3), // Blue
                            onTap: () {
                              Navigator.pushNamed(context, '/admin/visitors');
                            },
                          ),
                          _buildDashboardCard(
                            icon: Icons.security,
                            title: 'Security',
                            count: _securityCount.toString(),
                            color: const Color(0xFFF44336), // Red
                            onTap: () {
                              Navigator.pushNamed(context, '/admin/security');
                            },
                          ),
                          _buildDashboardCard(
                            icon: Icons.qr_code,
                            title: 'QR Codes',
                            count: '2',
                            color: const Color(0xFFFF9800), // Orange
                            onTap: () {
                              Navigator.pushNamed(context, '/admin/qr-management');
                            },
                          ),
                        ],
                      ),
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
    required Color color,
  }) {
    return AdminTheme.dashboardCard(
      accentColorOverride: color,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 32,
              color: color,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            count,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AdminTheme.subtitleTextStyle.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
