import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VisitorApprovalScreen extends StatefulWidget {
  const VisitorApprovalScreen({super.key});

  @override
  _VisitorApprovalScreenState createState() => _VisitorApprovalScreenState();
}

class _VisitorApprovalScreenState extends State<VisitorApprovalScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _visitorData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // We'll initialize the data in didChangeDependencies to access route arguments
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeVisitorData();
  }

  Future<void> _initializeVisitorData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Get visitor data from route arguments
      final args = ModalRoute.of(context)?.settings.arguments;
      
      if (args == null) {
        setState(() {
          _errorMessage = "No visitor data provided";
          _isLoading = false;
        });
        return;
      }
      
      if (args is! Map<String, dynamic>) {
        setState(() {
          _errorMessage = "Invalid visitor data format";
          _isLoading = false;
        });
        return;
      }
      
      print("Received arguments: $args");
      
      // Extract the visitor data from the arguments
      final visitorData = args['visitorData'];
      
      if (visitorData == null) {
        setState(() {
          _errorMessage = "No visitor data found in arguments";
          _isLoading = false;
        });
        return;
      }
      
      if (visitorData is! Map<String, dynamic>) {
        setState(() {
          _errorMessage = "Invalid visitor data format";
          _isLoading = false;
        });
        return;
      }
      
      print("Extracted visitor data: $visitorData");
      
      // Use the visitor data
      setState(() {
        _visitorData = Map<String, dynamic>.from(visitorData);
        _isLoading = false;
      });
      
    } catch (e) {
      setState(() {
        _errorMessage = "Error initializing visitor data: $e";
        _isLoading = false;
      });
      print("Error initializing visitor data: $e");
    }
  }

  bool _hasCompleteVisitorData(Map<String, dynamic> data) {
    // Check if we have the minimum required visitor data
    final hasRequiredFields = data.containsKey('visitor_id') && 
           data.containsKey('visitor_name') && 
           data.containsKey('visitor_phone');
           
    print('Checking if visitor data is complete. Has required fields: $hasRequiredFields');
    print('Data keys: ${data.keys}');
    print('Data values: $data');
    
    return hasRequiredFields;
  }

  Future<void> _fetchVisitorById(String visitorId) async {
    try {
      print("Fetching visit session data for ID: $visitorId");
      
      final response = await Supabase.instance.client
          .from('visit_sessions')
          .select()
          .eq('id', visitorId)
          .single();
      
      if (response != null) {
        // Map the response to the expected format
        final mappedData = {
          'id': response['id']?.toString() ?? '',
          'visitor_id': response['id']?.toString() ?? '',
          'visitor_name': response['visitor_name']?.toString() ?? 'Unknown',
          'visitor_phone': response['visitor_phone']?.toString() ?? 'Unknown',
          'unit_number': response['unit_number']?.toString() ?? 'Unknown',
          'status': response['status']?.toString() ?? 'pending',
          'check_in_at': response['check_in_at']?.toString() ?? '',
          'check_out_at': response['check_out_at']?.toString() ?? '',
          'national_id': response['national_id']?.toString() ?? '',
        };
        
        setState(() {
          _visitorData = mappedData;
          _isLoading = false;
        });
        print("Fetched visit session data by ID: $_visitorData");
      } else {
        setState(() {
          _errorMessage = "No visit session found with ID: $visitorId";
          _isLoading = false;
        });
        print("No visit session found with ID: $visitorId");
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error fetching visitor data: $e";
        _isLoading = false;
      });
      print("Error fetching visitor data: $e");
    }
  }

  Future<void> _fetchLatestVisitorRequest() async {
    try {
      print("Fetching latest pending visit session");
      
      // Get the current user ID
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception("User not authenticated");
      }

      // Fetch the most recent pending visit session for this user
      final response = await Supabase.instance.client
          .from('visit_sessions')
          .select()
          .eq('resident_id', userId)  // Make sure this field exists in your visit_sessions table
          .eq('status', 'pending')
          .order('created_at', ascending: false)
          .limit(1)
          .single();

      if (response != null) {
        // Map the response to the expected format
        final mappedData = {
          'id': response['id']?.toString() ?? '',
          'visitor_id': response['id']?.toString() ?? '',
          'visitor_name': response['visitor_name']?.toString() ?? 'Unknown',
          'visitor_phone': response['visitor_phone']?.toString() ?? 'Unknown',
          'unit_number': response['unit_number']?.toString() ?? 'Unknown',
          'status': response['status']?.toString() ?? 'pending',
          'check_in_at': response['check_in_at']?.toString() ?? '',
          'check_out_at': response['check_out_at']?.toString() ?? '',
          'national_id': response['national_id']?.toString() ?? '',
        };
        
        setState(() {
          _visitorData = mappedData;
          _isLoading = false;
        });
        print("Fetched latest pending visit session: $_visitorData");
      } else {
        setState(() {
          _errorMessage = "No pending visit sessions found";
          _isLoading = false;
        });
        print("No pending visit sessions found");
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error fetching visitor data: $e";
        _isLoading = false;
      });
      print("Error fetching latest visitor request: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visitor Approval'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading visitor details...', 
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text(
                        'Error',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Go Back'),
                      ),
                    ],
                  ),
                )
              : _buildVisitorApprovalContent(),
    );
  }

  Widget _buildVisitorApprovalContent() {
    // Extract visitor data with fallbacks for different field names
    final visitorName = _visitorData!['visitor_name'] ?? _visitorData!['name'] ?? 'Unknown';
    final visitorPhone = _visitorData!['visitor_phone'] ?? _visitorData!['phone'] ?? 'Unknown';
    final visitPurpose = _visitorData!['visit_purpose'] ?? _visitorData!['purpose'] ?? 'Unknown';
    final visitTime = _visitorData!['visit_time'] ?? _visitorData!['time'] ?? 'Unknown';
    final nationalId = _visitorData!['national_id'] ?? '';
    final unitNumber = _visitorData!['unit_number'] ?? '';
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with visitor avatar
          Container(
            color: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.only(bottom: 30, left: 20, right: 20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white.withOpacity(0.9),
                  child: Text(
                    visitorName.isNotEmpty ? visitorName[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 40, 
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  visitorName,
                  style: const TextStyle(
                    fontSize: 24, 
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Waiting for your approval',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          
          // Visitor details card
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Visitor Details',
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Divider(height: 30),
                  _buildInfoRowImproved(Icons.person, 'Name', visitorName),
                  _buildInfoRowImproved(Icons.phone, 'Phone', visitorPhone),
                  _buildInfoRowImproved(Icons.home, 'Unit', unitNumber),
                  _buildInfoRowImproved(Icons.description, 'Purpose', visitPurpose),
                  _buildInfoRowImproved(Icons.access_time, 'Time', visitTime),
                  if (nationalId.isNotEmpty)
                    _buildInfoRowImproved(Icons.badge, 'ID Number', nationalId),
                ],
              ),
            ),
          ),
          
          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _approveVisitor(),
                  icon: const Icon(Icons.check_circle),
                  label: const Text('APPROVE VISITOR'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _denyVisitor(),
                  icon: const Icon(Icons.cancel),
                  label: const Text('DENY VISITOR'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowImproved(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary.withOpacity(0.7)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _approveVisitor() async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Visitor'),
        content: const Text('Are you sure you want to approve this visitor?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('APPROVE'),
          ),
        ],
      ),
    );
    
    if (confirm != true) return;
    
    // Show loading overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
    );
    
    try {
      // Get the visitor ID
      final visitorId = _visitorData!['visitor_id'] ?? _visitorData!['id'];
      if (visitorId == null || visitorId.isEmpty) {
        throw Exception("Visitor ID not found");
      }
      
      print("Approving visitor with ID: $visitorId");
      
      // Update the visitor status in the database
      await Supabase.instance.client
          .from('visit_sessions')
          .update({'status': 'approved'})
          .eq('id', visitorId);
      
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();
      
      // Show success message and animation
      if (mounted) {
        // Show success animation
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 70,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Visitor Approved',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'The visitor has been approved successfully.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 45),
                    ),
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
          ),
        );
        
        // Navigate back to visitor history
        Navigator.of(context).pushReplacementNamed('/visitor_history');
      }
    } catch (e) {
      print("Error approving visitor: $e");
      
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();
      
      if (mounted) {
        // Show error dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to approve visitor: ${e.toString()}'),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _denyVisitor() async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deny Visitor'),
        content: const Text('Are you sure you want to deny this visitor?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('DENY'),
          ),
        ],
      ),
    );
    
    if (confirm != true) return;
    
    // Show loading overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
    );
    
    try {
      // Get the visitor ID
      final visitorId = _visitorData!['visitor_id'] ?? _visitorData!['id'];
      if (visitorId == null || visitorId.isEmpty) {
        throw Exception("Visitor ID not found");
      }
      
      print("Denying visitor with ID: $visitorId");
      
      // Update the visitor status in the database
      await Supabase.instance.client
          .from('visit_sessions')
          .update({'status': 'rejected'})
          .eq('id', visitorId);
      
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();
      
      // Show success message and animation
      if (mounted) {
        // Show success animation
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cancel,
                    color: Colors.red,
                    size: 70,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Visitor Denied',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'The visitor has been denied successfully.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 45),
                    ),
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
          ),
        );
        
        // Navigate back to visitor history
        Navigator.of(context).pushReplacementNamed('/visitor_history');
      }
    } catch (e) {
      print("Error denying visitor: $e");
      
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();
      
      if (mounted) {
        // Show error dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to deny visitor: ${e.toString()}'),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }
}