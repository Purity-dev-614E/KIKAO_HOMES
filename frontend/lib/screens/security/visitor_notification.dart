import 'package:flutter/material.dart';
import '../../core/constants/theme_constants.dart';

class VisitorNotification extends StatefulWidget {
  final Map<String, dynamic> visitorData;
  
  const VisitorNotification({
    super.key,
    required this.visitorData,
  });

  @override
  State<VisitorNotification> createState() => _VisitorNotificationState();
}

class _VisitorNotificationState extends State<VisitorNotification> {
  bool _isLoading = false;
  bool _isCheckedIn = false;
  
  void _checkInVisitor() {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
        _isCheckedIn = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: Text(
          'Approved Visitor',
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
                // Status Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: _isCheckedIn 
                        ? AppTheme.successColor.withOpacity(0.1)
                        : AppTheme.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isCheckedIn ? AppTheme.successColor : AppTheme.accentColor,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isCheckedIn ? Icons.check_circle : Icons.notifications_active,
                        color: _isCheckedIn ? AppTheme.successColor : AppTheme.accentColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _isCheckedIn
                              ? 'Visitor has been checked in'
                              : 'This visitor has been approved by the resident',
                          style: AppTheme.smallTextStyle.copyWith(
                            color: _isCheckedIn ? AppTheme.successColor : AppTheme.accentColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
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
                              widget.visitorData['visitor_name'] ?? '',
                              style: AppTheme.subheadingStyle,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Visitor',
                                style: AppTheme.smallTextStyle.copyWith(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),
                      
                      // Visitor Details
                      _buildInfoRow('Phone', widget.visitorData['visitor_phone'] ?? '+254 712 345 678'),
                      const SizedBox(height: 12),
                      _buildInfoRow('Unit Visiting', widget.visitorData['unit_number'] ?? 'A-123'),
                      const SizedBox(height: 12),
                      _buildInfoRow('Approved By', 'Resident Name'),
                      const SizedBox(height: 12),
                      _buildInfoRow('Approval Time', '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}'),
                      const SizedBox(height: 12),
                      _buildInfoRow('Date', '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Action Button
                if (!_isCheckedIn)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _checkInVisitor,
                      style: AppTheme.primaryButtonStyle,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Check In Visitor',
                              style: AppTheme.bodyStyle.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                
                if (_isCheckedIn)
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Check-in Time:', style: AppTheme.bodyStyle),
                                Text(
                                  '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                                  style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: AppTheme.accentButtonStyle,
                          child: Text(
                            'Done',
                            style: AppTheme.bodyStyle.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
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