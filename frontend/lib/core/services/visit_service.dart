import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constants/appEndpoints.dart';
import '../models/visit_sessions.dart';
import 'http_client.dart';
import 'dart:developer';

class VisitService {
  final _client = HttpClientWrapper();
  
  //get my visits
  Future<List<VisitSessions>> getMyVisits() async {
    try {
      final response = await _client.post(AppEndpoints().getMyVisits);

      log("My visits: ${response.statusCode} \n ${response.body}");

      if (response.statusCode == 200) {
        // Parse the response body from JSON string to a List
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => VisitSessions.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to load visits: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting visits: $e');
    }
  }

  //get visit details
  Future<String> approveVisit(String visitId) async {
    try {
      final response = await _client.post(
        AppEndpoints().approveVisit,
        body: jsonEncode({'visit_id': visitId}),
      );

      log("Approve visit: ${response.statusCode} \n ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['message']; // now returns "Visit Accepted"
      } else {
        throw Exception('Failed to approve visit: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error approving visit: $e');
    }
  }


  Future<String> rejectVisit(String visitId) async {
    try {
      final response = await _client.post(
          AppEndpoints().rejectVisit,
          body: jsonEncode({'visit_id': visitId})
      );

      log("Reject Visit: ${response.statusCode}\n${response.body}");
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['message']; // now returns "Visit Accepted"
      } else {
        throw Exception('Failed to reject visit: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error rejecting visit: $e');
    }
  }

  Future<VisitSessions> createVisitSession(VisitSessions visitSession) async {
    try {
      log("VisitService: Preparing to create visit session with data: ${jsonEncode(visitSession.toJson())}");
      
      // Check if we have a valid Supabase session - but don't require it for visitor registration
      final session = _client.supabase.auth.currentSession;
      log("VisitService: Current Supabase session: ${session != null ? 'Valid' : 'Not authenticated'}");
      
      // For visitor registration, we don't need authentication
      final response = await http.post(
        Uri.parse(AppEndpoints().submitVisit),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(visitSession.toJson()),
      );

      log("VisitService: Create Visit Session response - Status: ${response.statusCode}");
      log("VisitService: Response body: ${response.body ?? 'No response body'}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        log("VisitService: Visit session created successfully");
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        log("VisitService: Parsed response data: ${jsonEncode(responseData)}");
        
        // If the server returns the created visit data, use it
        if (responseData['data'] != null && responseData['data'] is Map) {
          return VisitSessions.fromJson(Map<String, dynamic>.from(responseData['data']));
        } 
        // If no data is returned but the request was successful, return the original visit session
        else {
          log("VisitService: No visit data in response, returning original visit session");
          return visitSession;
        }
      } else {
        log("VisitService: Failed to create visit session: ${response.statusCode}");
        log("VisitService: Error response: ${response.body}");
        
        // Parse error message for better user feedback
        String errorMessage = 'Failed to create visit session: ${response.statusCode}';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          }
        } catch (_) {
          // If we can't parse the error, use the default message
        }
        
        throw Exception('Failed to create visit session: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      log("VisitService: Exception during visit creation: $e");
      throw Exception('Error creating visit session: $e');
    }
  }

  Future<VisitSessions> checkoutVisit(String nationalId) async {
    try{
      final response =  await _client.post(AppEndpoints().checkoutVisit,
          body: jsonEncode({'national_id': nationalId})
      );

      log("Checkout Visit: ${response.statusCode}\n${response.body}");
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['message'];
      }else{
        throw Exception('Failed to checkout visit: ${response.statusCode}');
      }
    }catch(e){
      throw Exception('Error checking out visit: $e');
    }
  }

  Future<VisitSessions> assignSecurityToVisit({
    required String visitorId,
    required String unitNumber,
    required String authUid,
  }) async {
    try {
      final response = await _client.post(
        AppEndpoints().assignSecurityOfficer,
        body: jsonEncode({
          'visitorId': visitorId,
          'unitNumber': unitNumber,
          'authUid': authUid,
        }),
      );

      log("Assign Security Officer: ${response.statusCode}\n${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final Map<String, dynamic> visitData = responseBody['data'];
        return VisitSessions.fromJson(visitData);
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        throw Exception('Failed: ${errorData['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Error assigning security officer: $e');
    }
  }

  Future<List<VisitSessions>> fetchActiveVisits() async {
    try {
      final response = await _client.get(AppEndpoints().getActiveVisits);

      log("Fetch Active Visits: ${response.statusCode}\n${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final visits = List<Map<String, dynamic>>.from(data['visits']);
        return visits.map((v) => VisitSessions.fromJson(v)).toList();
      } else {
        throw Exception('Failed to fetch approved visits: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching approved visits: $e');
    }
  }

}
