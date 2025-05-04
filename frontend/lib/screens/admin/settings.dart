import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E0D8),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: const Color(0xFF4A6B5D),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'App Settings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'General Settings',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4A6B5D),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildSettingItem(
                                icon: Icons.notifications,
                                title: 'Visitor Notifications',
                                subtitle: 'Enable/disable visitor notifications',
                                value: true,
                              ),
                              const Divider(),
                              _buildSettingItem(
                                icon: Icons.timer,
                                title: 'Auto Check-out Time',
                                subtitle: 'Set default check-out time for visitors',
                                value: '18:00',
                              ),
                              const Divider(),
                              _buildSettingItem(
                                icon: Icons.security,
                                title: 'Security Check-in Time',
                                subtitle: 'Set security shift start time',
                                value: '07:00',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Security Settings',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4A6B5D),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildSettingItem(
                                icon: Icons.badge,
                                title: 'Security Badge Required',
                                subtitle: 'Require security personnel to wear badges',
                                value: true,
                              ),
                              const Divider(),
                              _buildSettingItem(
                                icon: Icons.security,
                                title: 'Security Patrol Frequency',
                                subtitle: 'Set frequency of security patrols',
                                value: '2 hours',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Resident Settings',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4A6B5D),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildSettingItem(
                                icon: Icons.person_add,
                                title: 'Max Visitors per Resident',
                                subtitle: 'Set maximum number of visitors per resident',
                                value: '3',
                              ),
                              const Divider(),
                              _buildSettingItem(
                                icon: Icons.timer,
                                title: 'Visitor Duration Limit',
                                subtitle: 'Set maximum visit duration',
                                value: '4 hours',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          // TODO: Implement save settings
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFCC7357),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Save Settings',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required dynamic value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4A6B5D)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
              ],
            ),
          ),
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A6B5D),
            ),
          ),
        ],
      ),
    );
  }
}