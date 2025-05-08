import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:kikao_homes/core/models/visit_sessions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VisitorsScreen extends StatefulWidget {
  const VisitorsScreen({super.key});

  @override
  State<VisitorsScreen> createState() => _VisitorsScreenState();
}

class _VisitorsScreenState extends State<VisitorsScreen> {
  final List<Map<String, dynamic>> _visitors = [];
  
  @override
  void initState() {
    super.initState();
    _fetchVisitors();
  }

  Future<void> _fetchVisitors() async {
    try {
      final response = await Supabase.instance.client
          .from('visit_sessions')
          .select();

      setState(() {
        _visitors.clear();
        _visitors.addAll((response as List).map((json) => VisitSessions.fromJson(json).toJson()));
      });
    } catch (e) {
      // Handle error
      print('Error fetching visitors: $e');
    }
  }

  String _selectedFilter = 'Week';

  List<Map<String, dynamic>> _getFilteredVisits() {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate;

    switch (_selectedFilter) {
      case 'Week':
        startDate = now.subtract(const Duration(days: 7));
        endDate = now;
        break;
      case 'Month':
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 0);
        break;
      case 'Year':
        startDate = DateTime(now.year, 1, 1);
        endDate = DateTime(now.year, 12, 31);
        break;
      default:
        startDate = now.subtract(const Duration(days: 7));
        endDate = now;
    }

    return _visitors.where((visit) {
      // Using check_in_at field instead of timeIn
      if (visit['check_in_at'] == null) return false;
      
      final visitDate = DateTime.parse(visit['check_in_at'].toString().split(' ')[0]);
      return visitDate.isAfter(startDate) && visitDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFF4CAF50);
      case 'pending':
        return const Color(0xFFFFC107);
      case 'rejected':
        return const Color(0xFFE53935);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredVisits = _getFilteredVisits();

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
                    'Visitor History',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  DropdownButton<String>(
                    value: _selectedFilter,
                    items: const [
                      DropdownMenuItem(
                        value: 'Week',
                        child: Text('This Week'),
                      ),
                      DropdownMenuItem(
                        value: 'Month',
                        child: Text('This Month'),
                      ),
                      DropdownMenuItem(
                        value: 'Year',
                        child: Text('This Year'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedFilter = value!;
                      });
                    },
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${filteredVisits.length} visits',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A6B5D),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredVisits.length,
                itemBuilder: (context, index) {
                  final visit = filteredVisits[index];
                  final timeIn = visit['check_in_at'] != null 
                      ? DateTime.parse(visit['check_in_at'].toString())
                      : DateTime.now();
                  final timeOut = visit['check_out_at'] != null && visit['check_out_at'].toString().isNotEmpty
                      ? DateTime.parse(visit['check_out_at'].toString())
                      : null;

                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getStatusColor(visit['status'] ?? 'pending'),
                        child: Text(
                          visit['visitor_name'] != null && visit['visitor_name'].toString().isNotEmpty
                              ? visit['visitor_name'][0]
                              : '?',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(visit['visitor_name'] ?? 'Unknown'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(visit['unit_number'] ?? 'No unit'),
                          Text(
                            '${DateFormat('MMM d, yyyy').format(timeIn)} at ${DateFormat('HH:mm').format(timeIn)}'
                            '${timeOut != null ? ' - ${DateFormat('HH:mm').format(timeOut)}' : ''}',
                          ),
                          if (visit['visitor_phone'] != null)
                            Text(visit['visitor_phone']),
                        ],
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(visit['status'] ?? 'pending'),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          visit['status'] ?? 'Pending',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}