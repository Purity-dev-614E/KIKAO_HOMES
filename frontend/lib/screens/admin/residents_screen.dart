import 'package:flutter/material.dart';
import 'package:kikao_homes/core/services/auth_service.dart';
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
      'name': 'John Doe',
      'unit_number': 'A101',
      'phone': '+254 700 000 000',
      'email': 'john@example.com',
    },
    {
      'name': 'Jane Smith',
      'unit_number': 'B202',
      'phone': '+254 700 000 001',
      'email': 'jane@example.com',
    },
    // Add more residents as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _residentsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Error: ${snapshot.error}'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _residentsFuture =
                                    AuthService().getProfilesByRole('resident');
                              });
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  // Use data from API or fallback to sample data if empty
                  final residents = (snapshot.hasData &&
                      snapshot.data!.isNotEmpty)
                      ? snapshot.data!
                      : _fallbackResidents;

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Residents Overview',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4A6B5D),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildStatCard('Total Residents',
                                      residents.length.toString()),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...residents.map((resident) =>
                          AdminTheme.card(
                            onTap: () {
                              // Navigate to resident details
                            },
                            padding: const EdgeInsets.all(0),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              title: Text(
                                resident['full_name'] ?? 'No Name',
                                style: AdminTheme.titleTextStyle,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text('Unit: ${resident['unit_number'] ??
                                      'N/A'}',
                                      style: AdminTheme.subtitleTextStyle),
                                  Text('Phone: ${resident['phone'] ?? 'N/A'}',
                                      style: AdminTheme.subtitleTextStyle),
                                  Text('Email: ${resident['email'] ?? 'N/A'}',
                                      style: AdminTheme.subtitleTextStyle),
                                ],
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios,
                                  size: 16,
                                  color: AdminTheme.primaryColor),
                            ),
                          )),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add resident screen
        },
        backgroundColor: AdminTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFCC7357),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
