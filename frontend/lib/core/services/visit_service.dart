import 'dart:convert';
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
      
      // Check if we have a valid Supabase session
      final session = _client.supabase.auth.currentSession;
      log("VisitService: Current Supabase session: ${session != null ? 'Valid' : 'Not authenticated'}");
      
      final response = await _client.post(
        AppEndpoints().submitVisit,
        body: jsonEncode(visitSession.toJson()),
      );

      log("VisitService: Create Visit Session response - Status: ${response.statusCode}");
      log("VisitService: Response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        log("VisitService: Visit session created successfully");
        final Map<String, dynamic> data = jsonDecode(response.body);
        log("VisitService: Parsed response data: ${jsonEncode(data)}");
        
        if (data['data'] != null) {
          return VisitSessions.fromJson(data['data']);
        } else {
          log("VisitService: Response data format unexpected: ${jsonEncode(data)}");
          throw Exception('Invalid response format from server');
        }
      } else {
        log("VisitService: Failed to create visit session: ${response.statusCode}");
        log("VisitService: Error response: ${response.body}");
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
