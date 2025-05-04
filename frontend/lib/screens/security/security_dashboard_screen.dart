import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/visit_provider.dart';
import '../../core/models/visit_sessions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/qr_code_generator.dart';

class SecurityDashboardScreen extends StatefulWidget {
  const SecurityDashboardScreen({super.key});

  @override
  State<SecurityDashboardScreen> createState() => _SecurityDashboardScreenState();
}

class _SecurityDashboardScreenState extends State<SecurityDashboardScreen> {
  bool _isLoading = false;
  List<VisitSessions> _activeVisits = [];
  List<VisitSessions> _recentCheckouts = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final visitProvider = Provider.of<VisitProvider>(context, listen: false);
      
      // Load active visits
      _activeVisits = await visitProvider.fetchActiveVisits();
      
      // Load recent checkouts directly from Supabase
      final response = await Supabase.instance.client
          .from('visit_sessions')
          .select()
          .eq('check_out_at', 'not null')
          .order('check_out_at', ascending: false)
          .limit(10); // Limit to last 10 checkouts

      _recentCheckouts = (response as List)
          .map((data) => VisitSessions.fromJson(data))
          .toList();
        } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Dashboard'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Text(_errorMessage!),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
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
                                'Active Visits',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4A6B5D),
                                ),
                              ),
                              const SizedBox(height: 10),
                              if (_activeVisits.isEmpty)
                                const Center(
                                  child: Text('No active visits'),
                                )
                              else
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _activeVisits.length,
                                  itemBuilder: (context, index) {
                                    final visit = _activeVisits[index];
                                    return _buildVisitCard(
                                      name: visit.VisitorName,
                                      unit: visit.unitNumber,
                                      status: visit.status,
                                      timeIn: visit.checkInTime?.split('T')[1].substring(0, 5) ?? 'N/A',
                                      timeOut: visit.checkOutTime?.split('T')[1].substring(0, 5) ?? 'N/A',
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Recent Checkouts Section
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
                                'Recent Checkouts',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4A6B5D),
                                ),
                              ),
                              const SizedBox(height: 10),
                              if (_recentCheckouts.isEmpty)
                                const Center(
                                  child: Text('No recent checkouts'),
                                )
                              else
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _recentCheckouts.length,
                                  itemBuilder: (context, index) {
                                    final visit = _recentCheckouts[index];
                                    return _buildVisitCard(
                                      name: visit.VisitorName,
                                      unit: visit.unitNumber,
                                      status: 'Checked Out',
                                      timeIn: visit.checkInTime?.split('T')[1].substring(0, 5) ?? 'N/A',
                                      timeOut: visit.checkOutTime?.split('T')[1].substring(0, 5) ?? 'N/A',
                                    );
                                  },
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
          Navigator.pushNamed(context, '/visitor_registration');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildVisitCard({
    required String name,
    required String unit,
    required String status,
    required String timeIn,
    String? timeOut,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A6B5D),
                  ),
                ),
                Text(
                  'Unit: $unit',
                  style: const TextStyle(
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                Text(
                  'Time In: $timeIn',
                  style: const TextStyle(
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                if (timeOut != null)
                  Text(
                    'Time Out: $timeOut',
                    style: const TextStyle(
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: _getStatusColor(status),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                status,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFFCC7357);
      case 'checked out':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
