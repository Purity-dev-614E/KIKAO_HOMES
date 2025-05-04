import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/providers/visit_provider.dart';
import '../../core/constants/theme_constants.dart';

class VisitorApproval extends StatefulWidget {
  final Map<String, dynamic> visitorData;

  const VisitorApproval({
    super.key,
    required this.visitorData,
  });

  @override
  State<VisitorApproval> createState() => _VisitorApprovalState();
}
class _VisitorApprovalState extends State<VisitorApproval> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeSecurityId();
  }
  
  Future<void> _approveVisitor() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final visitProvider = Provider.of<VisitProvider>(context, listen: false);
      await visitProvider.approveVisit(widget.visitorData['id']);
      
      if (!mounted) return;
      
      _showConfirmationDialog(true);
      await visitProvider.notifySecurityApproval(
        securityId: securityId ?? 'Unknown Security ID',
        message: 'Visitor approved: ${widget.visitorData['name']}',
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Approval failed: ${e.toString()}')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }
  Future<void> _initializeSecurityId() async {
    securityId = await _getSecurityId();
  }

 Future<String?> _getSecurityId() async {
      try {
        final response = await Supabase.instance.client
            .from('active_shifts')
            .select('security_id')
           .eq('logout', 'null')
            .order('login', ascending: false)
            .limit(1)
            .single();

        if (response != null && response['security_id'] != null) {
          return response['security_id'] as String;
        }
        return null;
      } catch (e) {
        print('Error fetching security ID: $e');
        return null;
      }
    }
    String? securityId;
  
  Future<void> _rejectVisitor() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final visitProvider = Provider.of<VisitProvider>(context, listen: false);
      await visitProvider.rejectVisit(widget.visitorData['id']);
      
      if (!mounted) return;
      
      _showConfirmationDialog(false);
      await visitProvider.notifySecurityRejection(
        securityId: securityId ?? 'Unknown Security ID',
        message: 'Visitor rejected: ${widget.visitorData['name']}',
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rejection failed: ${e.toString()}')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _showConfirmationDialog(bool approved) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          approved ? 'Visitor Approved' : 'Visitor Rejected',
          style: AppTheme.subheadingStyle,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              approved ? Icons.check_circle_outline : Icons.cancel_outlined,
              color: approved ? AppTheme.successColor : AppTheme.errorColor,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              approved 
                ? 'You have approved the visit request. The security desk has been notified.'
                : 'You have rejected the visit request. The visitor will not be allowed in.',
              style: AppTheme.bodyStyle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(
              'OK',
              style: TextStyle(color: AppTheme.primaryColor),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: Text(
          'Visitor Request',
          style: AppTheme.subheadingStyle.copyWith(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Visitor Info Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppTheme.secondaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.person,
                                size: 40,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Visitor Request',
                              style: AppTheme.subheadingStyle,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Someone is requesting to visit you',
                              style: AppTheme.smallTextStyle,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),
                      
                      // Visitor Details
                      _buildInfoRow('Name', widget.visitorData['name'] ?? 'John Doe'),
                      const SizedBox(height: 12),
                      _buildInfoRow('ID Number', widget.visitorData['id'] ?? '12345678'),
                      const SizedBox(height: 12),
                      _buildInfoRow('Phone', widget.visitorData['phone'] ?? '+254 712 345 678'),
                      const SizedBox(height: 12),
                      _buildInfoRow('Unit', widget.visitorData['unit_number'] ?? 'A-123'),
                      const SizedBox(height: 12),
                      _buildInfoRow('Time', '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}'),
                      const SizedBox(height: 12),
                      _buildInfoRow('Date', '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Action Buttons
                Row(
                  children: [
                    // Reject Button
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _rejectVisitor,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.errorColor,
                            side: BorderSide(color: AppTheme.errorColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppTheme.errorColor,
                                  ),
                                )
                              : Text(
                                  'Reject',
                                  style: AppTheme.bodyStyle.copyWith(
                                    color: AppTheme.errorColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Approve Button
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _approveVisitor,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.successColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  'Approve',
                                  style: AppTheme.bodyStyle.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTheme.bodyStyle.copyWith(
            color: AppTheme.textColor.withOpacity(0.7),
          ),
        ),
        Text(
          value,
          style: AppTheme.bodyStyle.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}