import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class VisitorsScreen extends StatefulWidget {
  const VisitorsScreen({super.key});

  @override
  State<VisitorsScreen> createState() => _VisitorsScreenState();
}

class _VisitorsScreenState extends State<VisitorsScreen> {
  final List<Map<String, dynamic>> _visitors = [
    {
      'name': 'John Doe',
      'status': 'Approved',
      'unit': 'A101',
      'timeIn': '2025-04-25 14:30',
      'timeOut': '2025-04-25 15:45',
      'purpose': 'Delivery',
    },
    {
      'name': 'Jane Smith',
      'status': 'Pending',
      'unit': 'B202',
      'timeIn': '2025-04-26 15:00',
      'timeOut': '',
      'purpose': 'Visit',
    },
    {
      'name': 'Bob Johnson',
      'status': 'Approved',
      'unit': 'C303',
      'timeIn': '2025-03-15 10:00',
      'timeOut': '2025-03-15 11:30',
      'purpose': 'Meeting',
    },
    {
      'name': 'Alice Brown',
      'status': 'Approved',
      'unit': 'D404',
      'timeIn': '2025-02-20 16:00',
      'timeOut': '2025-02-20 17:00',
      'purpose': 'Delivery',
    },
    // Add more visitors as needed
  ];

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
      final visitDate = DateTime.parse(visit['timeIn'].toString().split(' ')[0]);
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
                  final timeIn = DateTime.parse(visit['timeIn'].toString());
                  final timeOut = visit['timeOut'].isNotEmpty
                      ? DateTime.parse(visit['timeOut'].toString())
                      : null;

                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getStatusColor(visit['status']),
                        child: Text(
                          visit['name'][0],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(visit['name']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(visit['unit']),
                          Text(
                            '${DateFormat('MMM d, yyyy').format(timeIn)} at ${DateFormat('HH:mm').format(timeIn)}'
                            '${timeOut != null ? ' - ${DateFormat('HH:mm').format(timeOut)}' : ''}',
                          ),
                          Text(visit['purpose']),
                        ],
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(visit['status']),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          visit['status'],
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