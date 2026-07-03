import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tunihorse/core/constants/api_constants.dart';
import 'package:tunihorse/features/auth/data/auth_session_store.dart';

class CoursesApiException implements Exception {
  final String message;

  const CoursesApiException(this.message);

  @override
  String toString() => message;
}

class CoursesApiClient {
  final http.Client _client;

  CoursesApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Map<String, dynamic>>> getCourses() async {
    final response = await _send(method: 'GET', path: '/courses');
    final decoded = jsonDecode(response.body);

    if (decoded is List) {
      return decoded.whereType<Map<String, dynamic>>().toList();
    }

    return [];
  }

  Future<http.Response> _send({
    required String method,
    required String path,
  }) async {
    final token = AuthSessionStore.accessToken;
    if (token == null || token.isEmpty) {
      throw const CoursesApiException('Session expiree. Reconnectez-vous.');
    }

    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await _client
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw CoursesApiException(_errorMessage(response.body));
      }

      return response;
    } on TimeoutException {
      throw const CoursesApiException('Le serveur ne repond pas.');
    } on CoursesApiException {
      rethrow;
    } catch (error) {
      throw CoursesApiException('Impossible de contacter le serveur: $error');
    }
  }

  String _errorMessage(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'];
        if (message is List) return message.join('\n');
        if (message is String && message.isNotEmpty) return message;
      }
    } catch (_) {}

    return 'Erreur serveur pendant le chargement des courses.';
  }

  void close() {
    _client.close();
  }
}
