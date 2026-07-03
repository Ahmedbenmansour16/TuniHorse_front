import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tunihorse/core/constants/api_constants.dart';
import 'package:tunihorse/features/auth/data/auth_session_store.dart';

class HorsesApiException implements Exception {
  final String message;

  const HorsesApiException(this.message);

  @override
  String toString() => message;
}

class HorsesApiClient {
  final http.Client _client;

  HorsesApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Map<String, dynamic>>> getMyHorses() async {
    final response = await _send(
      method: 'GET',
      path: '${ApiConstants.horses}/my-horses',
    );

    final decoded = jsonDecode(response.body);
    if (decoded is List) {
      return decoded.whereType<Map<String, dynamic>>().toList();
    }

    return [];
  }

  Future<List<Map<String, dynamic>>> getHorseRaces() async {
    final response = await _send(
      method: 'GET',
      path: '${ApiConstants.horses}/races',
    );

    final decoded = jsonDecode(response.body);
    if (decoded is List) {
      return decoded.whereType<Map<String, dynamic>>().toList();
    }

    return [];
  }

  Future<Map<String, dynamic>> createHorse({
    required String nom,
    String? raceId,
    String? race,
    int? age,
    String? dateNaissance,
    String? sexe,
    double? poidsKg,
    String? numeroPuce,
    String? photoUrl,
    String? photoPath,
  }) async {
    final body = <String, dynamic>{
      'nom': nom.trim(),
      if (raceId != null && raceId.trim().isNotEmpty) 'raceId': raceId.trim(),
      if (race != null && race.trim().isNotEmpty) 'race': race.trim(),
      if (age != null) 'age': age,
      if (dateNaissance != null && dateNaissance.trim().isNotEmpty)
        'dateNaissance': dateNaissance.trim(),
      if (sexe != null && sexe.isNotEmpty) 'sexe': sexe,
      if (poidsKg != null) 'poidsKg': poidsKg,
      if (numeroPuce != null && numeroPuce.trim().isNotEmpty)
        'numeroPuce': numeroPuce.trim(),
      if (photoUrl != null && photoUrl.trim().isNotEmpty)
        'photoUrl': photoUrl.trim(),
    };

    final response = photoPath == null || photoPath.isEmpty
        ? await _send(method: 'POST', path: ApiConstants.horses, body: body)
        : await _sendMultipart(
            path: ApiConstants.horses,
            fields: body,
            photoPath: photoPath,
          );

    final decoded = jsonDecode(response.body);
    return decoded is Map<String, dynamic> ? decoded : {};
  }

  Future<http.Response> _sendMultipart({
    required String path,
    required Map<String, dynamic> fields,
    required String photoPath,
  }) async {
    final token = AuthSessionStore.accessToken;
    if (token == null || token.isEmpty) {
      throw const HorsesApiException('Session expiree. Reconnectez-vous.');
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConstants.baseUrl}$path'),
    );

    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    request.fields.addAll(
      fields.map((key, value) => MapEntry(key, value.toString())),
    );
    request.files.add(await http.MultipartFile.fromPath('photo', photoPath));

    try {
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HorsesApiException(_errorMessage(response.body));
      }

      return response;
    } on TimeoutException {
      throw const HorsesApiException('Le serveur ne repond pas.');
    } on HorsesApiException {
      rethrow;
    } catch (error) {
      throw HorsesApiException('Impossible d envoyer la photo: $error');
    }
  }

  Future<http.Response> _send({
    required String method,
    required String path,
    Map<String, dynamic>? body,
  }) async {
    final token = AuthSessionStore.accessToken;
    if (token == null || token.isEmpty) {
      throw const HorsesApiException('Session expiree. Reconnectez-vous.');
    }

    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    http.Response response;

    try {
      response = method == 'POST'
          ? await _client
                .post(uri, headers: headers, body: jsonEncode(body ?? {}))
                .timeout(const Duration(seconds: 15))
          : await _client
                .get(uri, headers: headers)
                .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw const HorsesApiException('Le serveur ne repond pas.');
    } catch (error) {
      throw HorsesApiException('Impossible de contacter le serveur: $error');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HorsesApiException(_errorMessage(response.body));
    }

    return response;
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

    return 'Erreur serveur pendant l operation cheval.';
  }

  void close() {
    _client.close();
  }
}
