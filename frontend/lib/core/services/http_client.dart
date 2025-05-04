import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class HttpClientWrapper {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<http.Response> post(String path,
      {Map<String, String>? headers, dynamic body}) async {
    final url = Uri.parse(path);
    final headers = await _getHeaders();

    http.Response response = await http.post(url, headers: headers, body: body);

    if (response.statusCode >= 401) {
      final refreshResult = await _attemptTokenRefresh();
      if (refreshResult) {
        final newHeaders = await _getHeaders();
        response = await http.post(url, headers: newHeaders, body: body);
      }
    }
    return response;
  }

  Future<Map<String, String>> _getHeaders() async {
    final accessToken = supabase.auth.currentSession?.accessToken;
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
  }

  Future<bool> _attemptTokenRefresh() async {
   try{
     final result = await supabase.auth.refreshSession();
     return result.session != null;
   }catch(e){
     print('Error refreshing token: $e');
     return false;
   }
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  Future<void> changeEmail(String email) async {
    await supabase.auth.updateUser(UserAttributes(email: email));
  }

  Future<void> resetPassword(String email) async {
    await supabase.auth.resetPasswordForEmail(email);
  }

  Future<http.Response> get(String path, {Map<String, String>? headers}) async {
    final url = Uri.parse(path);
    final headers = await _getHeaders();

    http.Response response = await http.get(url, headers: headers);

    if (response.statusCode >= 401) {
      final refreshResult = await _attemptTokenRefresh();
      if (refreshResult) {
        final newHeaders = await _getHeaders();
        response = await http.get(url, headers: newHeaders);
      }
    }
    return response;
  }

  Future<http.Response> put(String path,
      {Map<String, String>? headers, dynamic body}) async {
    final url = Uri.parse(path);
    final headers = await _getHeaders();

    http.Response response = await http.put(url, headers: headers, body: body);

    if (response.statusCode >= 401) {
      final refreshResult = await _attemptTokenRefresh();
      if (refreshResult) {
        final newHeaders = await _getHeaders();
        response = await http.put(url, headers: newHeaders, body: body);
      }
    }
    return response;
  }

  Future<http.Response> delete(String path,
      {Map<String, String>? headers, dynamic body}) async {
    final url = Uri.parse(path);
    final headers = await _getHeaders();

    http.Response response = await http.delete(url, headers: headers, body: body);

    if (response.statusCode >= 401) {
      final refreshResult = await _attemptTokenRefresh();
      if (refreshResult) {
        final newHeaders = await _getHeaders();
        response = await http.delete(url, headers: newHeaders, body: body);
      }
    }
    return response;
  }

}