import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tunihorse/core/constants/api_constants.dart';
import 'package:tunihorse/features/auth/data/auth_session_store.dart';

class TeamsApiException implements Exception {
  final String message;

  const TeamsApiException(this.message);

  @override
  String toString() => message;
}

class TrainerTeamInfo {
  final String id;
  final String nom;
  final String ville;
  final String codeInvitation;
  final String entraineurId;
  final List<String> cavaliers;
  final String? photoUrl;

  const TrainerTeamInfo({
    required this.id,
    required this.nom,
    required this.ville,
    required this.codeInvitation,
    required this.entraineurId,
    required this.cavaliers,
    this.photoUrl,
  });

  factory TrainerTeamInfo.fromJson(Map<String, dynamic> json) {
    return TrainerTeamInfo(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      nom: json['nom']?.toString() ?? '',
      ville: json['ville']?.toString() ?? '',
      codeInvitation: json['codeInvitation']?.toString() ?? '',
      entraineurId: json['entraineurId']?.toString() ?? '',
      cavaliers: (json['cavaliers'] as List? ?? [])
          .map((value) => value.toString())
          .toList(),
      photoUrl: json['photoUrl']?.toString(),
    );
  }
}

class TeamRiderInfo {
  final String id;
  final String nomComplet;
  final String email;
  final String? telephone;
  final String? ville;
  final String? teamId;

  const TeamRiderInfo({
    required this.id,
    required this.nomComplet,
    required this.email,
    this.telephone,
    this.ville,
    this.teamId,
  });

  factory TeamRiderInfo.fromJson(Map<String, dynamic> json) {
    return TeamRiderInfo(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      nomComplet: json['nomComplet']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      telephone: json['telephone']?.toString(),
      ville: json['ville']?.toString(),
      teamId: json['teamId']?.toString(),
    );
  }
}

class TeamUserProfileInfo {
  final String id;
  final String nomComplet;
  final String email;
  final String role;
  final String? telephone;
  final String? ville;
  final String? teamId;

  const TeamUserProfileInfo({
    required this.id,
    required this.nomComplet,
    required this.email,
    required this.role,
    this.telephone,
    this.ville,
    this.teamId,
  });

  factory TeamUserProfileInfo.fromJson(Map<String, dynamic> json) {
    return TeamUserProfileInfo(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      nomComplet: json['nomComplet']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      telephone: json['telephone']?.toString(),
      ville: json['ville']?.toString(),
      teamId: json['teamId']?.toString(),
    );
  }
}

class TeamsApiClient {
  final http.Client _client;

  TeamsApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<TrainerTeamInfo?> getMyTeam() async {
    final response = await _send(
      method: 'GET',
      path: '${ApiConstants.teams}/my-team',
      allowNotFound: true,
    );

    if (response.statusCode == 404) return null;

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return TrainerTeamInfo.fromJson(decoded);
    }

    return null;
  }

  Future<List<TeamRiderInfo>> getTeamRiders(String teamId) async {
    final response = await _send(
      method: 'GET',
      path: '${ApiConstants.teams}/$teamId/cavaliers',
    );

    final decoded = jsonDecode(response.body);
    if (decoded is List) {
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(TeamRiderInfo.fromJson)
          .toList();
    }

    return [];
  }

  Future<List<Map<String, dynamic>>> getTeamHorses(String teamId) async {
    final response = await _send(
      method: 'GET',
      path: '${ApiConstants.teams}/$teamId/horses',
    );

    final decoded = jsonDecode(response.body);
    if (decoded is List) {
      return decoded.whereType<Map<String, dynamic>>().toList();
    }

    return [];
  }

  Future<TeamUserProfileInfo?> getUserProfile(String userId) async {
    if (userId.trim().isEmpty) return null;

    final response = await _send(method: 'GET', path: '/users/$userId');
    final decoded = jsonDecode(response.body);

    if (decoded is Map<String, dynamic>) {
      return TeamUserProfileInfo.fromJson(decoded);
    }

    return null;
  }

  Future<List<TeamRiderInfo>> searchRiders(String query) async {
    final response = await _send(
      method: 'GET',
      path: '/users/riders/search?q=${Uri.encodeQueryComponent(query)}',
    );

    final decoded = jsonDecode(response.body);
    if (decoded is List) {
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(TeamRiderInfo.fromJson)
          .toList();
    }

    return [];
  }

  Future<void> sendInvitation({
    required String cavalierId,
    required String message,
  }) async {
    await _send(
      method: 'POST',
      path: '${ApiConstants.teams}/invitations',
      body: {
        'cavalierId': cavalierId,
        if (message.trim().isNotEmpty) 'message': message.trim(),
      },
    );
  }

  Future<void> respondInvitation({
    required String notificationId,
    required String decision,
  }) async {
    await _send(
      method: 'PATCH',
      path: '${ApiConstants.teams}/invitations/$notificationId/respond',
      body: {'decision': decision},
    );
  }

  Future<TrainerTeamInfo> createTeam({
    required String nom,
    required String ville,
    String? photoPath,
  }) async {
    final fields = <String, dynamic>{
      'nom': nom.trim(),
      'ville': ville.trim(),
    };

    final response = photoPath == null || photoPath.isEmpty
        ? await _send(method: 'POST', path: ApiConstants.teams, body: fields)
        : await _sendMultipart(
            path: ApiConstants.teams,
            fields: fields,
            photoPath: photoPath,
          );

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return TrainerTeamInfo.fromJson(decoded);
    }

    throw const TeamsApiException('Reponse equipe invalide.');
  }

  Future<http.Response> _sendMultipart({
    required String path,
    required Map<String, dynamic> fields,
    required String photoPath,
  }) async {
    final token = AuthSessionStore.accessToken;
    if (token == null || token.isEmpty) {
      throw const TeamsApiException('Session expiree. Reconnectez-vous.');
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
        throw TeamsApiException(_errorMessage(response.body));
      }

      return response;
    } on TimeoutException {
      throw const TeamsApiException('Le serveur ne repond pas.');
    } on TeamsApiException {
      rethrow;
    } catch (error) {
      throw TeamsApiException('Impossible d envoyer la photo: $error');
    }
  }

  Future<http.Response> _send({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    bool allowNotFound = false,
  }) async {
    final token = AuthSessionStore.accessToken;
    if (token == null || token.isEmpty) {
      throw const TeamsApiException('Session expiree. Reconnectez-vous.');
    }

    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    http.Response response;

    try {
      if (method == 'POST') {
        response = await _client
            .post(uri, headers: headers, body: jsonEncode(body ?? {}))
            .timeout(const Duration(seconds: 15));
      } else if (method == 'PATCH') {
        response = await _client
            .patch(uri, headers: headers, body: jsonEncode(body ?? {}))
            .timeout(const Duration(seconds: 15));
      } else {
        response = await _client
            .get(uri, headers: headers)
            .timeout(const Duration(seconds: 15));
      }
    } on TimeoutException {
      throw const TeamsApiException('Le serveur ne repond pas.');
    } catch (error) {
      throw TeamsApiException('Impossible de contacter le serveur: $error');
    }

    if (allowNotFound && response.statusCode == 404) return response;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw TeamsApiException(_errorMessage(response.body));
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

    return 'Erreur serveur pendant l operation equipe.';
  }

  void close() {
    _client.close();
  }
}
