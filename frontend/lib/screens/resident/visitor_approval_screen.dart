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
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _buildVisitorApprovalContent(),
    );
  }

  Widget _buildVisitorApprovalContent() {
    // Extract visitor data with fallbacks for different field names
    final visitorName = _visitorData!['visitor_name'] ?? _visitorData!['name'] ?? 'Unknown';
    final visitorPhone = _visitorData!['visitor_phone'] ?? _visitorData!['phone'] ?? 'Unknown';
    final visitPurpose = _visitorData!['visit_purpose'] ?? _visitorData!['purpose'] ?? 'Unknown';
    final visitTime = _visitorData!['visit_time'] ?? _visitorData!['time'] ?? 'Unknown';
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Visitor Details',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildInfoRow('Name', visitorName),
          _buildInfoRow('Phone', visitorPhone),
          _buildInfoRow('Purpose', visitPurpose),
          _buildInfoRow('Time', visitTime),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _approveVisitor(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: const Text('Approve', style: TextStyle(fontSize: 16)),
              ),
              ElevatedButton(
                onPressed: () => _denyVisitor(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: const Text('Deny', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _approveVisitor() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Get the visitor ID
      final visitorId = _visitorData!['visitor_id'] ?? _visitorData!['id'];
      if (visitorId == null || visitorId.isEmpty) {
        throw Exception("Visitor ID not found");
      }
      
      print("Approving visitor with ID: $visitorId");
      
      // Update the visitor status in the database
      await Supabase.instance.client
          .from('visit_sessions')  // Use visit_sessions table instead of visitors
          .update({'status': 'approved'})
          .eq('id', visitorId);
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Visitor approved successfully')),
        );
        
        // Navigate back to visitor history
        Navigator.of(context).pushReplacementNamed('/visitor_history');
      }
    } catch (e) {
      print("Error approving visitor: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error approving visitor: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _denyVisitor() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Get the visitor ID
      final visitorId = _visitorData!['visitor_id'] ?? _visitorData!['id'];
      if (visitorId == null || visitorId.isEmpty) {
        throw Exception("Visitor ID not found");
      }
      
      print("Denying visitor with ID: $visitorId");
      
      // Update the visitor status in the database
      await Supabase.instance.client
          .from('visit_sessions')  // Use visit_sessions table instead of visitors
          .update({'status': 'rejected'})
          .eq('id', visitorId);
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Visitor denied')),
        );
        
        // Navigate back to visitor history
        Navigator.of(context).pushReplacementNamed('/visitor_history');
      }
    } catch (e) {
      print("Error denying visitor: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error denying visitor: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}