import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:tunihorse/core/constants/api_constants.dart';

class AuthSession {
  final String accessToken;
  final String role;
  final Map<String, dynamic>? user;

  const AuthSession({required this.accessToken, required this.role, this.user});

  bool get isTrainer => role == 'ENTRAINEUR';
  bool get isRider => role == 'CAVALIER';
}

class AuthApiException implements Exception {
  final String message;

  const AuthApiException(this.message);

  @override
  String toString() => message;
}

class AuthApiClient {
  final http.Client _client;

  AuthApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<AuthSession> login({required String email, required String password}) {
    return _post(ApiConstants.login, {
      'email': email.trim(),
      'password': password,
    });
  }

  Future<AuthSession> register({
    required String nomComplet,
    required String email,
    required String telephone,
    required String ville,
    required String role,
    required String password,
  }) {
    return _post(ApiConstants.register, {
      'nomComplet': nomComplet.trim(),
      'email': email.trim(),
      'telephone': telephone.trim(),
      'ville': ville.trim(),
      'role': role.trim(),
      'password': password,
    });
  }

  Future<AuthSession> _post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');

    debugPrint('================ AUTH REQUEST ================');
    debugPrint('URL: $uri');
    debugPrint('BODY: ${jsonEncode(body)}');
    debugPrint('==============================================');

    http.Response response;

    try {
      response = await _client
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw const AuthApiException(
        'Le serveur ne répond pas. Vérifiez que le backend NestJS est lancé.',
      );
    } catch (e) {
      throw AuthApiException('Impossible de contacter le serveur. Détail: $e');
    }

    debugPrint('================ AUTH RESPONSE ===============');
    debugPrint('STATUS CODE: ${response.statusCode}');
    debugPrint('RESPONSE BODY: ${response.body}');
    debugPrint('==============================================');

    final decoded = _decode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthApiException(_errorMessage(decoded));
    }

    /*
      Le backend peut retourner :
      {
        "accessToken": "...",
        "user": {
          "role": "CAVALIER"
        }
      }

      Ou parfois :
      {
        "token": "...",
        "user": {
          "role": "CAVALIER"
        }
      }

      Ou :
      {
        "access_token": "...",
        "user": {
          "role": "CAVALIER"
        }
      }
    */

    final accessToken =
        decoded['accessToken'] ?? decoded['token'] ?? decoded['access_token'];

    final user = decoded['user'];

    String? role;

    if (user is Map<String, dynamic>) {
      role = user['role']?.toString();
    }

    role ??= decoded['role']?.toString();

    if (accessToken is! String || accessToken.isEmpty) {
      throw const AuthApiException(
        'Réponse auth invalide : accessToken manquant.',
      );
    }

    if (role == null || role.isEmpty) {
      throw const AuthApiException(
        'Réponse auth invalide : rôle utilisateur manquant.',
      );
    }

    return AuthSession(
      accessToken: accessToken,
      role: role,
      user: user is Map<String, dynamic> ? user : null,
    );
  }

  Map<String, dynamic> _decode(String body) {
    try {
      final decoded = jsonDecode(body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {};
    } catch (_) {
      return {};
    }
  }

  String _errorMessage(Map<String, dynamic> decoded) {
    final message = decoded['message'];

    if (message is List) {
      return message.join('\n');
    }

    if (message is String && message.isNotEmpty) {
      return message;
    }

    final error = decoded['error'];

    if (error is String && error.isNotEmpty) {
      return error;
    }

    return 'Erreur serveur inconnue.';
  }

  void close() {
    _client.close();
  }
}
