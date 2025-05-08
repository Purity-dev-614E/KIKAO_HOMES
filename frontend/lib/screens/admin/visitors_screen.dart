import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:kikao_homes/core/models/visit_sessions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_theme.dart';

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
      
      final visitDate = visit['check_in_at'] != null && visit['check_in_at'].toString().contains(' ')
          ? DateTime.parse(visit['check_in_at'].toString().split(' ')[0])
          : DateTime.now(); // Fallback to current date if invalid
      return visitDate.isAfter(startDate) && visitDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredVisits = _getFilteredVisits();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AdminTheme.header(
              context: context,
              title: 'Visitor History',
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AdminTheme.primaryColor),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
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
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${filteredVisits.length} visits',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AdminTheme.primaryColor,
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

                  DateTime _parseDate(String date, {DateTime? fallback}) {
                    try {
                      return DateTime.parse(date);
                    } catch (e) {
                      return fallback ?? DateTime.now();
                    }
                  }
                 final timeIn = visit['check_in_at'] != null
                     ? _parseDate(visit['check_in_at'].toString(), fallback: DateTime.now())
                     : DateTime.now();
                 final timeOut = visit['check_out_at'] != null && visit['check_out_at'].toString().isNotEmpty
                     ? _parseDate(visit['check_out_at'].toString())
                     : null;

                  return AdminTheme.card(
                    padding: const EdgeInsets.all(0),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: _getStatusColor(visit['status'] ?? 'pending'),
                        child: Text(
                          visit['visitor_name'] != null && visit['visitor_name'].toString().isNotEmpty
                              ? visit['visitor_name'][0].toString().toUpperCase()
                              : '?',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        visit['visitor_name'] ?? 'Unknown',
                        style: AdminTheme.titleTextStyle,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            visit['unit_number'] ?? 'No unit',
                            style: AdminTheme.subtitleTextStyle,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${DateFormat('MMM d, yyyy').format(timeIn)} at ${DateFormat('HH:mm').format(timeIn)}'
                            '${timeOut != null ? ' - ${DateFormat('HH:mm').format(timeOut)}' : ''}',
                            style: AdminTheme.subtitleTextStyle,
                          ),
                          if (visit['visitor_phone'] != null)
                            Text(
                              visit['visitor_phone'],
                              style: AdminTheme.subtitleTextStyle,
                            ),
                        ],
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(visit['status'] ?? 'pending').withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getStatusColor(visit['status'] ?? 'pending'),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          (visit['status'] ?? 'Pending').toString().toUpperCase(),
                          style: TextStyle(
                            color: _getStatusColor(visit['status'] ?? 'pending'),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
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