import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tunihorse/core/constants/api_constants.dart';
import 'package:tunihorse/core/constants/app_colors.dart';
import 'package:tunihorse/core/models/ui_models.dart';
import 'package:tunihorse/features/auth/data/auth_session_store.dart';

class HealthApiException implements Exception {
  final String message;

  const HealthApiException(this.message);

  @override
  String toString() => message;
}

class HealthCareTypeOption {
  final String id;
  final String code;
  final String label;
  final int reminderDays;
  final String reminderLabel;

  const HealthCareTypeOption({
    required this.id,
    required this.code,
    required this.label,
    required this.reminderDays,
    required this.reminderLabel,
  });

  factory HealthCareTypeOption.fromJson(Map<String, dynamic> json) {
    return HealthCareTypeOption(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      reminderDays: int.tryParse(json['reminderDays']?.toString() ?? '') ?? 0,
      reminderLabel: json['reminderLabel']?.toString() ?? '',
    );
  }
}

class HealthRecordItem {
  final String id;
  final String careTypeLabel;
  final DateTime dateSoin;
  final DateTime reminderDate;
  final String? notes;

  const HealthRecordItem({
    required this.id,
    required this.careTypeLabel,
    required this.dateSoin,
    required this.reminderDate,
    this.notes,
  });

  factory HealthRecordItem.fromJson(Map<String, dynamic> json) {
    return HealthRecordItem(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      careTypeLabel: json['careTypeLabel']?.toString() ?? 'Soin',
      dateSoin:
          DateTime.tryParse(json['dateSoin']?.toString() ?? '') ??
          DateTime.now(),
      reminderDate:
          DateTime.tryParse(json['reminderDate']?.toString() ?? '') ??
          DateTime.now(),
      notes: json['notes']?.toString(),
    );
  }
}

class NextHealthReminder {
  final String id;
  final String careTypeLabel;
  final DateTime reminderDate;
  final Horse horse;

  const NextHealthReminder({
    required this.id,
    required this.careTypeLabel,
    required this.reminderDate,
    required this.horse,
  });

  factory NextHealthReminder.fromJson(Map<String, dynamic> json) {
    final horseJson = json['horse'] is Map<String, dynamic>
        ? json['horse'] as Map<String, dynamic>
        : <String, dynamic>{};
    final photoUrl = horseJson['photoUrl']?.toString();

    return NextHealthReminder(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      careTypeLabel: json['careTypeLabel']?.toString() ?? 'Rappel sante',
      reminderDate:
          DateTime.tryParse(json['reminderDate']?.toString() ?? '') ??
          DateTime.now(),
      horse: Horse(
        id: horseJson['id']?.toString() ?? horseJson['_id']?.toString(),
        name: horseJson['nom']?.toString() ?? 'Cheval',
        race: horseJson['race']?.toString() ?? 'Race non precisee',
        age: horseJson['age'] == null ? '--' : '${horseJson['age']} ans',
        owner: '',
        status: 'Actif',
        color: AppColors.green,
        photoUrl: photoUrl == null || photoUrl.isEmpty
            ? null
            : (photoUrl.startsWith('http')
                  ? photoUrl
                  : '${ApiConstants.baseUrl}$photoUrl'),
      ),
    );
  }
}

class HealthApiClient {
  final http.Client _client;

  HealthApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<List<HealthCareTypeOption>> getCareTypes() async {
    final response = await _send(
      method: 'GET',
      path: '${ApiConstants.health}/types',
    );
    final decoded = jsonDecode(response.body);

    if (decoded is List) {
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(HealthCareTypeOption.fromJson)
          .toList();
    }

    return [];
  }

  Future<NextHealthReminder?> getNextReminder() async {
    final response = await _send(
      method: 'GET',
      path: '${ApiConstants.health}/reminders/next',
    );
    final decoded = jsonDecode(response.body);

    if (decoded is Map<String, dynamic>) {
      return NextHealthReminder.fromJson(decoded);
    }

    return null;
  }

  Future<List<NextHealthReminder>> getUpcomingReminders({int? limit}) async {
    final query = limit == null ? '' : '?limit=$limit';
    final response = await _send(
      method: 'GET',
      path: '${ApiConstants.health}/reminders/upcoming$query',
    );
    final decoded = jsonDecode(response.body);

    if (decoded is List) {
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(NextHealthReminder.fromJson)
          .toList();
    }

    return [];
  }

  Future<List<HealthRecordItem>> getHorseRecords(String horseId) async {
    final response = await _send(
      method: 'GET',
      path: '${ApiConstants.health}/horse/$horseId',
    );
    final decoded = jsonDecode(response.body);

    if (decoded is List) {
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(HealthRecordItem.fromJson)
          .toList();
    }

    return [];
  }

  Future<List<HealthRecordItem>> getHorseHistory(String horseId) async {
    final response = await _send(
      method: 'GET',
      path: '${ApiConstants.health}/horse/$horseId/history',
    );
    final decoded = jsonDecode(response.body);

    if (decoded is List) {
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(HealthRecordItem.fromJson)
          .toList();
    }

    return [];
  }

  Future<void> createRecord({
    required String horseId,
    required String careTypeId,
    required DateTime dateSoin,
    String? notes,
  }) async {
    await _send(
      method: 'POST',
      path: ApiConstants.health,
      body: {
        'horseId': horseId,
        'careTypeId': careTypeId,
        'dateSoin': _toIsoDate(dateSoin),
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      },
    );
  }

  Future<http.Response> _send({
    required String method,
    required String path,
    Map<String, dynamic>? body,
  }) async {
    final token = AuthSessionStore.accessToken;
    if (token == null || token.isEmpty) {
      throw const HealthApiException('Session expiree. Reconnectez-vous.');
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
      throw const HealthApiException('Le serveur ne repond pas.');
    } catch (error) {
      throw HealthApiException('Impossible de contacter le serveur: $error');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HealthApiException(_errorMessage(response.body));
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

    return 'Erreur serveur pendant l operation sante.';
  }

  String _toIsoDate(DateTime date) {
    return '${date.year}-${_two(date.month)}-${_two(date.day)}';
  }

  String _two(int value) => value.toString().padLeft(2, '0');

  void close() {
    _client.close();
  }
}
