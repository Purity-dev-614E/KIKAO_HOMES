import 'package:flutter/material.dart';
import 'package:kikao_homes/core/models/profiles.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  if (response == null) {
    throw Exception('Failed to load residents');
  }

  return (response as List).length;
}

Future<int> getAllVisitors() async {
  final response = await Supabase.instance.client
      .from('visit_sessions')
      .select();

  if (response == null) {
    throw Exception('Failed to load visitors');
  }

  return (response as List).length;
}

Future<int> getAllSecurity() async {
  final response = await Supabase.instance.client
      .from('profiles')
      .select()
      .eq('role', 'security');
  if (response == null) {
    throw Exception('Failed to load Security officers');
  }

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
            Navigator.pushNamed(context, '/user-management');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/admin/settings');
          }
        },
      ),

      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: const Color(0xFF4A6B5D),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () {},
                  ),
                  const Text(
                    'Admin Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.white),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.person, color: Colors.white),
                    onPressed: () {
                      Navigator.pushNamed(context, '/profile');
                    },
                  ),
                ],
              ),
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
   return Card(
     elevation: 2,
     shape: RoundedRectangleBorder(
       borderRadius: BorderRadius.circular(12),
     ),
     child: InkWell(
       onTap: onTap,
       borderRadius: BorderRadius.circular(12),
       child: Padding(
         padding: const EdgeInsets.all(16.0),
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             Icon(
               icon,
               size: 32,
               color: const Color(0xFF4A6B5D),
             ),
             const SizedBox(height: 12),
             Text(
               count,
               style: const TextStyle(
                 fontSize: 20,
                 fontWeight: FontWeight.bold,
                 color: Color(0xFF4A6B5D),
               ),
             ),
             const SizedBox(height: 6),
             Text(
               title,
               style: const TextStyle(
                 fontSize: 14,
                 color: Color(0xFF2D2D2D),
               ),
             ),
           ],
         ),
       ),
     ),
   );
  }
}
