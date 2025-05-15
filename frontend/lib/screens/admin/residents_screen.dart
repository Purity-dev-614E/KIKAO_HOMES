import 'package:flutter/material.dart';
import 'package:kikao_homes/core/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_theme.dart';

class ResidentsScreen extends StatefulWidget {
  const ResidentsScreen({super.key});

  @override
  State<ResidentsScreen> createState() => _ResidentsScreenState();
}

class _ResidentsScreenState extends State<ResidentsScreen> {
  late Future<List<Map<String, dynamic>>> _residentsFuture;

  @override
  void initState() {
    super.initState();
    _residentsFuture = AuthService().getProfilesByRole('resident');
  }

  // Fallback data in case the API fails
  final List<Map<String, dynamic>> _fallbackResidents = [
    {
      'full_name': 'John Doe',
      'unit_number': 'A101',
      'phone': '+254 700 000 000',
      'email': 'john@example.com',
    },
    {
      'full_name': 'Jane Smith',
      'unit_number': 'B202',
      'phone': '+254 700 000 001',
      'email': 'jane@example.com',
    },
    // Add more residents as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            AdminTheme.header(
              context: context,
              title: 'Residents',
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {},
                  tooltip: 'Search residents',
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list, color: Colors.white),
                  onPressed: () {},
                  tooltip: 'Filter residents',
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manage Residents',
                      style: AdminTheme.titleTextStyle.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'View and manage all residents in your community',
                      style: AdminTheme.subtitleTextStyle,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: FutureBuilder<List<Map<String, dynamic>>>(
                        future: _residentsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(AdminTheme.accentColor),
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 64,
                                    color: Colors.red.shade300,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Error loading residents',
                                    style: AdminTheme.titleTextStyle.copyWith(
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    snapshot.error.toString(),
                                    style: AdminTheme.subtitleTextStyle,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _residentsFuture = AuthService().getProfilesByRole('resident');
                                      });
                                    },
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Retry'),
                                    style: AdminTheme.elevatedButtonTheme.style,
                                  ),
                                ],
                              ),
                            );
                          }

                          // Use data from API or fallback to sample data if empty
                          final residents = (snapshot.hasData && snapshot.data!.isNotEmpty)
                              ? snapshot.data!
                              : _fallbackResidents;

                          return Column(
                            children: [
                              // Stats card
                              AdminTheme.dashboardCard(
                                accentColorOverride: AdminTheme.accentColor,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AdminTheme.accentColor.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.people,
                                          size: 28,
                                          color: AdminTheme.accentColor,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Total Residents',
                                            style: AdminTheme.subtitleTextStyle.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            residents.length.toString(),
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: AdminTheme.accentColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // Residents list
                              Expanded(
                                child: residents.isEmpty
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.person_off,
                                              size: 64,
                                              color: Colors.grey.shade400,
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'No residents found',
                                              style: AdminTheme.titleTextStyle.copyWith(
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : ListView.builder(
                                        itemCount: residents.length,
                                        itemBuilder: (context, index) {
                                          final resident = residents[index];
                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 12),
                                            child: AdminTheme.card(
                                              onTap: () {
                                                // Navigate to resident details
                                              },
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 50,
                                                    height: 50,
                                                    decoration: BoxDecoration(
                                                      color: AdminTheme.primaryColor.withOpacity(0.1),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        (resident['full_name'] ?? 'R').substring(0, 1).toUpperCase(),
                                                        style: TextStyle(
                                                          color: AdminTheme.primaryColor,
                                                          fontSize: 20,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          resident['full_name'] ?? 'Unknown',
                                                          style: const TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 4),
                                                        Text(
                                                          'Unit: ${resident['unit_number'] ?? 'N/A'}',
                                                          style: TextStyle(
                                                            color: Colors.grey.shade700,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 4),
                                                        Text(
                                                          resident['email'] ?? 'No email',
                                                          style: TextStyle(
                                                            color: Colors.grey.shade600,
                                                            fontSize: 13,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Column(
                                                    children: [
                                                      IconButton(
                                                        icon: const Icon(Icons.edit, color: AdminTheme.primaryColor),
                                                        onPressed: () {
                                                          // Edit resident
                                                        },
                                                        tooltip: 'Edit resident',
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(Icons.delete, color: Colors.red),
                                                      onPressed: () async {
                                                        try {
                                                          final userId = resident['id']; // Replace with the correct key for the user's ID
                                                          await Supabase.instance.client.auth.admin.deleteUser(userId);
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            const SnackBar(content: Text('Resident deleted successfully')),
                                                          );
                                                          setState(() {
                                                            _residentsFuture = AuthService().getProfilesByRole('resident');
                                                          });
                                                        } catch (e) {
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(content: Text('Error deleting resident: $e')),
                                                          );
                                                        }
                                                      },
                                                        tooltip: 'Delete resident',
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add resident screen
        },
        backgroundColor: AdminTheme.accentColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        tooltip: 'Add new resident',
      ),
    );
  }
}
