import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tunihorse/core/constants/api_constants.dart';
import 'package:tunihorse/features/auth/data/auth_session_store.dart';

class NotificationsApiException implements Exception {
  final String message;

  const NotificationsApiException(this.message);

  @override
  String toString() => message;
}

class AppNotificationInfo {
  final String id;
  final String type;
  final String title;
  final String message;
  final bool read;
  final Map<String, dynamic> metadata;
  final DateTime? createdAt;

  const AppNotificationInfo({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.read,
    this.metadata = const {},
    this.createdAt,
  });

  bool get isTeamInvitation => type == 'TEAM_INVITATION';
  String get invitationStatus => metadata['status']?.toString() ?? '';

  factory AppNotificationInfo.fromJson(Map<String, dynamic> json) {
    final rawMetadata = json['metadata'];

    return AppNotificationInfo(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'GENERAL',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      read: json['read'] == true,
      metadata: rawMetadata is Map<String, dynamic> ? rawMetadata : {},
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }
}

class NotificationsApiClient {
  final http.Client _client;

  NotificationsApiClient({http.Client? client})
      : _client = client ?? http.Client();

  Future<List<AppNotificationInfo>> getNotifications() async {
    final response = await _send(method: 'GET', path: '/notifications');
    final decoded = jsonDecode(response.body);

    if (decoded is List) {
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(AppNotificationInfo.fromJson)
          .toList();
    }

    return [];
  }

  Future<void> markAsRead(String id) async {
    await _send(method: 'PATCH', path: '/notifications/$id/read');
  }

  Future<void> respondTeamInvitation({
    required String notificationId,
    required String decision,
  }) async {
    await _send(
      method: 'PATCH',
      path: '${ApiConstants.teams}/invitations/$notificationId/respond',
      body: {'decision': decision},
    );
  }

  Future<http.Response> _send({
    required String method,
    required String path,
    Map<String, dynamic>? body,
  }) async {
    final token = AuthSessionStore.accessToken;
    if (token == null || token.isEmpty) {
      throw const NotificationsApiException(
        'Session expiree. Reconnectez-vous.',
      );
    }

    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    http.Response response;

    try {
      if (method == 'PATCH') {
        response = await _client
            .patch(uri, headers: headers, body: jsonEncode(body ?? {}))
            .timeout(const Duration(seconds: 15));
      } else {
        response = await _client
            .get(uri, headers: headers)
            .timeout(const Duration(seconds: 15));
      }
    } on TimeoutException {
      throw const NotificationsApiException('Le serveur ne repond pas.');
    } catch (error) {
      throw NotificationsApiException(
        'Impossible de contacter le serveur: $error',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw NotificationsApiException(_errorMessage(response.body));
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

    return 'Erreur serveur pendant les notifications.';
  }

  void close() {
    _client.close();
  }
}
