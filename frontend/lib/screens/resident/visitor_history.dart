import 'package:flutter/material.dart';
import 'package:kikao_homes/screens/resident/visitor_approval.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/models/visit_sessions.dart';
import '../../core/providers/visit_provider.dart';

class VisitorHistoryScreen extends StatefulWidget {
  const VisitorHistoryScreen({super.key});

  @override
  State<VisitorHistoryScreen> createState() => _VisitorHistoryScreenState();
}

class _VisitorHistoryScreenState extends State<VisitorHistoryScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  List<VisitSessions> _visits = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadVisits();
  }

  Future<void> _loadVisits() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _visits = (await Supabase.instance.client
          .from('visit_sessions')
          .select()
          .order('created_at', ascending: false) as List)
          .map((data) => VisitSessions.fromJson(data as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _errorMessage = 'Failed to load visits: ${e.toString()}';
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
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const Spacer(),
                    const Text(
                      'Visitor History',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(
                          Icons.person_outline_sharp, color: Colors.white),
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, "/profile"),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: 'Select Date',
                          prefixIcon: const Icon(
                              Icons.calendar_today, color: Color(0xFF4A6B5D)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null && picked != _selectedDate) {
                            setState(() {
                              _selectedDate = picked;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCC7357),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Search',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: _visits.isEmpty
                    ? const Center(
                  child: Text('No visits found'),
                )
                    : ListView.builder(
                  itemCount: _visits.length,
                  itemBuilder: (context, index) {
                    final visit = _visits[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(visit.VisitorName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHistoryItem('Phone', visit.visitorPhone),
                            _buildHistoryItem('unit', visit.unitNumber),
                            Container(
                              height: 10,
                              width: 10,
                              decoration: BoxDecoration(
                                color: _getStatusColor(visit.status),
                                shape: BoxShape.circle,
                              ),
                            ),
                            if (visit.checkInTime != null)
                              _buildHistoryItem('Check-in', DateTime.parse(
                                  visit.checkInTime!).toLocal()
                                  .toString()
                                  .split('.')[0].replaceAll('-', '/')),
                            if (visit.checkOutTime != null)
                              _buildHistoryItem('Check-in:', DateTime.parse(
                                  visit.checkInTime!).toLocal()
                                  .toString()
                                  .split('.')[0].replaceAll('-', '/')),
                          ],
                        ),
                        trailing: Icon(
                          visit.status == 'approved'
                              ? Icons.check_circle
                              : Icons.pending,
                          color: visit.status == 'approved'
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/visitor_approval');
          },
          backgroundColor: const Color(0xFF4A6B5D),
          tooltip: "Accept visit request",
          child: const Icon(Icons.add),
        )
    );
  }
  Widget _buildHistoryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF4A6B5D),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF2D2D2D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFFCC7357);
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
